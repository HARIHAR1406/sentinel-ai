import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_ai/data/models/incident_ai_analysis.dart';

void main() {
  group('IncidentAIAnalysis JSON Parsing', () {
    test('successfully parses valid map', () {
      final map = {
        'category': 'Fire Hazard',
        'subCategory': 'building_fire',
        'severity': 'high',
        'priority': 'URGENT',
        'confidence': 0.95,
        'riskLevel': 'ORANGE',
        'reason': 'Fire detected in description',
        'summary': 'Fire hazard detected with high confidence.',
        'recommendedAction': 'Evacuate',
        'duplicateStatus': 'NOT_SIMILAR',
      };

      final analysis = IncidentAIAnalysis.fromMap(map);

      expect(analysis.category, 'Fire Hazard');
      expect(analysis.subCategory, 'building_fire');
      expect(analysis.severity, 'high');
      expect(analysis.priority, 'URGENT');
      expect(analysis.confidence, 0.95);
      expect(analysis.riskLevel, 'ORANGE');
      expect(analysis.reason, 'Fire detected in description');
      expect(analysis.summary, 'Fire hazard detected with high confidence.');
      expect(analysis.recommendedAction, 'Evacuate');
      expect(analysis.duplicateStatus, 'NOT_SIMILAR');
      expect(analysis.analyzedAt, isA<DateTime>());
    });

    test('handles missing fields safely with defaults', () {
      final map = <String, dynamic>{};

      final analysis = IncidentAIAnalysis.fromMap(map);

      expect(analysis.category, 'unknown');
      expect(analysis.subCategory, 'unknown');
      expect(analysis.severity, 'unknown');
      expect(analysis.priority, 'NORMAL');
      expect(analysis.confidence, 0.0);
      expect(analysis.riskLevel, 'UNKNOWN');
      expect(analysis.reason, '');
      expect(analysis.summary, '');
      expect(analysis.recommendedAction, '');
      expect(analysis.duplicateStatus, 'NOT_SIMILAR');
      expect(analysis.analyzedAt, isA<DateTime>());
    });

    test('normalizes severity enum values correctly', () {
      final analysis1 = IncidentAIAnalysis.fromMap({'severity': 'CRITICAL'});
      expect(analysis1.severity, 'critical');

      final analysis2 = IncidentAIAnalysis.fromMap({'severity': 'Invalid'});
      expect(analysis2.severity, 'unknown');
    });

    test('normalizes priority enum values correctly', () {
      final analysis1 = IncidentAIAnalysis.fromMap({'priority': 'urgent'});
      expect(analysis1.priority, 'URGENT');

      final analysis2 = IncidentAIAnalysis.fromMap({'priority': 'Invalid'});
      expect(analysis2.priority, 'NORMAL');
    });

    test('normalizes riskLevel enum values correctly', () {
      final analysis1 = IncidentAIAnalysis.fromMap({'riskLevel': 'red'});
      expect(analysis1.riskLevel, 'RED');

      final analysis2 = IncidentAIAnalysis.fromMap({'riskLevel': 'Invalid'});
      expect(analysis2.riskLevel, 'UNKNOWN');
    });

    test('normalizes duplicateStatus correctly and handles backward compatibility', () {
      // 1. Explicit duplicateStatus overrides
      final analysis1 = IncidentAIAnalysis.fromMap({'duplicateStatus': 'LIKELY_DUPLICATE'});
      expect(analysis1.duplicateStatus, 'LIKELY_DUPLICATE');

      // 2. Fallback to isPotentialDuplicate
      final analysis2 = IncidentAIAnalysis.fromMap({'isPotentialDuplicate': true});
      expect(analysis2.duplicateStatus, 'POSSIBLY_DUPLICATE');

      final analysis3 = IncidentAIAnalysis.fromMap({'isPotentialDuplicate': false});
      expect(analysis3.duplicateStatus, 'NOT_SIMILAR');

      // 3. Invalid duplicateStatus
      final analysis4 = IncidentAIAnalysis.fromMap({'duplicateStatus': 'WeirdValue'});
      expect(analysis4.duplicateStatus, 'NOT_SIMILAR');
    });

    test('bounds confidence correctly', () {
      final analysis1 = IncidentAIAnalysis.fromMap({'confidence': 1.5});
      expect(analysis1.confidence, 1.0);

      final analysis2 = IncidentAIAnalysis.fromMap({'confidence': -0.5});
      expect(analysis2.confidence, 0.0);
    });
  });
}
