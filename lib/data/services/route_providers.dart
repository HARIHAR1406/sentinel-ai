import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'route_service.dart';
import 'cloud_route_service.dart';
import 'route_risk_analyzer.dart';
import '../models/route_risk_result.dart';
import 'database_service.dart';

final routeServiceProvider = Provider<RouteService>((ref) {
  return CloudRouteService();
});

final routeRiskAnalyzerProvider = Provider<RouteRiskAnalyzer>((ref) {
  return RouteRiskAnalyzer();
});

// A state provider to hold the current destination if selected
final selectedDestinationProvider = StateProvider<LatLng?>((ref) => null);
final selectedOriginProvider = StateProvider<LatLng?>((ref) => null);

// The core provider that fetches routes and analyzes risk
final routeAnalysisProvider = FutureProvider<List<RouteRiskResult>>((ref) async {
  final origin = ref.watch(selectedOriginProvider);
  final destination = ref.watch(selectedDestinationProvider);

  if (origin == null || destination == null) {
    return [];
  }

  // 1. Fetch route alternatives (will throw BackendRequiredException with CloudRouteService)
  final routeService = ref.watch(routeServiceProvider);
  final routes = await routeService.getRoutes(origin, destination);

  // 2. Fetch verified incidents
  // To avoid duplicate queries, we try to use the same stream that the map uses,
  // or fetch directly. For simplicity and performance, we'll wait for the current nearby incidents.
  final incidentsStream = ref.watch(nearbyIncidentsStreamProvider.future);
  final incidents = await incidentsStream;

  // 3. Analyze Risk
  final analyzer = ref.watch(routeRiskAnalyzerProvider);
  return analyzer.analyzeRoutes(routes, incidents);
});
