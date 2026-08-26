import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'route_model.dart';
import 'route_risk_result.dart';

enum TripStatus { idle, active, completed, error }

class TripModel {
  final String id;
  final LatLng? origin;
  final LatLng? destination;
  final RouteModel? selectedRoute;
  final RouteRiskResult? riskResult;
  final LatLng? currentLocation;
  final TripStatus status;
  final DateTime? startTime;
  final DateTime? expectedEndTime;
  final bool isDeviated;
  final double distanceRemainingMeters;

  const TripModel({
    required this.id,
    this.origin,
    this.destination,
    this.selectedRoute,
    this.riskResult,
    this.currentLocation,
    this.status = TripStatus.idle,
    this.startTime,
    this.expectedEndTime,
    this.isDeviated = false,
    this.distanceRemainingMeters = 0.0,
  });

  TripModel copyWith({
    String? id,
    LatLng? origin,
    LatLng? destination,
    RouteModel? selectedRoute,
    RouteRiskResult? riskResult,
    LatLng? currentLocation,
    TripStatus? status,
    DateTime? startTime,
    DateTime? expectedEndTime,
    bool? isDeviated,
    double? distanceRemainingMeters,
  }) {
    return TripModel(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      riskResult: riskResult ?? this.riskResult,
      currentLocation: currentLocation ?? this.currentLocation,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      expectedEndTime: expectedEndTime ?? this.expectedEndTime,
      isDeviated: isDeviated ?? this.isDeviated,
      distanceRemainingMeters: distanceRemainingMeters ?? this.distanceRemainingMeters,
    );
  }
}
