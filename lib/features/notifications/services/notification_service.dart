import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/config/constants.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

/// Service class to handle creating notifications for various app events
class NotificationService {
  final SupabaseService _supabaseService = SupabaseService();
  final NotificationProvider? _notificationProvider;

  NotificationService({NotificationProvider? notificationProvider})
      : _notificationProvider = notificationProvider;

  /// Create a notification for request status updates
  Future<UserNotification?> createRequestStatusNotification({
    required String userId,
    required String requestId,
    required String requestType,
    required String newStatus,
    String? supervisorName,
    String? notes,
  }) async {
    try {
      final title = 'Request Status Updated';
      final message = _buildRequestStatusMessage(
        requestType: requestType,
        newStatus: newStatus,
        supervisorName: supervisorName,
        notes: notes,
      );

      final data = {
        'request_id': requestId,
        'request_type': requestType,
        'new_status': newStatus,
        'supervisor_name': supervisorName,
        'notes': notes,
      };

      // If provider is available, use it (in-app)
      if (_notificationProvider != null) {
        return await _notificationProvider!.createNotification(
          userId: userId,
          title: title,
          message: message,
          type: NotificationType.requestUpdate,
          relatedId: requestId,
          data: data,
        );
      }
      // Otherwise, create directly (background)
      else {
        final notificationData = {
          'user_id': userId,
          'title': title,
          'message': message,
          'type': NotificationType.requestUpdate.toString().split('.').last,
          'related_id': requestId,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
          'data': data,
        };

        final response = await _supabaseService.client
            .from(AppConstants.notificationsCollection)
            .insert(notificationData)
            .select()
            .single();

        return UserNotification.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error creating request status notification: $e');
      return null;
    }
  }

  /// Create a general announcement notification for multiple users
  Future<List<UserNotification>> createAnnouncementNotification({
    required List<String> userIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final results = <UserNotification>[];

    try {
      // Create notification entries for each user
      final notificationsData = userIds
          .map((userId) => {
                'user_id': userId,
                'title': title,
                'message': message,
                'type':
                    NotificationType.announcement.toString().split('.').last,
                'is_read': false,
                'created_at': DateTime.now().toIso8601String(),
                'data': data,
              })
          .toList();

      // Batch insert notifications
      final response = await _supabaseService.client
          .from(AppConstants.notificationsCollection)
          .insert(notificationsData)
          .select();

      // Parse response
      for (final item in response) {
        results.add(UserNotification.fromJson(item));
      }

      return results;
    } catch (e) {
      debugPrint('Error creating announcement notifications: $e');
      return results;
    }
  }

  /// Create a maintenance notification
  Future<UserNotification?> createMaintenanceNotification({
    required String userId,
    required String title,
    required String message,
    String? maintenanceId,
    Map<String, dynamic>? data,
  }) async {
    try {
      // If provider is available, use it
      if (_notificationProvider != null) {
        return await _notificationProvider!.createNotification(
          userId: userId,
          title: title,
          message: message,
          type: NotificationType.maintenance,
          relatedId: maintenanceId,
          data: data,
        );
      }
      // Otherwise, create directly
      else {
        final notificationData = {
          'user_id': userId,
          'title': title,
          'message': message,
          'type': NotificationType.maintenance.toString().split('.').last,
          'related_id': maintenanceId,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
          'data': data,
        };

        final response = await _supabaseService.client
            .from(AppConstants.notificationsCollection)
            .insert(notificationData)
            .select()
            .single();

        return UserNotification.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error creating maintenance notification: $e');
      return null;
    }
  }

  /// Create a payment reminder notification
  Future<UserNotification?> createPaymentNotification({
    required String userId,
    required String title,
    required String message,
    String? paymentId,
    Map<String, dynamic>? data,
  }) async {
    try {
      // If provider is available, use it
      if (_notificationProvider != null) {
        return await _notificationProvider!.createNotification(
          userId: userId,
          title: title,
          message: message,
          type: NotificationType.payment,
          relatedId: paymentId,
          data: data,
        );
      }
      // Otherwise, create directly
      else {
        final notificationData = {
          'user_id': userId,
          'title': title,
          'message': message,
          'type': NotificationType.payment.toString().split('.').last,
          'related_id': paymentId,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
          'data': data,
        };

        final response = await _supabaseService.client
            .from(AppConstants.notificationsCollection)
            .insert(notificationData)
            .select()
            .single();

        return UserNotification.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error creating payment notification: $e');
      return null;
    }
  }

  /// Create a general reminder notification
  Future<UserNotification?> createReminderNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      // If provider is available, use it
      if (_notificationProvider != null) {
        return await _notificationProvider!.createNotification(
          userId: userId,
          title: title,
          message: message,
          type: NotificationType.reminder,
          data: data,
        );
      }
      // Otherwise, create directly
      else {
        final notificationData = {
          'user_id': userId,
          'title': title,
          'message': message,
          'type': NotificationType.reminder.toString().split('.').last,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
          'data': data,
        };

        final response = await _supabaseService.client
            .from(AppConstants.notificationsCollection)
            .insert(notificationData)
            .select()
            .single();

        return UserNotification.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error creating reminder notification: $e');
      return null;
    }
  }

  // Helper method to build request status message
  String _buildRequestStatusMessage({
    required String requestType,
    required String newStatus,
    String? supervisorName,
    String? notes,
  }) {
    final baseMessage =
        'Your $requestType request status has been updated to $newStatus';

    if (supervisorName != null) {
      if (notes != null && notes.isNotEmpty) {
        return '$baseMessage by $supervisorName with note: "$notes"';
      }
      return '$baseMessage by $supervisorName';
    }

    if (notes != null && notes.isNotEmpty) {
      return '$baseMessage with note: "$notes"';
    }

    return baseMessage;
  }
}
