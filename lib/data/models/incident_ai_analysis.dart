import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentAIAnalysis {
  final String category;
  final String subCategory;
  final String severity;
  final String priority;
  final double confidence;
  final String riskLevel;
  final String reason;
  final String recommendedAction;
  final bool isPotentialDuplicate;
  final DateTime analyzedAt;

  const IncidentAIAnalysis({
    required this.category,
    required this.subCategory,
    required this.severity,
    required this.priority,
    required this.confidence,
    required this.riskLevel,
    required this.reason,
    required this.recommendedAction,
    required this.isPotentialDuplicate,
    required this.analyzedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'subCategory': subCategory,
      'severity': severity,
      'priority': priority,
      'confidence': confidence,
      'riskLevel': riskLevel,
      'reason': reason,
      'recommendedAction': recommendedAction,
      'isPotentialDuplicate': isPotentialDuplicate,
      'analyzedAt': Timestamp.fromDate(analyzedAt),
    };
  }

  factory IncidentAIAnalysis.fromMap(Map<String, dynamic> map) {
    return IncidentAIAnalysis(
      category: map['category'] as String? ?? 'unknown',
      subCategory: map['subCategory'] as String? ?? 'unknown',
      severity: _validateSeverity(map['severity'] as String?),
      priority: map['priority'] as String? ?? 'unknown',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      riskLevel: _validateRiskLevel(map['riskLevel'] as String?),
      reason: map['reason'] as String? ?? '',
      recommendedAction: map['recommendedAction'] as String? ?? '',
      isPotentialDuplicate: map['isPotentialDuplicate'] as bool? ?? false,
      analyzedAt: (map['analyzedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static String _validateSeverity(String? value) {
    final lower = value?.toLowerCase();
    switch (lower) {
      case 'low':
      case 'medium':
      case 'high':
      case 'critical':
        return lower!;
      default:
        return 'unknown';
    }
  }

  static String _validateRiskLevel(String? value) {
    final upper = value?.toUpperCase();
    switch (upper) {
      case 'GREEN':
      case 'YELLOW':
      case 'ORANGE':
      case 'RED':
        return upper!;
      default:
        return 'UNKNOWN';
    }
  }
}
