import 'package:cloud_firestore/cloud_firestore.dart';
import 'incident_ai_analysis.dart';

enum IncidentStatus { pending, verified, rejected, resolved }
enum VerificationStatus { pending, verified, rejected, duplicate }
enum IncidentSeverity { low, medium, high, critical }

class IncidentModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String reportedBy;
  final IncidentSeverity severity;
  final IncidentStatus status;
  final VerificationStatus verificationStatus;
  final DateTime timestamp;
  final DateTime? updatedAt;
  final String? imageUrl;
  final String? address;
  final bool isDuplicate;
  final String? duplicateOf;
  final IncidentAIAnalysis? aiAnalysis;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? rejectionReason;

  const IncidentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.reportedBy,
    required this.severity,
    required this.status,
    required this.verificationStatus,
    required this.timestamp,
    this.updatedAt,
    this.imageUrl,
    this.address,
    this.isDuplicate = false,
    this.duplicateOf,
    this.aiAnalysis,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
  });

  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final location = data['location'] as GeoPoint?;
    final lat = location?.latitude ?? data['latitude'] ?? 0.0;
    final lng = location?.longitude ?? data['longitude'] ?? 0.0;
    
    return IncidentModel(
      id: doc.id,
      type: data['type'] ?? 'unknown',
      title: data['title'] ?? 'Incident',
      description: data['description'] ?? '',
      latitude: lat,
      longitude: lng,
      reportedBy: data['reportedBy'] ?? '',
      severity: parseSeverity(data['severity']),
      status: _parseStatus(data['status']),
      verificationStatus: _parseVerificationStatus(data['verificationStatus']),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      imageUrl: data['imageUrl'],
      address: data['address'],
      isDuplicate: data['isDuplicate'] ?? false,
      duplicateOf: data['duplicateOf'],
      aiAnalysis: data['aiAnalysis'] != null ? IncidentAIAnalysis.fromMap(Map<String, dynamic>.from(data['aiAnalysis'])) : null,
      verifiedBy: data['verifiedBy'],
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'location': GeoPoint(latitude, longitude),
      'reportedBy': reportedBy,
      'severity': severity.name,
      'status': status.name,
      'verificationStatus': verificationStatus.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (address != null) 'address': address,
      'isDuplicate': isDuplicate,
      if (duplicateOf != null) 'duplicateOf': duplicateOf,
      if (aiAnalysis != null) 'aiAnalysis': aiAnalysis!.toMap(),
      if (verifiedBy != null) 'verifiedBy': verifiedBy,
      if (verifiedAt != null) 'verifiedAt': Timestamp.fromDate(verifiedAt!),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  static IncidentSeverity parseSeverity(String? value) {
    switch (value) {
      case 'critical': return IncidentSeverity.critical;
      case 'high': return IncidentSeverity.high;
      case 'medium': return IncidentSeverity.medium;
      case 'low': return IncidentSeverity.low;
      default: return IncidentSeverity.medium;
    }
  }

  static IncidentStatus _parseStatus(String? value) {
    switch (value) {
      case 'verified': return IncidentStatus.verified;
      case 'rejected': return IncidentStatus.rejected;
      case 'resolved': return IncidentStatus.resolved;
      case 'pending': 
      default: return IncidentStatus.pending;
    }
  }

  static VerificationStatus _parseVerificationStatus(String? value) {
    switch (value) {
      case 'verified': return VerificationStatus.verified;
      case 'rejected': return VerificationStatus.rejected;
      case 'duplicate': return VerificationStatus.duplicate;
      case 'pending':
      default: return VerificationStatus.pending;
    }
  }
}
