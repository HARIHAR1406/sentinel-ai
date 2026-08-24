import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../core/exceptions/route_exceptions.dart';
import '../models/route_model.dart';
import 'route_service.dart';

class CloudRouteService implements RouteService {
  final FirebaseFunctions _functions;

  CloudRouteService({FirebaseFunctions? functions}) 
      : _functions = functions ?? FirebaseFunctions.instance;

  @override
  Future<List<RouteModel>> getRoutes(LatLng origin, LatLng destination) async {
    try {
      final callable = _functions.httpsCallable('getSafeRoutes');
      
      final response = await callable.call<Map<String, dynamic>>({
        'origin': {
          'latitude': origin.latitude,
          'longitude': origin.longitude,
        },
        'destination': {
          'latitude': destination.latitude,
          'longitude': destination.longitude,
        }
      }).timeout(const Duration(seconds: 15));

      final data = response.data;
      if (data['routes'] == null) {
        throw RouteApiException('Malformed backend response: missing routes array.');
      }

      final routesList = data['routes'] as List<dynamic>;
      return routesList.map((routeJson) => RouteModel.fromJson(Map<String, dynamic>.from(routeJson))).toList();
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'not-found' || e.code == 'unimplemented') {
        throw BackendUnavailableException('Backend route service is offline or not deployed.');
      }
      throw RouteApiException(e.message ?? 'Unknown backend route error.');
    } on TimeoutException {
      throw RouteTimeoutException('The route request timed out.');
    } catch (e) {
      if (e is BackendUnavailableException || e is RouteApiException || e is RouteTimeoutException) {
        rethrow;
      }
      throw RouteApiException('Failed to retrieve routes: $e');
    }
  }
}
