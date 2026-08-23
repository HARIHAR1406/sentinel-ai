import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentAIAnalysis {
  final String category;
  final String subCategory;
  final String severity;
  final String priority;
  final double confidence;
  final String riskLevel;
  final String reason;
  final String summary;
  final String recommendedAction;
  final String duplicateStatus;
  final DateTime analyzedAt;

  const IncidentAIAnalysis({
    required this.category,
    required this.subCategory,
    required this.severity,
    required this.priority,
    required this.confidence,
    required this.riskLevel,
    required this.reason,
    required this.summary,
    required this.recommendedAction,
    required this.duplicateStatus,
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
      'summary': summary,
      'recommendedAction': recommendedAction,
      'duplicateStatus': duplicateStatus,
      'analyzedAt': Timestamp.fromDate(analyzedAt),
    };
  }

  factory IncidentAIAnalysis.fromMap(Map<String, dynamic> map) {
    // Backwards compatibility for duplicate status
    String resolvedDuplicateStatus = 'NOT_SIMILAR';
    if (map.containsKey('duplicateStatus')) {
      resolvedDuplicateStatus = _validateDuplicateStatus(map['duplicateStatus'] as String?);
    } else if (map.containsKey('isPotentialDuplicate')) {
      final isDup = map['isPotentialDuplicate'] as bool? ?? false;
      resolvedDuplicateStatus = isDup ? 'POSSIBLY_DUPLICATE' : 'NOT_SIMILAR';
    }

    double rawConfidence = (map['confidence'] as num?)?.toDouble() ?? 0.0;
    if (rawConfidence < 0.0) rawConfidence = 0.0;
    if (rawConfidence > 1.0) rawConfidence = 1.0;

    return IncidentAIAnalysis(
      category: map['category'] as String? ?? 'unknown',
      subCategory: map['subCategory'] as String? ?? 'unknown',
      severity: _validateSeverity(map['severity'] as String?),
      priority: _validatePriority(map['priority'] as String?),
      confidence: rawConfidence,
      riskLevel: _validateRiskLevel(map['riskLevel'] as String?),
      reason: map['reason'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      recommendedAction: map['recommendedAction'] as String? ?? '',
      duplicateStatus: resolvedDuplicateStatus,
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

  static String _validatePriority(String? value) {
    final upper = value?.toUpperCase();
    switch (upper) {
      case 'LOW':
      case 'NORMAL':
      case 'HIGH':
      case 'URGENT':
        return upper!;
      default:
        return 'NORMAL'; // Safe default
    }
  }

  static String _validateDuplicateStatus(String? value) {
    final upper = value?.toUpperCase();
    switch (upper) {
      case 'NOT_SIMILAR':
      case 'POSSIBLY_DUPLICATE':
      case 'LIKELY_DUPLICATE':
        return upper!;
      default:
        return 'NOT_SIMILAR';
    }
  }
}
