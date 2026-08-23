import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_ai_analysis.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return DummyAiService();
});

abstract class AiService {
  /// Analyzes an incident's title, description, and selected category to provide
  /// structured intelligence (severity, priority, risk level, etc.).
  Future<IncidentAIAnalysis?> analyzeIncident(
      String title, String description, String category);
}

class DummyAiService implements AiService {
  @override
  Future<IncidentAIAnalysis?> analyzeIncident(
      String title, String description, String category) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final combined = '\${title.toLowerCase()} \${description.toLowerCase()}';

    String severity = 'medium';
    String priority = 'medium';
    String riskLevel = 'YELLOW';
    double confidence = 0.75;
    String subCategory = 'general';
    String recommendedAction = 'Stay alert and monitor the situation.';
    bool isPotentialDuplicate = false;

    // Simulate AI parsing rules
    if (combined.contains('gun') || combined.contains('weapon') || combined.contains('stab')) {
      severity = 'critical';
      priority = 'critical';
      riskLevel = 'RED';
      confidence = 0.95;
      subCategory = 'armed_threat';
      recommendedAction = 'Evacuate area immediately and contact emergency services.';
    } else if (combined.contains('fire') || combined.contains('smoke')) {
      severity = 'high';
      priority = 'high';
      riskLevel = 'ORANGE';
      confidence = 0.90;
      subCategory = 'building_fire';
      recommendedAction = 'Do not use elevators. Exit the building safely.';
    } else if (combined.contains('accident') || combined.contains('crash')) {
      severity = 'high';
      priority = 'high';
      riskLevel = 'ORANGE';
      confidence = 0.88;
      subCategory = 'vehicle_collision';
      recommendedAction = 'Stay clear of traffic. Check for injuries if safe to do so.';
    } else if (combined.contains('stole') || combined.contains('theft')) {
      severity = 'medium';
      priority = 'low';
      riskLevel = 'YELLOW';
      confidence = 0.82;
      subCategory = 'property_theft';
      recommendedAction = 'Report to local authorities. Secure remaining belongings.';
    }

    return IncidentAIAnalysis(
      category: category,
      subCategory: subCategory,
      severity: severity,
      priority: priority,
      confidence: confidence,
      riskLevel: riskLevel,
      reason: 'Analyzed keywords in description and title',
      recommendedAction: recommendedAction,
      isPotentialDuplicate: isPotentialDuplicate,
      analyzedAt: DateTime.now(),
    );
  }
}
