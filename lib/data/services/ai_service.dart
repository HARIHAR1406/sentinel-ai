import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_ai_analysis.dart';
import '../models/incident_model.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return DummyAiService();
});

abstract class AiService {
  /// Analyzes an incident's title, description, and selected category to provide
  /// structured intelligence (severity, priority, risk level, etc.).
  Future<IncidentAIAnalysis?> analyzeIncident(
      String title, String description, String category, [List<IncidentModel>? nearbyIncidents]);
}

class DummyAiService implements AiService {
  @override
  Future<IncidentAIAnalysis?> analyzeIncident(
      String title, String description, String category, [List<IncidentModel>? nearbyIncidents]) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final combined = '\${title.toLowerCase()} \${description.toLowerCase()}';

    String severity = 'medium';
    String priority = 'NORMAL';
    String riskLevel = 'YELLOW';
    double confidence = 0.75;
    String subCategory = 'general';
    String recommendedAction = 'Stay alert and monitor the situation.';
    String summary = 'General incident detected. Monitor for updates.';
    String duplicateStatus = 'NOT_SIMILAR';

    // 1. Simulate AI Classification parsing rules
    if (combined.contains('gun') || combined.contains('weapon') || combined.contains('stab')) {
      severity = 'critical';
      priority = 'URGENT';
      riskLevel = 'RED';
      confidence = 0.95;
      subCategory = 'armed_threat';
      recommendedAction = 'Evacuate area immediately and contact emergency services.';
      summary = 'High-confidence detection of armed threat. Immediate emergency response required.';
    } else if (combined.contains('fire') || combined.contains('smoke')) {
      severity = 'critical';
      priority = 'URGENT';
      riskLevel = 'RED';
      confidence = 0.92;
      subCategory = 'building_fire';
      recommendedAction = 'Do not use elevators. Exit the building safely.';
      summary = 'Fire hazard detected with high confidence. Immediate evacuation recommended.';
    } else if (combined.contains('accident') || combined.contains('crash')) {
      severity = 'high';
      priority = 'HIGH';
      riskLevel = 'ORANGE';
      confidence = 0.88;
      subCategory = 'vehicle_collision';
      recommendedAction = 'Stay clear of traffic. Check for injuries if safe to do so.';
      summary = 'Vehicle collision detected. High severity due to potential for injury and obstruction.';
    } else if (combined.contains('stole') || combined.contains('theft')) {
      severity = 'medium';
      priority = 'NORMAL';
      riskLevel = 'YELLOW';
      confidence = 0.82;
      subCategory = 'property_theft';
      recommendedAction = 'Report to local authorities. Secure remaining belongings.';
      summary = 'Property theft identified. Normal priority for follow-up response.';
    } else if (combined.contains('harass') || combined.contains('stalk')) {
      severity = 'medium';
      priority = 'HIGH';
      riskLevel = 'ORANGE';
      confidence = 0.85;
      subCategory = 'verbal_harassment';
      recommendedAction = 'Move to a safe, populated area immediately.';
      summary = 'Harassment or stalking detected. Elevated priority for user safety.';
    } else if (combined.contains('medical') || combined.contains('unconscious') || combined.contains('injury')) {
      severity = 'critical';
      priority = 'URGENT';
      riskLevel = 'RED';
      confidence = 0.94;
      subCategory = 'injury';
      recommendedAction = 'Provide first aid if qualified, and wait for paramedics.';
      summary = 'Medical emergency detected. Critical severity requiring immediate assistance.';
    } else if (combined.contains('obstruction') || combined.contains('blocked')) {
      severity = 'low';
      priority = 'NORMAL';
      riskLevel = 'GREEN';
      confidence = 0.78;
      subCategory = 'road_obstruction';
      recommendedAction = 'Proceed with caution around the obstructed area.';
      summary = 'Minor road obstruction detected. Low severity.';
    }

    // 2. Duplicate detection (Deterministic)
    if (nearbyIncidents != null && nearbyIncidents.isNotEmpty) {
      for (final existing in nearbyIncidents) {
        if (existing.type == category.toLowerCase().replaceAll(' ', '_')) {
          // Compare descriptions naively for this phase
          if (existing.description.toLowerCase() == description.toLowerCase()) {
            duplicateStatus = 'LIKELY_DUPLICATE';
            summary += ' Warning: This report is highly similar to an existing recent incident.';
            break;
          } else {
            duplicateStatus = 'POSSIBLY_DUPLICATE';
          }
        }
      }
      if (duplicateStatus == 'POSSIBLY_DUPLICATE') {
        summary += ' Note: Other recent incidents share the same category nearby.';
      }
    }

    return IncidentAIAnalysis(
      category: category,
      subCategory: subCategory,
      severity: severity,
      priority: priority,
      confidence: confidence,
      riskLevel: riskLevel,
      reason: 'Analyzed keywords in description and title',
      summary: summary,
      recommendedAction: recommendedAction,
      duplicateStatus: duplicateStatus,
      analyzedAt: DateTime.now(),
    );
  }
}
