import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/config/constants.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _role;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get role => _role;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Initialize in a post-frame callback to ensure Flutter is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  Future<void> _initializeAuth() async {
    if (_status != AuthStatus.initial) return;

    _status = AuthStatus.loading;
    _safeNotifyListeners();

    try {
      // First check if we have local cached auth state
      Map<String, dynamic>? cachedAuthState;
      try {
        cachedAuthState = await LocalStorageService.getAuthState();
      } catch (e) {
        debugPrint('Error getting cached auth state: $e');
        // Continue without cached state
      }

      // Get current user from Supabase
      try {
        _user = await _supabaseService.getCurrentUser();
      } catch (e) {
        debugPrint('Error getting current user: $e');
        _user = null;
      }

      if (_user != null) {
        try {
          // Try to get user profile from Supabase
          final userData = await _supabaseService.getUserProfile(_user!.id);
          if (userData != null) {
            // Important: Use user_role from the profiles table, not role from metadata
            _role = userData['user_role'] as String? ?? '';
            debugPrint('Retrieved user_role from profile: $_role');

            // Ensure role is synchronized between metadata and profile
            await _ensureRoleSynchronization(_role);

            // Save the user data to local storage
            await LocalStorageService.saveUserProfile(userData);
            await LocalStorageService.saveAuthState(
              userId: _user!.id,
              email: _user!.email ?? '',
              role: _role ?? '',
            );

            _status = AuthStatus.authenticated;
          } else if (cachedAuthState != null) {
            // Use cached data if no server data
            _role = cachedAuthState['user_role'] as String?;
            _status = AuthStatus.authenticated;

            // Try to create or update profile with the cached role
            if (_role != null && _role!.isNotEmpty) {
              await _createOrUpdateProfile(_role);
            }
          } else {
            // Fallback to metadata if no cached data
            _role = _user?.userMetadata?['role'] as String? ?? '';
            _status = AuthStatus.authenticated;

            // Try to create or update profile with metadata role
            if (_role != null && _role!.isNotEmpty) {
              await _createOrUpdateProfile(_role);
            }
          }
        } catch (e) {
          debugPrint('Error fetching user profile: $e');

          // If error fetching, try to use cached data
          if (cachedAuthState != null) {
            _role = cachedAuthState['user_role'] as String?;
          } else {
            // Fallback to metadata if no cached data
            _role = _user?.userMetadata?['role'] as String? ?? '';
          }
          _status = AuthStatus.authenticated;

          // Try to create or update profile with the role we have
          if (_role != null && _role!.isNotEmpty) {
            await _createOrUpdateProfile(_role);
          }
        }
      } else {
        // Check for persisted auth state even if Supabase session is gone
        if (cachedAuthState != null &&
            cachedAuthState['is_authenticated'] == true) {
          // Try to refresh the session or sign out
          try {
            await _supabaseService.client.auth.refreshSession();
            _user = _supabaseService.client.auth.currentUser;
            if (_user != null) {
              _role = cachedAuthState['user_role'] as String?;
              _status = AuthStatus.authenticated;

              // Try to create or update profile with cached role
              if (_role != null && _role!.isNotEmpty) {
                await _createOrUpdateProfile(_role);
              }
            } else {
              // Session couldn't be refreshed, clear local state
              await LocalStorageService.clearAuthState();
              await LocalStorageService.clearUserProfile();
              _status = AuthStatus.unauthenticated;
            }
          } catch (e) {
            debugPrint('Error refreshing session: $e');
            await LocalStorageService.clearAuthState();
            await LocalStorageService.clearUserProfile();
            _status = AuthStatus.unauthenticated;
          }
        } else {
          _status = AuthStatus.unauthenticated;
        }
      }
    } catch (e) {
      debugPrint('Error in initialization: $e');
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }

    _safeNotifyListeners();
  }

  // Safe wrapper for notifyListeners to avoid binding issues
  void _safeNotifyListeners() {
    try {
      // If we're in the middle of a build/layout, schedule for later
      if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
    } catch (e) {
      // If binding isn't available, use a microtask
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      _user = response.user;

      if (_user != null) {
        try {
          // Get user profile
          final userData = await _supabaseService.getUserProfile(_user!.id);

          if (userData != null) {
            // Important: Use user_role from the profiles table
            _role = userData['user_role'] as String? ?? '';

            // Ensure metadata and profile roles are synchronized
            await _ensureRoleSynchronization(_role);

            debugPrint('Retrieved user_role on login: $_role');

            // Save user data to local storage
            await LocalStorageService.saveUserProfile(userData);
            await LocalStorageService.saveAuthState(
              userId: _user!.id,
              email: _user!.email ?? '',
              role: _role ?? '',
            );
          } else {
            // If profile retrieval fails, try to use metadata as fallback
            _role = _user?.userMetadata?['role'] as String? ?? 'unknown';
            debugPrint(
                'No user profile data returned, using metadata role: $_role');

            // Try to create/update profile with metadata role
            if (_role != 'unknown') {
              await _createOrUpdateProfile(_role);
            }
          }

          // Set authenticated status and notify listeners immediately
          _status = AuthStatus.authenticated;
          _safeNotifyListeners();
          return true;
        } catch (e) {
          debugPrint('Error getting user profile: $e');
          // Still consider login successful even if profile fetch fails
          // Get role from user metadata as fallback
          _role = _user?.userMetadata?['role'] as String? ?? 'unknown';
          debugPrint('Error retrieving profile, using metadata role: $_role');

          // Try to create/update profile with metadata role
          if (_role != 'unknown') {
            await _createOrUpdateProfile(_role);
          }

          _status = AuthStatus.authenticated;
          _safeNotifyListeners();
          return true;
        }
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Authentication failed';
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;

      // Extract more meaningful error messages for common issues
      String errorMsg = e.toString();

      if (errorMsg.contains('email_not_confirmed') ||
          errorMsg.contains('Email not confirmed')) {
        _errorMessage =
            'Please verify your email address before logging in. Check your inbox for a confirmation email.';
      } else if (errorMsg.contains('Invalid login credentials')) {
        _errorMessage = 'Invalid email or password. Please try again.';
      } else {
        _errorMessage = errorMsg;
      }

      _safeNotifyListeners();
      return false;
    }
  }

  // Ensure role synchronization between profile and metadata
  Future<void> _ensureRoleSynchronization(String? profileRole) async {
    try {
      if (_user == null || profileRole == null) return;

      // Get current metadata role
      final metadataRole = _user?.userMetadata?['role'] as String?;

      // If roles don't match, update metadata
      if (metadataRole != profileRole && profileRole.isNotEmpty) {
        debugPrint('Syncing metadata role with profile role: $profileRole');

        // Update user metadata with the profile role
        await _supabaseService.client.auth.updateUser(
          UserAttributes(
            data: {
              'role': profileRole,
              // Preserve other metadata
              ..._user?.userMetadata?.map((key, value) =>
                      MapEntry(key, key == 'role' ? profileRole : value)) ??
                  {},
            },
          ),
        );
      }
      // If profile role is empty but metadata has a role, create/update profile
      else if (profileRole.isEmpty &&
          metadataRole != null &&
          metadataRole.isNotEmpty) {
        await _createOrUpdateProfile(metadataRole);
      }
    } catch (e) {
      debugPrint('Error syncing roles: $e');
    }
  }

  // Create or update the user profile
  Future<void> _createOrUpdateProfile(String? roleParam) async {
    try {
      if (_user == null) return;

      // Ensure role is not null
      final role = roleParam ?? 'unknown';
      if (role == 'unknown') {
        debugPrint(
            'Warning: Attempting to create/update profile with unknown role');
      }

      final email = _user!.email ?? '';
      final fullName = _user?.userMetadata?['full_name']?.toString() ?? '';
      final phone = _user?.userMetadata?['phone']?.toString() ?? '';

      // Basic profile data
      final profileData = {
        'id': _user!.id,
        'email': email,
        'user_role': role,
        'full_name': fullName,
        'phone': phone,
      };

      // Try to retrieve existing profile
      final existingProfile = await _supabaseService.getUserProfile(_user!.id);

      if (existingProfile != null) {
        // Update existing profile with role
        await _supabaseService
            .updateData('profiles', _user!.id, {'user_role': role});
      } else {
        // Create new profile
        await _supabaseService.insertData('profiles', profileData);
      }

      debugPrint('Profile created/updated with role: $role');
    } catch (e) {
      debugPrint('Error creating/updating profile: $e');
    }
  }

  Future<bool> signUp(String email, String password, String role,
      Map<String, dynamic> userData) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      // Separate auth metadata from profile data
      final authMetadata = {
        'role': role,
        'full_name': userData['full_name'],
        'phone': userData['phone'],
      };

      // Remove non-essential fields from profile data
      final profileData = Map<String, dynamic>.from(userData);
      // Add user_role to profile data (required by RLS policies)
      profileData['user_role'] = role;
      // Add email to profile data (required by RLS policies)
      profileData['email'] = email;

      // Step 1: Sign up with Supabase Auth with user metadata
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        role: role,
        userMetadata: authMetadata,
      );

      _user = response.user;

      if (_user != null) {
        // Store user data locally
        _role = role;

        // Save auth state
        await LocalStorageService.saveAuthState(
          userId: _user!.id,
          email: email,
          role: role,
        );

        try {
          // Step 2: Create user profile
          // Ensure profileData has the user ID
          profileData['id'] = _user!.id;

          try {
            // Try to create profile - handle potential errors with Arabic text
            await _supabaseService.insertData('profiles', profileData);

            // Save profile data locally
            await LocalStorageService.saveUserProfile({
              ...profileData,
              'id': _user!.id,
              'email': email,
              'role': role,
            });
          } catch (e) {
            debugPrint('Error creating profile: $e');

            // Check if the profile might already exist
            if (e.toString().contains('violates row-level security policy')) {
              // Try to update profile instead
              try {
                await _supabaseService.updateData(
                    'profiles', _user!.id, profileData);
              } catch (updateError) {
                debugPrint(
                    'Error updating profile after creation failed: $updateError');
                // Profile might exist but we can't update it, continue with auth-only credentials
              }
            }
          }

          _status = AuthStatus.authenticated;
          _safeNotifyListeners();
          return true;
        } catch (e) {
          debugPrint('Error in profile creation: $e');
          // Still consider signup successful if the auth part worked
          _status = AuthStatus.authenticated;
          _safeNotifyListeners();
          return true;
        }
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage =
            'Registration failed. Please check your information and try again.';
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;

      // Parse error message
      String errorMsg = e.toString();

      if (errorMsg.contains('already registered')) {
        _errorMessage =
            'This email is already registered. Please sign in or use a different email.';
      } else if (errorMsg.contains('invalid email')) {
        _errorMessage = 'Please enter a valid email address.';
      } else if (errorMsg.contains('violates row-level security policy')) {
        _errorMessage =
            'Permission error during profile creation. Please try again or contact support.';
      } else {
        _errorMessage = errorMsg;
      }

      _safeNotifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    _safeNotifyListeners();

    try {
      // Clear local storage first to ensure UI can navigate away
      await LocalStorageService.clearAuthState();
      await LocalStorageService.clearUserProfile();

      // Reset local state
      _user = null;
      _role = null;
      _status = AuthStatus.unauthenticated;
      _safeNotifyListeners();

      // Then try to sign out from Supabase
      // Even if this fails, the UI will already be in unauthenticated state
      try {
        await _supabaseService.signOut();
      } catch (supabaseError) {
        // Log but don't change state since we've already cleared local state
        debugPrint(
            'Supabase sign out error (UI already updated): $supabaseError');
      }
    } catch (e) {
      debugPrint('Error during sign out process: $e');

      // Even if there's an error, force unauthenticated state
      _user = null;
      _role = null;
      _status = AuthStatus.unauthenticated;

      // Try to clear storage again just in case
      try {
        await LocalStorageService.clearAuthState();
        await LocalStorageService.clearUserProfile();
      } catch (storageError) {
        debugPrint('Error clearing storage during fallback: $storageError');
      }

      _safeNotifyListeners();
    }
  }

  Future<void> refreshUser() async {
    try {
      _user = await _supabaseService.getCurrentUser();

      if (_user != null) {
        // Simply delegate to refreshUserRole for consistent logic
        await refreshUserRole();
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
      _errorMessage = 'Error refreshing user data: ${e.toString()}';
      _safeNotifyListeners();
    }
  }

  Future<bool> resendConfirmationEmail(String email) async {
    try {
      await _supabaseService.resendConfirmationEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  Future<void> refreshUserRole() async {
    if (_user != null) {
      try {
        final userData = await _supabaseService.getUserProfile(_user!.id);
        if (userData != null) {
          final newRole = userData['user_role'] as String? ?? '';

          // Ensure metadata and profile roles are synchronized
          await _ensureRoleSynchronization(newRole);

          if (_role != newRole) {
            _role = newRole;
            debugPrint('Updated user role to: $_role');

            // Also update local storage when role changes
            await LocalStorageService.saveAuthState(
              userId: _user!.id,
              email: _user!.email ?? '',
              role: _role ?? '',
            );
            await LocalStorageService.saveUserProfile(userData);

            _safeNotifyListeners();
          }
        } else {
          // If profile not found, try to retrieve role from metadata
          final metadataRole = _user?.userMetadata?['role'] as String?;
          if (metadataRole != null &&
              metadataRole.isNotEmpty &&
              _role != metadataRole) {
            debugPrint(
                'Using role from metadata: $metadataRole (profile not found)');
            _role = metadataRole;

            // Try to create a profile with this role
            await _createOrUpdateProfile(metadataRole);

            _safeNotifyListeners();
          }
        }
      } catch (e) {
        debugPrint('Error refreshing user role: $e');
        // Try to use cached role from local storage as fallback
        try {
          final cachedAuthState = await LocalStorageService.getAuthState();
          if (cachedAuthState != null && cachedAuthState['user_role'] != null) {
            final cachedRole = cachedAuthState['user_role'] as String;
            if (_role != cachedRole) {
              _role = cachedRole;
              debugPrint('Using cached role from local storage: $_role');
              _safeNotifyListeners();
            }
          }
        } catch (cacheError) {
          debugPrint('Error retrieving cached role: $cacheError');
        }
      }
    }
  }
}
