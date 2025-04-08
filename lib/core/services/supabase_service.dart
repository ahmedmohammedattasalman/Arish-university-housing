import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../config/constants.dart';

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

  // Authentication methods
  Future<AuthResponse> signUp(
      {required String email,
      required String password,
      required String role}) async {
    if (!_isInitialized) {
      throw Exception(
          'Supabase client not initialized. Call initialize() first.');
    }

    try {
      // Sign up using Supabase Auth without autoConfirm
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'role': role},
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
      // First check if the table exists and if the user exists in it
      final response = await _client
          .from(AppConstants.usersCollection)
          .select('id')
          .eq('id', userId);

      // If the user doesn't exist in the database, return a basic profile with role
      if (response.isEmpty) {
        // Get user metadata from auth
        final user = _client.auth.currentUser;
        if (user != null && user.id == userId) {
          // Create a basic profile with data from auth metadata
          final role = user.userMetadata?['role'] as String? ?? 'student';

          try {
            // Try to create the user profile
            await _client.from(AppConstants.usersCollection).insert({
              'id': userId,
              'email': user.email,
              'role': role,
              'created_at': DateTime.now().toIso8601String(),
            });

            // Return the newly created profile
            return {
              'id': userId,
              'email': user.email,
              'role': role,
              'created_at': DateTime.now().toIso8601String(),
            };
          } catch (e) {
            debugPrint('Error creating user profile: $e');
            // Still return basic info even if creation fails
            return {
              'id': userId,
              'email': user.email ?? '',
              'role': role,
            };
          }
        }
        return null;
      }

      // If the user exists, get their full profile
      final userProfile = await _client
          .from(AppConstants.usersCollection)
          .select()
          .eq('id', userId)
          .single();

      return userProfile;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');

      // If there's an error, try to get basic user info from auth as fallback
      final user = _client.auth.currentUser;
      if (user != null && user.id == userId) {
        return {
          'id': userId,
          'email': user.email ?? '',
          'role': user.userMetadata?['role'] as String? ?? 'student',
        };
      }
      return null;
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
