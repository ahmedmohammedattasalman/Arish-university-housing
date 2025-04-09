import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import 'package:provider/provider.dart';
import '../localization/language_provider.dart';

class SupabaseService {
  late final SupabaseClient _client;
  static bool _isInitialized = false;

  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized) {
      return;
    }

    try {
      // Initialize Supabase
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
        debug: false, // Set to false for production
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('Supabase initialization completed successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }

  // Close Supabase connections properly
  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        await Supabase.instance.dispose();
        _isInitialized = false;
      } catch (e) {
        debugPrint('Error disposing Supabase: $e');
      }
    }
  }

  bool get isInitialized => _isInitialized;

  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception(
          'Supabase client not initialized. Call initialize() first.');
    }
    return _client;
  }

  // Insert data with proper encoding for Arabic text
  Future<dynamic> insertData(String tableName, Map<String, dynamic> data,
      {BuildContext? context}) async {
    try {
      // Ensure data is properly encoded for Arabic if the app is in Arabic mode
      if (context != null) {
        final isArabic =
            Provider.of<LanguageProvider>(context, listen: false).isArabic;
        if (isArabic) {
          // Process Arabic text if needed
          data = _processArabicData(data);
        }
      }

      // If the table is 'profiles', ensure we have the correct user ID
      if (tableName == 'profiles') {
        final user = await getCurrentUser();
        if (user != null && !data.containsKey('id')) {
          data['id'] = user.id;
        }
      }

      final response = await _client.from(tableName).insert(data).select();
      return response;
    } catch (e) {
      debugPrint('Error inserting data: $e');
      // Handle RLS policy errors more gracefully
      if (e.toString().contains('violates row-level security policy')) {
        throw Exception(
            'Permission denied. You may not have the right access to perform this operation.');
      }
      // Handle potential character encoding issues
      if (e.toString().contains('invalid byte sequence')) {
        throw Exception(
            'Character encoding error. Please check the text you entered.');
      }
      rethrow;
    }
  }

  // Update data with proper encoding for Arabic text
  Future<dynamic> updateData(
      String tableName, String id, Map<String, dynamic> data,
      {BuildContext? context}) async {
    try {
      // Ensure data is properly encoded for Arabic if the app is in Arabic mode
      if (context != null) {
        final isArabic =
            Provider.of<LanguageProvider>(context, listen: false).isArabic;
        if (isArabic) {
          // Process Arabic text if needed
          data = _processArabicData(data);
        }
      }

      // Explicitly validate permission for profiles updates
      if (tableName == 'profiles') {
        final user = await getCurrentUser();
        if (user == null || (user.id != id && !_isUserAdmin(user))) {
          throw Exception(
              'Permission denied. You can only update your own profile.');
        }
      }

      final response =
          await _client.from(tableName).update(data).eq('id', id).select();
      return response;
    } catch (e) {
      debugPrint('Error updating data: $e');
      // Handle RLS policy errors more gracefully
      if (e.toString().contains('violates row-level security policy')) {
        throw Exception(
            'Permission denied. You may not have the right access to perform this operation.');
      }
      // Handle potential character encoding issues
      if (e.toString().contains('invalid byte sequence')) {
        throw Exception(
            'Character encoding error. Please check the text you entered.');
      }
      rethrow;
    }
  }

  // Check if the user is an admin
  bool _isUserAdmin(User user) {
    final userRole = user.userMetadata?['role'] as String?;
    return userRole == 'admin';
  }

  // Helper method to ensure proper handling of Arabic text
  Map<String, dynamic> _processArabicData(Map<String, dynamic> data) {
    // Make a copy of the data to avoid modifying the original
    final processedData = Map<String, dynamic>.from(data);

    // Process text fields that might contain Arabic
    processedData.forEach((key, value) {
      if (value is String && _containsArabic(value)) {
        // Log for debugging but don't modify the text - Supabase handles UTF-8
        debugPrint('Arabic text detected in field: $key');
      }
    });

    return processedData;
  }

  // Helper method for debugging only - to check if we're handling all Arabic text cases
  bool _containsArabic(String text) {
    // Check for Arabic Unicode range
    final hasArabic = text.contains(RegExp(r'[\u0600-\u06FF]'));
    if (hasArabic) {
      debugPrint('Arabic text detected: $text');
    }
    return hasArabic;
  }

  // Handle non-ASCII characters properly in query filters
  Future<dynamic> queryWithFilter(String tableName, String column, String value,
      {BuildContext? context}) async {
    try {
      // Check if the value contains Arabic characters
      bool containsArabic = _containsArabic(value);

      if (containsArabic) {
        debugPrint('Arabic filter detected for column: $column');
      }

      // Supabase handles UTF-8 correctly, so we can use the value directly
      final response =
          await _client.from(tableName).select().ilike(column, '%$value%');
      return response;
    } catch (e) {
      debugPrint('Error querying with filter: $e');
      rethrow;
    }
  }

  // Enhanced query method specifically for Arabic text searches
  Future<dynamic> arabicTextSearch(
      String tableName, String column, String value) async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .filter(column, 'ilike', '%$value%');

      return response;
    } catch (e) {
      debugPrint('Error in Arabic text search: $e');
      rethrow;
    }
  }

  // Authentication methods
  Future<AuthResponse> signUp(
      {required String email,
      required String password,
      required String role,
      Map<String, dynamic>? userMetadata}) async {
    if (!_isInitialized) {
      throw Exception(
          'Supabase client not initialized. Call initialize() first.');
    }

    try {
      // Prepare metadata with role and any additional fields
      final metadata = {
        'role': role,
        ...?userMetadata, // Merge additional metadata if provided
      };

      // Sign up using Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      return response;
    } catch (e) {
      // Handle error and rethrow with more useful message
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<AuthResponse> signIn(
      {required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      if (e.toString().contains('email_not_confirmed')) {
        throw Exception(
            'Your email is not confirmed. Please check your inbox and confirm your email before logging in.');
      } else {
        // Handle error and rethrow with more useful message
        throw Exception('Login failed: ${e.toString()}');
      }
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // User methods
  Future<User?> getCurrentUser() async {
    return _client.auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      // Get user from auth
      final user = _client.auth.currentUser;

      if (user != null && user.id == userId) {
        // Create a basic profile with data from auth metadata
        final role = user.userMetadata?['role'] as String? ?? 'student';
        final email = user.email ?? '';
        final fullName = user.userMetadata?['full_name'] as String? ?? '';
        final phone = user.userMetadata?['phone'] as String? ?? '';

        // Try to fetch profile data from the profiles table
        try {
          // First check if user exists directly with a simple query
          final List<dynamic> response = await _client
              .from(AppConstants.profilesCollection)
              .select('id')
              .eq('id', userId)
              .limit(1);

          if (response.isNotEmpty) {
            // User exists, fetch full profile
            final profileData = await _client
                .from(AppConstants.profilesCollection)
                .select('*')
                .eq('id', userId)
                .single();

            // Merge auth data with profile data for consistent access
            return {
              'id': userId,
              'email': email,
              'role': role, // From auth for consistent role usage in the app
              'user_role':
                  profileData['user_role'] ?? role, // From profile table
              'full_name': profileData['full_name'] ?? fullName,
              'phone': profileData['phone'] ?? phone,
              'avatar_url':
                  profileData['avatar_url'] ?? user.userMetadata?['avatar_url'],
              'created_at': profileData['created_at'],
              'updated_at': profileData['updated_at'],
              // Include all additional fields
              'student_id': profileData['student_id'],
              'room_number': profileData['room_number'],
              'program': profileData['program'],
              'employee_id': profileData['employee_id'],
              'department': profileData['department'],
              'specialty': profileData['specialty'],
              'position': profileData['position'],
              'building_assigned': profileData['building_assigned'],
              'dining_hall': profileData['dining_hall'],
              'graduation_year': profileData['graduation_year'],
              'enrollment_date': profileData['enrollment_date'],
              'hire_date': profileData['hire_date'],
              'shift_hours': profileData['shift_hours'],
              'access_level': profileData['access_level'],
            };
          }

          // Profile doesn't exist, create one
          final Map<String, dynamic> newProfile = {
            'id': userId,
            'email': email,
            'user_role': role,
            'full_name': fullName,
            'phone': phone,
            'created_at': DateTime.now().toIso8601String(),
          };

          // Add role-specific fields from auth metadata if available
          if (role == AppConstants.roleStudent) {
            newProfile['student_id'] = user.userMetadata?['student_id'];
            newProfile['room_number'] = user.userMetadata?['room_number'];
            newProfile['program'] = user.userMetadata?['program'];
          } else if (role == AppConstants.roleSupervisor ||
              role == AppConstants.roleAdmin ||
              role == AppConstants.roleLabor) {
            newProfile['employee_id'] = user.userMetadata?['employee_id'];
            newProfile['department'] = user.userMetadata?['department'];
          }

          // Insert the new profile
          await _client
              .from(AppConstants.profilesCollection)
              .insert(newProfile);

          // Return the newly created profile data
          return {
            'id': userId,
            'email': email,
            'role': role,
            'user_role': role,
            'full_name': fullName,
            'phone': phone,
            'created_at': DateTime.now().toIso8601String(),
            // Other fields will be null until set
          };
        } catch (dbError) {
          debugPrint('Error accessing profiles table: $dbError');

          // Return basic user info from auth as fallback
          return {
            'id': userId,
            'email': email,
            'role': role,
            'full_name': fullName,
            'phone': phone,
            'created_at': DateTime.now().toIso8601String(),
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');

      // If there's an error, try to get basic user info from auth as fallback
      final user = _client.auth.currentUser;
      if (user != null && user.id == userId) {
        final role = user.userMetadata?['role'] as String? ?? 'student';
        final email = user.email ?? '';
        final fullName = user.userMetadata?['full_name'] as String? ?? '';
        final phone = user.userMetadata?['phone'] as String? ?? '';

        return {
          'id': userId,
          'email': email,
          'role': role,
          'full_name': fullName,
          'phone': phone,
          'created_at': DateTime.now().toIso8601String(),
        };
      }
      return null;
    }
  }

  // Update method to handle our new table structure
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> profileData) async {
    try {
      // Remove any fields that don't exist in the profiles table
      final Map<String, dynamic> validProfileData = {};
      for (final key in profileData.keys) {
        // Check if this is a valid column before including it
        if ([
          'id',
          'email',
          'full_name',
          'avatar_url',
          'user_role',
          'phone',
          'student_id',
          'room_number',
          'program',
          'employee_id',
          'department',
          'specialty',
          'position',
          'building_assigned',
          'dining_hall',
          'graduation_year',
          'enrollment_date',
          'hire_date',
          'shift_hours',
          'access_level'
        ].contains(key)) {
          validProfileData[key] = profileData[key];
        }
      }

      // Always include the updated_at timestamp
      validProfileData['updated_at'] = DateTime.now().toIso8601String();

      // Update profile in the database
      await _client
          .from(AppConstants.profilesCollection)
          .update(validProfileData)
          .eq('id', userId);

      // Update metadata in auth if needed
      final currentUser = _client.auth.currentUser;
      if (currentUser != null && currentUser.id == userId) {
        final Map<String, dynamic> metadata =
            Map.from(currentUser.userMetadata ?? {});

        // Update common metadata fields
        if (profileData.containsKey('full_name')) {
          metadata['full_name'] = profileData['full_name'];
        }
        if (profileData.containsKey('phone')) {
          metadata['phone'] = profileData['phone'];
        }
        if (profileData.containsKey('avatar_url')) {
          metadata['avatar_url'] = profileData['avatar_url'];
        }

        // Only update if there are changes
        if (metadata.isNotEmpty) {
          await _client.auth.updateUser(UserAttributes(
            data: metadata,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Request methods
  Future<List<Map<String, dynamic>>> getRequests(
      {String? userId, String? status}) async {
    var query = _client.from(AppConstants.requestsCollection).select();

    if (userId != null) {
      query = query.eq('user_id', userId);
    }

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createRequest({
    required String userId,
    required String type,
    required String status,
    required Map<String, dynamic> details,
  }) async {
    await _client.from(AppConstants.requestsCollection).insert({
      'user_id': userId,
      'type': type,
      'status': status,
      'details': details,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? supervisorId,
    String? notes,
  }) async {
    final Map<String, dynamic> data = {
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (supervisorId != null) {
      data['supervisor_id'] = supervisorId;
    }

    if (notes != null) {
      data['notes'] = notes;
    }

    await _client
        .from(AppConstants.requestsCollection)
        .update(data)
        .eq('id', requestId);
  }

  // QR Code methods
  Future<String> createQRCode({
    required String type,
    required String createdBy,
    required DateTime validUntil,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _client.from(AppConstants.qrCodesCollection).insert({
      'type': type,
      'created_by': createdBy,
      'valid_until': validUntil.toIso8601String(),
      'metadata': metadata,
      'created_at': DateTime.now().toIso8601String(),
    }).select('id');

    return response[0]['id'];
  }

  Future<Map<String, dynamic>?> validateQRCode(String qrCodeId) async {
    final now = DateTime.now().toIso8601String();

    try {
      final response = await _client
          .from(AppConstants.qrCodesCollection)
          .select()
          .eq('id', qrCodeId)
          .gt('valid_until', now)
          .single();

      return response;
    } catch (e) {
      return null; // Invalid or expired QR code
    }
  }

  // Attendance methods
  Future<void> markAttendance({
    required String userId,
    required String qrCodeId,
  }) async {
    await _client.from(AppConstants.attendanceCollection).insert({
      'user_id': userId,
      'qr_code_id': qrCodeId,
      'marked_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAttendance({
    String? userId,
    DateTime? date,
  }) async {
    var query = _client.from(AppConstants.attendanceCollection).select();

    if (userId != null) {
      query = query.eq('user_id', userId);
    }

    if (date != null) {
      final startOfDay =
          DateTime(date.year, date.month, date.day).toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59)
          .toIso8601String();

      query = query.gte('marked_at', startOfDay).lte('marked_at', endOfDay);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // Payment methods
  Future<void> recordPayment({
    required String userId,
    required double amount,
    required String description,
    required String status,
  }) async {
    await _client.from(AppConstants.paymentsCollection).insert({
      'user_id': userId,
      'amount': amount,
      'description': description,
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Cleaning request methods
  Future<void> createCleaningRequest({
    required String laborId,
    required String description,
    required String location,
    String? priority,
  }) async {
    await _client.from(AppConstants.cleaningRequestsCollection).insert({
      'labor_id': laborId,
      'description': description,
      'location': location,
      'priority': priority ?? 'medium',
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Add method to resend verification email
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw Exception('Failed to resend verification email: ${e.toString()}');
    }
  }
}
