import '../../shared/widgets/risk_chip.dart';

class AlertModel {
  final String id;
  final String incidentId;
  final String title;
  final String description;
  final RiskLevel level;
  final int distanceMeters;
  final DateTime timestamp;
  final bool isRead;

  const AlertModel({
    required this.id,
    required this.incidentId,
    required this.title,
    required this.description,
    required this.level,
    required this.distanceMeters,
    required this.timestamp,
    this.isRead = false,
  });

  AlertModel copyWith({
    String? id,
    String? incidentId,
    String? title,
    String? description,
    RiskLevel? level,
    int? distanceMeters,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AlertModel(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
