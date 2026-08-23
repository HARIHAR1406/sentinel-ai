import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  incidentAlert,
  systemMessage,
  unknown,
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

class NotificationModel {
  final String id;
  final String userId;
  final String? incidentId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool read;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.incidentId,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.createdAt,
    required this.read,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'incidentId': incidentId,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': read,
    };
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      incidentId: data['incidentId'] as String?,
      title: data['title'] as String? ?? 'Notification',
      body: data['body'] as String? ?? '',
      type: _parseType(data['type'] as String?),
      priority: _parsePriority(data['priority'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }

  static NotificationType _parseType(String? value) {
    if (value == null) return NotificationType.unknown;
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.unknown,
    );
  }

  static NotificationPriority _parsePriority(String? value) {
    if (value == null) return NotificationPriority.low;
    return NotificationPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationPriority.low,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? incidentId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    bool? read,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      incidentId: incidentId ?? this.incidentId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}
