class AlertModel {
  final String id;
  final String targetUserId;
  final String title;
  final String description;
  final String level;
  final DateTime timestamp;
  final bool readStatus;

  const AlertModel({
    required this.id,
    required this.targetUserId,
    required this.title,
    required this.description,
    required this.level,
    required this.timestamp,
    required this.readStatus,
  });
}
