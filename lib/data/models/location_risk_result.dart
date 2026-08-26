import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'incident_model.dart';
import 'route_risk_result.dart'; // To reuse RouteRiskLevel and RiskDataConfidence

class LocationRiskResult {
  final LatLng center;
  final double radiusMeters;
  final List<IncidentModel> matchedIncidents;
  final double totalRiskScore;
  final RouteRiskLevel riskLevel;
  final RiskDataConfidence confidence;
  final Map<String, int> riskBreakdown;

  const LocationRiskResult({
    required this.center,
    required this.radiusMeters,
    required this.matchedIncidents,
    required this.totalRiskScore,
    required this.riskLevel,
    required this.confidence,
    required this.riskBreakdown,
  });
}
