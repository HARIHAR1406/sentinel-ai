import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';
import '../models/notification_model.dart';
import '../models/device_token_model.dart';

/// Provider for the NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return FirestoreNotificationService();
});

/// Provider for watching all notifications
final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotificationsStream();
});

/// Provider for watching unread count
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadCountStream();
});

class FirestoreNotificationService implements NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<void> saveDeviceToken(String token, String platform) async {
    final uid = _uid;
    if (uid == null) return;

    final tokenRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('device_tokens')
        .doc(token); // Use token string as ID or a hash

    final model = DeviceTokenModel(
      token: token,
      platform: platform,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      enabled: true,
    );

    // Use set with merge to update updatedAt without overwriting createdAt if it exists
    await tokenRef.set(model.toFirestore(), SetOptions(merge: true));
  }

  @override
  Stream<List<NotificationModel>> getNotificationsStream({bool unreadOnly = false}) {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    if (unreadOnly) {
      query = query.where('read', isEqualTo: false);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<int> getUnreadCountStream() {
    final uid = _uid;
    if (uid == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final uid = _uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  @override
  Future<void> updatePreferences(bool incidentAlertsEnabled, bool highRiskAlertsEnabled) async {
    final uid = _uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      'preferences': {
        'incidentAlertsEnabled': incidentAlertsEnabled,
        'highRiskAlertsEnabled': highRiskAlertsEnabled,
      }
    }, SetOptions(merge: true));
  }
}
