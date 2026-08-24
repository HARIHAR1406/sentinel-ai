import 'route_model.dart';
import 'incident_model.dart';

enum RouteRiskLevel { low, medium, high, critical }
enum RiskDataConfidence { high, medium, limited }

class RouteRiskResult {
  final RouteModel route;
  final List<IncidentModel> matchedIncidents;
  final double totalRiskScore;
  final RouteRiskLevel riskLevel;
  final RiskDataConfidence confidence;
  final Map<String, int> riskBreakdown;
  final String recommendation;

  const RouteRiskResult({
    required this.route,
    required this.matchedIncidents,
    required this.totalRiskScore,
    required this.riskLevel,
    required this.confidence,
    required this.riskBreakdown,
    required this.recommendation,
  });
}
