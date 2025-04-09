import 'dart:convert';

/// Enum for notification types
enum NotificationType {
  requestUpdate,
  announcement,
  payment,
  maintenance,
  reminder,
  other;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == value.toLowerCase(),
      orElse: () => NotificationType.other,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationType.requestUpdate:
        return 'Request Update';
      case NotificationType.announcement:
        return 'Announcement';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.maintenance:
        return 'Maintenance';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.other:
        return 'Other';
    }
  }
}

/// Model representing a notification in the system
class UserNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String?
      relatedId; // ID of the related content (request, announcement, etc.)
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>?
      data; // Additional data specific to notification type

  UserNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.relatedId,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  // Create a notification from a JSON object
  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      relatedId: json['related_id'] as String?,
      type: NotificationType.fromString(json['type'] as String),
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      data: json['data'] != null
          ? (json['data'] is String
              ? jsonDecode(json['data'] as String) as Map<String, dynamic>
              : json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  // Convert notification to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'related_id': relatedId,
      'type': type.toString().split('.').last,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'data': data != null ? jsonEncode(data) : null,
    };
  }

  // Create a copy of this notification with new values
  UserNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? relatedId,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return UserNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedId: relatedId ?? this.relatedId,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}
