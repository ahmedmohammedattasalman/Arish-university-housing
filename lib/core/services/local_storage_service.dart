import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userProfileKey = 'user_profile';

  // Save user profile data to local storage
  static Future<bool> saveUserProfile(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userProfileKey, jsonEncode(userData));
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

      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
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
      return await prefs.remove(_userProfileKey);
    } catch (e) {
      debugPrint('Error clearing user profile: $e');
      return false;
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
      await prefs.setString('user_id', userId);
      await prefs.setString('user_email', email);
      await prefs.setString('user_role', role);
      await prefs.setBool('is_authenticated', true);
      return true;
    } catch (e) {
      debugPrint('Error saving auth state: $e');
      return false;
    }
  }

  // Get user's auth state
  static Future<Map<String, dynamic>?> getAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;

      if (!isAuthenticated) {
        return null;
      }

      return {
        'user_id': prefs.getString('user_id'),
        'user_email': prefs.getString('user_email'),
        'user_role': prefs.getString('user_role'),
        'is_authenticated': isAuthenticated,
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
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_role');
      await prefs.setBool('is_authenticated', false);
      return true;
    } catch (e) {
      debugPrint('Error clearing auth state: $e');
      return false;
    }
  }
}
