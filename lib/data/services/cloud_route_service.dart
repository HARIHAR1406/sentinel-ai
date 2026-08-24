import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/exceptions/backend_required_exception.dart';
import '../models/route_model.dart';
import 'route_service.dart';

class CloudRouteService implements RouteService {
  @override
  Future<List<RouteModel>> getRoutes(LatLng origin, LatLng destination) async {
    // DO NOT fake successful API responses.
    // The Google Maps Directions API requires a protected server API key or unrestricted key.
    // Putting it in the client source is a severe security violation.
    // This requires a backend Cloud Function to proxy the request.
    throw BackendRequiredException(
      'Cloud Function required to safely fetch Directions API without exposing server keys. '
      'Please deploy the route-fetcher Cloud Function and configure its endpoint.',
    );
  }
}
