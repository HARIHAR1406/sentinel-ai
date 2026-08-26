import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/trip_model.dart';
import '../models/route_risk_result.dart';
import 'location_service.dart';
import '../../core/utils/geo_utils.dart';

class TripSafetyNotifier extends StateNotifier<TripModel> {
  final Ref ref;
  TripSafetyNotifier(this.ref) : super(const TripModel(id: 'initial'));

  void _setupListener() {
    ref.listen<LocationState>(locationServiceProvider, (previous, next) {
      if (next.position != null && state.status == TripStatus.active) {
        _handleLocationUpdate(LatLng(next.position!.latitude, next.position!.longitude));
      }
    });
  }

  void startTrip(RouteRiskResult riskResult) {
    // Start listening to live location from GPS
    ref.read(locationServiceProvider.notifier).startListening();

    final locationState = ref.read(locationServiceProvider);
    LatLng? currentLoc;
    if (locationState.position != null) {
      currentLoc = LatLng(locationState.position!.latitude, locationState.position!.longitude);
    }

    state = state.copyWith(
      id: const Uuid().v4(),
      status: TripStatus.active,
      origin: riskResult.route.startLocation,
      destination: riskResult.route.endLocation,
      selectedRoute: riskResult.route,
      riskResult: riskResult,
      currentLocation: currentLoc,
      startTime: DateTime.now(),
      expectedEndTime: DateTime.now().add(Duration(seconds: riskResult.route.durationSeconds)),
      distanceRemainingMeters: riskResult.route.distanceMeters.toDouble(),
      isDeviated: false,
    );
  }

  void endTrip() {
    // Stop live tracking to save battery
    ref.read(locationServiceProvider.notifier).stopListening();
    
    state = state.copyWith(
      status: TripStatus.completed,
    );
  }

  void _handleLocationUpdate(LatLng newLocation) {
    if (state.selectedRoute == null) return;
    
    // Check for route deviation (e.g. 50 meters radius)
    final bool isNearRoute = GeoUtils.isPointNearPolyline(
      newLocation, 
      state.selectedRoute!.polylinePoints, 
      50.0
    );

    // Calculate remaining distance (naive straight line from current to destination)
    final remaining = GeoUtils.haversineDistance(newLocation, state.destination!);

    state = state.copyWith(
      currentLocation: newLocation,
      isDeviated: !isNearRoute,
      distanceRemainingMeters: remaining,
    );
  }
}

final tripSafetyProvider = StateNotifierProvider<TripSafetyNotifier, TripModel>((ref) {
  final notifier = TripSafetyNotifier(ref);
  notifier._setupListener();
  return notifier;
});
