import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_model.dart';

abstract class RouteService {
  /// Fetches route alternatives from the origin to the destination.
  /// Should throw a BackendRequiredException if the backend is not configured.
  Future<List<RouteModel>> getRoutes(LatLng origin, LatLng destination);
}
