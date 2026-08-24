import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoUtils {
  static const double earthRadiusMeters = 6371000;

  /// Calculates the Haversine distance between two points in meters.
  static double haversineDistance(LatLng p1, LatLng p2) {
    final dLat = _toRadians(p2.latitude - p1.latitude);
    final dLon = _toRadians(p2.longitude - p1.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(p1.latitude)) *
            math.cos(_toRadians(p2.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadiusMeters * c;
  }

  /// Finds the minimum distance from a point [p] to a line segment defined by [a] and [b].
  /// Uses equirectangular approximation for high performance over short distances.
  static double distanceToSegment(LatLng p, LatLng a, LatLng b) {
    // Convert to radians
    final lat1 = _toRadians(a.latitude);
    final lon1 = _toRadians(a.longitude);
    final lat2 = _toRadians(b.latitude);
    final lon2 = _toRadians(b.longitude);
    final lat3 = _toRadians(p.latitude);
    final lon3 = _toRadians(p.longitude);

    // Approximate flat plane coordinates
    final x1 = lon1 * math.cos((lat1 + lat3) / 2);
    final y1 = lat1;
    final x2 = lon2 * math.cos((lat2 + lat3) / 2);
    final y2 = lat2;
    final x3 = lon3 * math.cos(lat3); // using lat3 for the point
    final y3 = lat3;

    final dx = x2 - x1;
    final dy = y2 - y1;
    final lengthSquared = dx * dx + dy * dy;

    if (lengthSquared == 0.0) {
      // a and b are the same point
      return haversineDistance(p, a);
    }

    // Projection scalar
    final t = math.max(0.0, math.min(1.0, ((x3 - x1) * dx + (y3 - y1) * dy) / lengthSquared));
    
    final projX = x1 + t * dx;
    final projY = y1 + t * dy;

    // Distance in radians on the approximated plane
    final dRad = math.sqrt(math.pow(x3 - projX, 2) + math.pow(y3 - projY, 2));

    return dRad * earthRadiusMeters;
  }

  /// Checks if a point [p] is within [radiusMeters] of ANY segment of the [polyline].
  static bool isPointNearPolyline(LatLng p, List<LatLng> polyline, double radiusMeters) {
    if (polyline.isEmpty) return false;
    if (polyline.length == 1) {
      return haversineDistance(p, polyline.first) <= radiusMeters;
    }

    for (int i = 0; i < polyline.length - 1; i++) {
      final a = polyline[i];
      final b = polyline[i + 1];

      // Quick bounding box check to avoid expensive math if far away
      final minLat = math.min(a.latitude, b.latitude);
      final maxLat = math.max(a.latitude, b.latitude);
      final minLng = math.min(a.longitude, b.longitude);
      final maxLng = math.max(a.longitude, b.longitude);
      
      // ~1 degree = 111km, so radiusMeters / 111000 is approx degrees
      final buffer = (radiusMeters / 111000.0) * 1.5; // 1.5 safety factor

      if (p.latitude < minLat - buffer ||
          p.latitude > maxLat + buffer ||
          p.longitude < minLng - buffer ||
          p.longitude > maxLng + buffer) {
        continue;
      }

      final dist = distanceToSegment(p, a, b);
      if (dist <= radiusMeters) {
        return true;
      }
    }
    return false;
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180.0;
  }
}
