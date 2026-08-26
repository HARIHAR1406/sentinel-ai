import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LocationStatus {
  initial,
  loading,
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  ready,
  error,
}

class LocationState {
  final LocationStatus status;
  final Position? position;
  final String? errorMessage;

  LocationState({
    this.status = LocationStatus.initial,
    this.position,
    this.errorMessage,
  });

  LocationState copyWith({
    LocationStatus? status,
    Position? position,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      position: position ?? this.position,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LocationService extends StateNotifier<LocationState> {
  StreamSubscription<Position>? _positionStream;

  LocationService() : super(LocationState());

  Future<void> initializeAndGetLocation() async {
    state = state.copyWith(status: LocationStatus.loading);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(status: LocationStatus.serviceDisabled, errorMessage: 'Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(status: LocationStatus.permissionDenied, errorMessage: 'Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(status: LocationStatus.permissionDeniedForever, errorMessage: 'Location permissions are permanently denied.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      state = state.copyWith(
        status: LocationStatus.ready,
        position: position,
      );
    } catch (e) {
      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: 'Failed to get location: $e',
      );
    }
  }

  void startListening() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Only update if moved 10 meters
      ),
    ).listen((Position position) {
      state = state.copyWith(
        status: LocationStatus.ready,
        position: position,
      );
    });
  }

  void stopListening() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<void> openSettings() async {
    if (state.status == LocationStatus.serviceDisabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}

final locationServiceProvider = StateNotifierProvider<LocationService, LocationState>((ref) {
  return LocationService();
});
