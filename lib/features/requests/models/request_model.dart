import 'dart:convert';

/// Enum for request types
enum RequestType {
  vacation,
  eviction,
  maintenance,
  other;

  static RequestType fromString(String value) {
    return RequestType.values.firstWhere(
      (e) => e.toString().split('.').last == value.toLowerCase(),
      orElse: () => RequestType.other,
    );
  }

  String get displayName {
    switch (this) {
      case RequestType.vacation:
        return 'Vacation';
      case RequestType.eviction:
        return 'Eviction';
      case RequestType.maintenance:
        return 'Maintenance';
      case RequestType.other:
        return 'Other';
    }
  }
}

/// Enum for request status
enum RequestStatus {
  pending,
  approved,
  rejected,
  canceled;

  static RequestStatus fromString(String value) {
    return RequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value.toLowerCase(),
      orElse: () => RequestStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.canceled:
        return 'Canceled';
    }
  }
}

/// Model representing a request in the system
class Request {
  final String id;
  final String userId;
  final RequestType type;
  final RequestStatus status;
  final Map<String, dynamic> details;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? supervisorId;
  final String? notes;

  Request({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.details,
    required this.createdAt,
    this.updatedAt,
    this.supervisorId,
    this.notes,
  });

  /// Create a Request from a JSON map
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      userId: json['user_id'],
      type: RequestType.fromString(json['type']),
      status: RequestStatus.fromString(json['status']),
      details: json['details'] is String
          ? jsonDecode(json['details'])
          : json['details'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      supervisorId: json['supervisor_id'],
      notes: json['notes'],
    );
  }

  /// Convert Request to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'details': details is String ? details : jsonEncode(details),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'supervisor_id': supervisorId,
      'notes': notes,
    };
  }

  /// Create a copy of the Request with updated fields
  Request copyWith({
    String? id,
    String? userId,
    RequestType? type,
    RequestStatus? status,
    Map<String, dynamic>? details,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? supervisorId,
    String? notes,
  }) {
    return Request(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      supervisorId: supervisorId ?? this.supervisorId,
      notes: notes ?? this.notes,
    );
  }

  /// Get a specific detail value with type safety
  T? getDetail<T>(String key) {
    if (details.containsKey(key)) {
      final value = details[key];
      if (value is T) {
        return value;
      }
    }
    return null;
  }

  /// Get formatted creation date
  String get formattedCreatedDate {
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
  }

  /// Get request duration in days (for vacation requests)
  int? get durationDays {
    if (type == RequestType.vacation) {
      final startDate = getDetail<String>('start_date');
      final endDate = getDetail<String>('end_date');

      if (startDate != null && endDate != null) {
        final start = DateTime.parse(startDate);
        final end = DateTime.parse(endDate);
        return end.difference(start).inDays +
            1; // Include both start and end days
      }
    }
    return null;
  }
}
