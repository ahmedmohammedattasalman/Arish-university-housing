import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/config/constants.dart';

class NotificationProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  // Notification lists
  List<UserNotification> _notifications = [];
  List<UserNotification> _unreadNotifications = [];

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserNotification> get notifications => _notifications;
  List<UserNotification> get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadNotifications.length;

  // Get notifications for a specific user
  Future<void> fetchUserNotifications(String userId) async {
    _setLoading(true);

    try {
      final response = await _supabaseService.client
          .from(AppConstants.notificationsCollection)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _notifications = response
          .map<UserNotification>((data) => UserNotification.fromJson(data))
          .toList();
      _filterUnreadNotifications();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch notifications: ${e.toString()}');
    }
  }

  // Create a new notification
  Future<UserNotification?> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    _setLoading(true);

    try {
      final notificationData = {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      if (relatedId != null) {
        notificationData['related_id'] = relatedId;
      }

      if (data != null) {
        notificationData['data'] = data;
      }

      final response = await _supabaseService.client
          .from(AppConstants.notificationsCollection)
          .insert(notificationData)
          .select()
          .single();

      final newNotification = UserNotification.fromJson(response);

      // Add to notifications list
      _notifications.insert(0, newNotification);
      _filterUnreadNotifications();
      notifyListeners();

      _setLoading(false);
      return newNotification;
    } catch (e) {
      _setError('Failed to create notification: ${e.toString()}');
      return null;
    }
  }

  // Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabaseService.client
          .from(AppConstants.notificationsCollection)
          .update({'is_read': true}).eq('id', notificationId);

      // Update local notification list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        final updatedNotification =
            _notifications[index].copyWith(isRead: true);
        _notifications[index] = updatedNotification;
        _filterUnreadNotifications();
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to mark notification as read: ${e.toString()}');
      return false;
    }
  }

  // Mark all notifications as read for a user
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _supabaseService.client
          .from(AppConstants.notificationsCollection)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      // Update local notification list
      _notifications = _notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();

      _unreadNotifications = [];
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to mark all notifications as read: ${e.toString()}');
      return false;
    }
  }

  // Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabaseService.client
          .from(AppConstants.notificationsCollection)
          .delete()
          .eq('id', notificationId);

      // Remove from local lists
      _notifications
          .removeWhere((notification) => notification.id == notificationId);
      _filterUnreadNotifications();
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to delete notification: ${e.toString()}');
      return false;
    }
  }

  // Setup real-time updates for notifications
  void setupNotificationsSubscription(String userId) {
    _supabaseService.client
        .channel('public:${AppConstants.notificationsCollection}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.notificationsCollection,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            _handleRealtimeUpdate(payload);
          },
        )
        .subscribe();
  }

  // Handle real-time updates
  void _handleRealtimeUpdate(PostgresChangePayload payload) {
    final eventType = payload.eventType;
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;

    if (newRecord != null) {
      final notification = UserNotification.fromJson(newRecord);

      if (eventType == PostgresChangeEvent.insert) {
        // Add new notification
        _notifications.insert(0, notification);
        if (!notification.isRead) {
          _unreadNotifications.insert(0, notification);
        }
      } else if (eventType == PostgresChangeEvent.update) {
        // Update existing notification
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index >= 0) {
          _notifications[index] = notification;
        }
        _filterUnreadNotifications();
      } else if (eventType == PostgresChangeEvent.delete && oldRecord != null) {
        // Remove deleted notification
        _notifications.removeWhere((n) => n.id == oldRecord['id'] as String);
        _filterUnreadNotifications();
      }

      notifyListeners();
    }
  }

  // Helper method to filter unread notifications
  void _filterUnreadNotifications() {
    _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  // Helper method to set error
  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
