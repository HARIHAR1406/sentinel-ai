import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_ai/data/models/incident_ai_analysis.dart';

void main() {
  group('IncidentAIAnalysis JSON Parsing', () {
    test('successfully parses valid map', () {
      final map = {
        'category': 'Fire Hazard',
        'subCategory': 'building_fire',
        'severity': 'high',
        'priority': 'high',
        'confidence': 0.95,
        'riskLevel': 'ORANGE',
        'reason': 'Fire detected in description',
        'recommendedAction': 'Evacuate',
        'isPotentialDuplicate': false,
      };

      final analysis = IncidentAIAnalysis.fromMap(map);

      expect(analysis.category, 'Fire Hazard');
      expect(analysis.subCategory, 'building_fire');
      expect(analysis.severity, 'high');
      expect(analysis.priority, 'high');
      expect(analysis.confidence, 0.95);
      expect(analysis.riskLevel, 'ORANGE');
      expect(analysis.reason, 'Fire detected in description');
      expect(analysis.recommendedAction, 'Evacuate');
      expect(analysis.isPotentialDuplicate, false);
      expect(analysis.analyzedAt, isA<DateTime>());
    });

    test('handles missing fields safely with defaults', () {
      final map = <String, dynamic>{};

      final analysis = IncidentAIAnalysis.fromMap(map);

      expect(analysis.category, 'unknown');
      expect(analysis.subCategory, 'unknown');
      expect(analysis.severity, 'unknown');
      expect(analysis.priority, 'unknown');
      expect(analysis.confidence, 0.0);
      expect(analysis.riskLevel, 'UNKNOWN');
      expect(analysis.reason, '');
      expect(analysis.recommendedAction, '');
      expect(analysis.isPotentialDuplicate, false);
      expect(analysis.analyzedAt, isA<DateTime>());
    });

    test('normalizes severity enum values correctly', () {
      final analysis1 = IncidentAIAnalysis.fromMap({'severity': 'CRITICAL'});
      expect(analysis1.severity, 'critical');

      final analysis2 = IncidentAIAnalysis.fromMap({'severity': 'Invalid'});
      expect(analysis2.severity, 'unknown');
    });

    test('normalizes riskLevel enum values correctly', () {
      final analysis1 = IncidentAIAnalysis.fromMap({'riskLevel': 'red'});
      expect(analysis1.riskLevel, 'RED');

      final analysis2 = IncidentAIAnalysis.fromMap({'riskLevel': 'Invalid'});
      expect(analysis2.riskLevel, 'UNKNOWN');
    });
  });
}
