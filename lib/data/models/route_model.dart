import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final String id;
  final int distanceMeters;
  final int durationSeconds;
  final List<LatLng> polylinePoints;
  final LatLng startLocation;
  final LatLng endLocation;
  final String routeName;

  const RouteModel({
    required this.id,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polylinePoints,
    required this.startLocation,
    required this.endLocation,
    required this.routeName,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    // Note: Parsing encoded polylines usually happens via flutter_polyline_points
    // But since we are creating strongly typed models and a backend service, we assume
    // the backend will send decoded points or we parse them here if we add that package.
    // For now, we assume points are a list of {lat, lng} from the server if any.
    final rawPoints = json['polylinePoints'] as List<dynamic>? ?? [];
    final parsedPoints = rawPoints.map((p) => LatLng(
      (p['lat'] as num).toDouble(),
      (p['lng'] as num).toDouble()
    )).toList();

    return RouteModel(
      id: json['id'] as String? ?? 'unknown_route',
      distanceMeters: json['distanceMeters'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      polylinePoints: parsedPoints,
      startLocation: LatLng(
        (json['startLocation']?['lat'] as num?)?.toDouble() ?? 0.0,
        (json['startLocation']?['lng'] as num?)?.toDouble() ?? 0.0,
      ),
      endLocation: LatLng(
        (json['endLocation']?['lat'] as num?)?.toDouble() ?? 0.0,
        (json['endLocation']?['lng'] as num?)?.toDouble() ?? 0.0,
      ),
      routeName: json['routeName'] as String? ?? 'Unnamed Route',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
      'routeName': routeName,
      'polylinePoints': polylinePoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'startLocation': {'lat': startLocation.latitude, 'lng': startLocation.longitude},
      'endLocation': {'lat': endLocation.latitude, 'lng': endLocation.longitude},
    };
  }
}
