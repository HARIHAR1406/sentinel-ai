import '../models/notification_model.dart';

abstract class NotificationService {
  /// Saves a device token for the currently authenticated user
  Future<void> saveDeviceToken(String token, String platform);

  /// Retrieves a stream of notifications for the current user
  Stream<List<NotificationModel>> getNotificationsStream({bool unreadOnly = false});

  /// Retrieves the unread notification count
  Stream<int> getUnreadCountStream();

  /// Marks a specific notification as read
  Future<void> markAsRead(String notificationId);

  /// Updates notification preferences for the user
  Future<void> updatePreferences(bool incidentAlertsEnabled, bool highRiskAlertsEnabled);
}
