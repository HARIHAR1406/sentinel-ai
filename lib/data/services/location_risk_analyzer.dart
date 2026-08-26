import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/utils/geo_utils.dart';
import '../models/incident_model.dart';
import '../models/location_risk_result.dart';
import '../models/route_risk_result.dart'; // For RouteRiskLevel and RiskDataConfidence

class LocationRiskAnalyzer {
  /// Analyzes the risk of a specific location given a radius and incidents.
  /// Only [VerificationStatus.verified] incidents are evaluated.
  LocationRiskResult analyzeLocation({
    required LatLng center,
    required double radiusMeters,
    required List<IncidentModel> incidents,
  }) {
    // 1. Filter to strictly verified incidents
    final verifiedIncidents = incidents.where((i) => i.verificationStatus == VerificationStatus.verified).toList();

    // 2. Find matched incidents inside the radius
    final matchedIncidents = _findIncidentsInRadius(center, radiusMeters, verifiedIncidents);

    // 3. Score risk
    final riskScore = _calculateRiskScore(matchedIncidents);
    
    // 4. Determine level
    final riskLevel = _determineRiskLevel(riskScore, matchedIncidents.length);

    // 5. Generate breakdown
    final breakdown = _generateBreakdown(matchedIncidents);
    
    // 6. Data Confidence
    final confidence = _determineConfidence(verifiedIncidents.length, matchedIncidents.length);

    return LocationRiskResult(
      center: center,
      radiusMeters: radiusMeters,
      matchedIncidents: matchedIncidents,
      totalRiskScore: riskScore,
      riskLevel: riskLevel,
      confidence: confidence,
      riskBreakdown: breakdown,
    );
  }

  List<IncidentModel> _findIncidentsInRadius(LatLng center, double radius, List<IncidentModel> verifiedIncidents) {
    return verifiedIncidents.where((incident) {
      final point = LatLng(incident.latitude, incident.longitude);
      final distance = GeoUtils.haversineDistance(center, point);
      return distance <= radius;
    }).toList();
  }

  double _calculateRiskScore(List<IncidentModel> incidents) {
    double score = 0.0;
    for (final incident in incidents) {
      // Base severity weight
      double weight = 1.0;
      switch (incident.severity) {
        case IncidentSeverity.critical:
          weight = 10.0;
          break;
        case IncidentSeverity.high:
          weight = 5.0;
          break;
        case IncidentSeverity.medium:
          weight = 2.0;
          break;
        case IncidentSeverity.low:
          weight = 1.0;
          break;
      }

      // AI Risk Level Multiplier
      if (incident.aiAnalysis != null) {
        switch (incident.aiAnalysis!.riskLevel.toLowerCase()) {
          case 'critical':
            weight *= 1.5;
            break;
          case 'high':
            weight *= 1.2;
            break;
        }
      }
      
      score += weight;
    }
    return score;
  }

  RouteRiskLevel _determineRiskLevel(double score, int count) {
    if (score == 0) return RouteRiskLevel.low;
    if (score <= 5) return RouteRiskLevel.low;
    if (score <= 15) return RouteRiskLevel.medium;
    if (score <= 30) return RouteRiskLevel.high;
    return RouteRiskLevel.critical;
  }

  RiskDataConfidence _determineConfidence(int totalVerified, int matchedCount) {
    if (totalVerified == 0) return RiskDataConfidence.limited;
    if (totalVerified > 50) return RiskDataConfidence.high;
    return RiskDataConfidence.medium;
  }

  Map<String, int> _generateBreakdown(List<IncidentModel> incidents) {
    final breakdown = <String, int>{};
    for (final incident in incidents) {
      final type = incident.type;
      breakdown[type] = (breakdown[type] ?? 0) + 1;
    }
    return breakdown;
  }
}
