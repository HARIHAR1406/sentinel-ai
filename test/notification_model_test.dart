import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sentinel_ai/data/models/notification_model.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  final String _id;

  MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => true;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  DocumentReference<Map<String, dynamic>> get reference => throw UnimplementedError();

  @override
  dynamic get(Object field) => _data[field];
  
  @override
  dynamic operator [](Object field) => _data[field];
}

void main() {
  group('NotificationModel JSON Parsing', () {
    test('successfully parses valid map', () {
      final now = DateTime.now();
      final map = {
        'userId': 'user123',
        'incidentId': 'inc456',
        'title': 'Test Alert',
        'body': 'This is a test notification.',
        'type': 'incidentAlert',
        'priority': 'high',
        'createdAt': Timestamp.fromDate(now),
        'read': false,
      };

      final doc = MockDocumentSnapshot('notif_1', map);
      final model = NotificationModel.fromFirestore(doc);

      expect(model.id, 'notif_1');
      expect(model.userId, 'user123');
      expect(model.incidentId, 'inc456');
      expect(model.title, 'Test Alert');
      expect(model.body, 'This is a test notification.');
      expect(model.type, NotificationType.incidentAlert);
      expect(model.priority, NotificationPriority.high);
      expect(model.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(model.read, false);
    });

    test('handles missing fields safely with defaults', () {
      final map = <String, dynamic>{};
      final doc = MockDocumentSnapshot('notif_2', map);
      final model = NotificationModel.fromFirestore(doc);

      expect(model.id, 'notif_2');
      expect(model.userId, '');
      expect(model.incidentId, null);
      expect(model.title, 'Notification');
      expect(model.body, '');
      expect(model.type, NotificationType.unknown);
      expect(model.priority, NotificationPriority.low);
      expect(model.read, false);
    });

    test('normalizes type enum correctly', () {
      final map = {
        'type': 'systemMessage',
      };
      final doc = MockDocumentSnapshot('notif_3', map);
      final model = NotificationModel.fromFirestore(doc);

      expect(model.type, NotificationType.systemMessage);
    });

    test('normalizes unknown priority to low', () {
      final map = {
        'priority': 'superExtreme', // Invalid priority
      };
      final doc = MockDocumentSnapshot('notif_4', map);
      final model = NotificationModel.fromFirestore(doc);

      expect(model.priority, NotificationPriority.low);
    });

    test('toFirestore serializes correctly', () {
      final now = DateTime.now();
      final model = NotificationModel(
        id: 'notif_5',
        userId: 'u1',
        incidentId: 'i1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.systemMessage,
        priority: NotificationPriority.critical,
        createdAt: now,
        read: true,
      );

      final map = model.toFirestore();
      expect(map['userId'], 'u1');
      expect(map['incidentId'], 'i1');
      expect(map['title'], 'Title');
      expect(map['body'], 'Body');
      expect(map['type'], 'systemMessage');
      expect(map['priority'], 'critical');
      expect((map['createdAt'] as Timestamp).toDate(), now);
      expect(map['read'], true);
    });
  });
}
