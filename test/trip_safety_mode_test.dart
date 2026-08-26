import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sentinel_ai/core/utils/geo_utils.dart';
import 'package:sentinel_ai/data/models/trip_model.dart';

void main() {
  group('TripModel Tests', () {
    test('TripModel initializes with idle status by default', () {
      const trip = TripModel(id: 'test_id');
      expect(trip.id, 'test_id');
      expect(trip.status, TripStatus.idle);
      expect(trip.isDeviated, false);
      expect(trip.distanceRemainingMeters, 0.0);
    });

    test('TripModel copyWith updates fields correctly', () {
      const trip = TripModel(id: 'test_id');
      final updated = trip.copyWith(
        status: TripStatus.active,
        isDeviated: true,
        distanceRemainingMeters: 500.0,
      );
      expect(updated.id, 'test_id');
      expect(updated.status, TripStatus.active);
      expect(updated.isDeviated, true);
      expect(updated.distanceRemainingMeters, 500.0);
    });
  });

  group('Route Deviation Logic (GeoUtils)', () {
    final routePoints = [
      const LatLng(0, 0),
      const LatLng(0, 0.01),
      const LatLng(0, 0.02),
    ];

    test('isPointNearPolyline returns true when point is exactly on route', () {
      final p = const LatLng(0, 0.01);
      final result = GeoUtils.isPointNearPolyline(p, routePoints, 50.0);
      expect(result, true);
    });

    test('isPointNearPolyline returns false when point is far from route', () {
      final p = const LatLng(1.0, 1.0); // very far
      final result = GeoUtils.isPointNearPolyline(p, routePoints, 50.0);
      expect(result, false);
    });

    test('isPointNearPolyline returns true when point is slightly off route but within radius', () {
      // 0.0001 degrees is roughly 11 meters
      final p = const LatLng(0.0001, 0.01); 
      final result = GeoUtils.isPointNearPolyline(p, routePoints, 50.0);
      expect(result, true);
    });

    test('isPointNearPolyline returns false when point is slightly off route and outside radius', () {
      // 0.001 degrees is roughly 111 meters
      final p = const LatLng(0.001, 0.01); 
      final result = GeoUtils.isPointNearPolyline(p, routePoints, 50.0);
      expect(result, false);
    });
  });
}
