import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/utils/geo_utils.dart';
import '../models/incident_model.dart';
import '../models/route_model.dart';
import '../models/route_risk_result.dart';

class RouteRiskAnalyzer {
  /// Defines the distance in meters from the route polyline where an incident is considered relevant.
  static const double corridorRadiusMeters = 250.0;

  /// Analyzes a list of routes against a dataset of incidents.
  /// Only [VerificationStatus.verified] incidents are evaluated.
  List<RouteRiskResult> analyzeRoutes(List<RouteModel> routes, List<IncidentModel> incidents) {
    // 1. Filter to strictly verified incidents
    final verifiedIncidents = incidents.where((i) => i.verificationStatus == VerificationStatus.verified).toList();

    final results = <RouteRiskResult>[];

    for (final route in routes) {
      // 2. Find matched incidents inside the route corridor
      final matchedIncidents = _findIncidentsInCorridor(route, verifiedIncidents);

      // 3. Score risk
      final riskScore = _calculateRiskScore(matchedIncidents);
      
      // 4. Determine level
      final riskLevel = _determineRiskLevel(riskScore, matchedIncidents.length);

      // 5. Generate breakdown
      final breakdown = _generateBreakdown(matchedIncidents);
      
      // 6. Data Confidence
      final confidence = _determineConfidence(verifiedIncidents.length, matchedIncidents.length);

      results.add(RouteRiskResult(
        route: route,
        matchedIncidents: matchedIncidents,
        totalRiskScore: riskScore,
        riskLevel: riskLevel,
        confidence: confidence,
        riskBreakdown: breakdown,
        recommendation: '', // Will be populated in comparison step
      ));
    }

    return _generateRecommendations(results);
  }

  List<IncidentModel> _findIncidentsInCorridor(RouteModel route, List<IncidentModel> verifiedIncidents) {
    return verifiedIncidents.where((incident) {
      final point = LatLng(incident.latitude, incident.longitude);
      return GeoUtils.isPointNearPolyline(point, route.polylinePoints, corridorRadiusMeters);
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
    // Deterministic thresholds
    // Using Sentinel AI existing incident count zones as baseline, 
    // but adjusting for weighted score.
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
      final type = incident.type; // e.g. "Theft", "Medical Emergency"
      breakdown[type] = (breakdown[type] ?? 0) + 1;
    }
    return breakdown;
  }

  List<RouteRiskResult> _generateRecommendations(List<RouteRiskResult> results) {
    if (results.isEmpty) return results;
    if (results.length == 1) {
      return [
        RouteRiskResult(
          route: results[0].route,
          matchedIncidents: results[0].matchedIncidents,
          totalRiskScore: results[0].totalRiskScore,
          riskLevel: results[0].riskLevel,
          confidence: results[0].confidence,
          riskBreakdown: results[0].riskBreakdown,
          recommendation: results[0].matchedIncidents.isEmpty 
              ? 'Only one route available. Insufficient verified incident data to guarantee safety.'
              : 'Only one route available. Exercise caution based on risk level.',
        )
      ];
    }

    // Sort by risk score ascending (safest first)
    final sortedByRisk = List<RouteRiskResult>.from(results)..sort((a, b) => a.totalRiskScore.compareTo(b.totalRiskScore));
    // Sort by distance ascending (shortest first)
    final sortedByDist = List<RouteRiskResult>.from(results)..sort((a, b) => a.route.distanceMeters.compareTo(b.route.distanceMeters));

    final safest = sortedByRisk.first;
    final shortest = sortedByDist.first;

    final updatedResults = <RouteRiskResult>[];

    for (final res in results) {
      String rec = '';
      if (res == safest && res == shortest) {
        rec = 'Optimal Route: Shortest and Safest route available.';
      } else if (res == safest) {
        final distDiff = safest.route.distanceMeters - shortest.route.distanceMeters;
        final incidentDiff = shortest.matchedIncidents.length - safest.matchedIncidents.length;
        if (incidentDiff > 0) {
          rec = 'Safer route recommended — approximately $distDiff m longer but avoids $incidentDiff verified incidents.';
        } else if (safest.totalRiskScore < shortest.totalRiskScore) {
          rec = 'Safer route recommended — approximately $distDiff m longer but has significantly lower severity risk.';
        } else {
          rec = 'Safest alternative available.';
        }
      } else if (res == shortest) {
        rec = 'Shortest route, but higher incident risk.';
      } else {
        rec = 'Alternative route.';
      }

      updatedResults.add(RouteRiskResult(
        route: res.route,
        matchedIncidents: res.matchedIncidents,
        totalRiskScore: res.totalRiskScore,
        riskLevel: res.riskLevel,
        confidence: res.confidence,
        riskBreakdown: res.riskBreakdown,
        recommendation: rec,
      ));
    }

    return updatedResults;
  }
}
