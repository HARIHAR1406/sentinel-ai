class TripModel {
  final String id;
  final String userId;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final String status;
  final DateTime startTime;
  final DateTime expectedEndTime;

  const TripModel({
    required this.id,
    required this.userId,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.status,
    required this.startTime,
    required this.expectedEndTime,
  });
}
