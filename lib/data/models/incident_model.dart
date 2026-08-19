class IncidentModel {
  final String id;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final String reportedBy;
  final String severity;
  final String status;
  final DateTime timestamp;

  const IncidentModel({
    required this.id,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.reportedBy,
    required this.severity,
    required this.status,
    required this.timestamp,
  });

  // TODO(Phase 7.x): Serialization methods
}
