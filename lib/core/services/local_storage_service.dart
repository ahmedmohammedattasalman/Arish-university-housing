import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _isAuthenticatedKey = 'is_authenticated';

  // Initialize for web if needed
  static Future<void> initialize() async {
    // No special initialization needed currently,
    // but this method is available for future web-specific setup
  }

  // Save user profile data to local storage
  static Future<bool> saveUserProfile(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedData = jsonEncode(userData);
      final result = await prefs.setString(_userProfileKey, encodedData);
      debugPrint('User profile saved: ${result ? "success" : "failed"}');
      return result;
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    }
  }

  // Get user profile data from local storage
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userProfileKey);

      if (userDataString != null && userDataString.isNotEmpty) {
        try {
          final Map<String, dynamic> data =
              jsonDecode(userDataString) as Map<String, dynamic>;
          return data;
        } catch (parseError) {
          debugPrint('Error parsing user profile JSON: $parseError');
          // Clear corrupted data
          await prefs.remove(_userProfileKey);
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Clear user profile data from local storage
  static Future<bool> clearUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.remove(_userProfileKey);
      debugPrint('User profile cleared: ${result ? "success" : "failed"}');
      return result;
    } catch (e) {
      debugPrint('Error clearing user profile: $e');
      // Don't rethrow - consider it cleared even if there's an error
      return true; // Return true anyway to indicate to caller that they can proceed
    }
  }

  // Save user's auth state
  static Future<bool> saveAuthState({
    required String userId,
    required String email,
    required String role,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Use a transaction-like approach to ensure all values are saved
      bool success = true;
      success = success && await prefs.setString(_userIdKey, userId);
      success = success && await prefs.setString(_userEmailKey, email);
      success = success && await prefs.setString(_userRoleKey, role);
      success = success && await prefs.setBool(_isAuthenticatedKey, true);

      // Log result for debugging
      debugPrint('Auth state saved: ${success ? "success" : "failed"}');

      // Save a timestamp of when auth was saved
      if (success) {
        await prefs.setInt(
            'auth_timestamp', DateTime.now().millisecondsSinceEpoch);
      }

      return success;
    } catch (e) {
      debugPrint('Error saving auth state: $e');
      return false;
    }
  }

  // Get user's auth state
  static Future<Map<String, dynamic>?> getAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool(_isAuthenticatedKey) ?? false;

      if (!isAuthenticated) {
        return null;
      }

      final userId = prefs.getString(_userIdKey);
      final userEmail = prefs.getString(_userEmailKey);
      final userRole = prefs.getString(_userRoleKey);

      // Validate that we have the minimum required data
      if (userId == null ||
          userId.isEmpty ||
          userRole == null ||
          userRole.isEmpty) {
        debugPrint('Auth state is inconsistent, missing required fields');
        return null;
      }

      return {
        'user_id': userId,
        'user_email': userEmail ?? '',
        'user_role': userRole,
        'is_authenticated': isAuthenticated,
        'timestamp': prefs.getInt('auth_timestamp') ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting auth state: $e');
      return null;
    }
  }

  // Clear user's auth state
  static Future<bool> clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove all auth-related keys
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userRoleKey);
      final result = await prefs.setBool(_isAuthenticatedKey, false);

      debugPrint('Auth state cleared: ${result ? "success" : "failed"}');
      return result;
    } catch (e) {
      debugPrint('Error clearing auth state: $e');
      // Don't rethrow - consider it cleared even if there's an error
      return true; // Return true anyway to indicate to caller that they can proceed
    }
  }
}
