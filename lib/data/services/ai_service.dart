import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/incident_ai_analysis.dart';
import '../models/incident_model.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return CloudAiService();
});

abstract class AiService {
  /// Analyzes an incident's title, description, and selected category to provide
  /// structured intelligence (severity, priority, risk level, etc.).
  Future<IncidentAIAnalysis?> analyzeIncident(
      String title, String description, String category, [List<IncidentModel>? nearbyIncidents]);
}

class CloudAiService implements AiService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  @override
  Future<IncidentAIAnalysis?> analyzeIncident(
      String title, String description, String category, [List<IncidentModel>? nearbyIncidents]) async {
    try {
      final existingData = nearbyIncidents?.map((i) => {
        'id': i.id,
        'title': i.title,
        'description': i.description,
        'type': i.type,
      }).toList();

      final result = await _functions.httpsCallable('analyzeIncident').call({
        'title': title,
        'description': description,
        'category': category,
        'existingIncidents': existingData ?? [],
      });

      final data = result.data as Map<String, dynamic>;

      // Map riskLevel int to string representations if needed
      int riskInt = data['riskLevel'] ?? 3;
      String riskStr = 'YELLOW';
      if (riskInt >= 4) {
        riskStr = 'RED';
      } else if (riskInt == 3) {
        riskStr = 'ORANGE';
      } else if (riskInt == 2) {
        riskStr = 'YELLOW';
      } else {
        riskStr = 'GREEN';
      }

      return IncidentAIAnalysis(
        category: data['category'] ?? category,
        subCategory: data['subCategory'] ?? 'general',
        severity: data['severity'] ?? 'medium',
        priority: data['priority']?.toString().toUpperCase() ?? 'NORMAL',
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.5,
        riskLevel: riskStr,
        reason: 'Analyzed by backend GenAI',
        summary: data['summary'] ?? 'AI Analysis available.',
        recommendedAction: 'Review the analysis for appropriate actions.',
        duplicateStatus: data['duplicateStatus'] ?? 'UNIQUE',
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      // Fallback in case of emulator failure or missing API key
      return IncidentAIAnalysis(
        category: category,
        subCategory: 'general',
        severity: 'medium',
        priority: 'NORMAL',
        confidence: 0.5,
        riskLevel: 'YELLOW',
        reason: 'Backend fallback (Error: $e)',
        summary: 'General incident detected. Backend AI unavailable.',
        recommendedAction: 'Stay alert and monitor the situation.',
        duplicateStatus: 'UNIQUE',
        analyzedAt: DateTime.now(),
      );
    }
  }
}
