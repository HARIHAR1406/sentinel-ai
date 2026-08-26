import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_risk_result.dart';
import 'location_risk_analyzer.dart';
import 'location_service.dart';
import 'database_service.dart';

final locationRiskAnalyzerProvider = Provider<LocationRiskAnalyzer>((ref) {
  return LocationRiskAnalyzer();
});

final locationRiskProvider = FutureProvider.autoDispose<LocationRiskResult>((ref) async {
  // 1. Get current location
  final locationState = ref.watch(locationServiceProvider);
  
  if (locationState.position == null) {
    throw Exception('Location not available. Please ensure location services are enabled.');
  }
  
  final center = LatLng(locationState.position!.latitude, locationState.position!.longitude);
  
  // 2. Fetch all verified incidents 
  // We use the firestore stream and take the latest snapshot. 
  // In a real large-scale app we would use geo-queries, but we use the existing stream for phase consistency.
  final incidentStream = ref.watch(databaseServiceProvider).getNearbyIncidents(center.latitude, center.longitude, 2.0);
  final incidents = await incidentStream.first;
  
  // 3. Analyze Risk
  final analyzer = ref.watch(locationRiskAnalyzerProvider);
  return analyzer.analyzeLocation(
    center: center,
    radiusMeters: 2000.0, // 2km radius for location risk
    incidents: incidents,
  );
});
