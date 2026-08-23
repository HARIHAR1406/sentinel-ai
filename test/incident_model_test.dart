import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sentinel_ai/data/models/incident_model.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  final String _id;

  MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic get(Object field) => _data[field];

  @override
  bool get exists => true;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  DocumentReference<Map<String, dynamic>> get reference => throw UnimplementedError();

  @override
  operator [](Object field) => _data[field];
}

void main() {
  group('IncidentModel JSON Parsing', () {
    test('successfully parses valid map with all verification fields', () {
      final now = DateTime.now();
      final map = {
        'type': 'fire',
        'title': 'Test Fire',
        'description': 'A small fire',
        'latitude': 34.0,
        'longitude': -118.0,
        'reportedBy': 'user123',
        'severity': 'high',
        'status': 'verified',
        'verificationStatus': 'verified',
        'timestamp': Timestamp.fromDate(now),
        'verifiedBy': 'admin1',
        'verifiedAt': Timestamp.fromDate(now),
      };

      final doc = MockDocumentSnapshot('doc1', map);
      final incident = IncidentModel.fromFirestore(doc);

      expect(incident.id, 'doc1');
      expect(incident.type, 'fire');
      expect(incident.verificationStatus, VerificationStatus.verified);
      expect(incident.verifiedBy, 'admin1');
      expect(incident.verifiedAt, isNotNull);
    });

    test('handles missing verification fields safely (backward compatibility)', () {
      final now = DateTime.now();
      final map = {
        'type': 'theft',
        'title': 'Test Theft',
        'description': 'A theft',
        'latitude': 34.0,
        'longitude': -118.0,
        'reportedBy': 'user123',
        'timestamp': Timestamp.fromDate(now),
      };

      final doc = MockDocumentSnapshot('doc2', map);
      final incident = IncidentModel.fromFirestore(doc);

      expect(incident.verificationStatus, VerificationStatus.pending);
      expect(incident.verifiedBy, isNull);
      expect(incident.verifiedAt, isNull);
      expect(incident.rejectionReason, isNull);
      expect(incident.isDuplicate, false);
      expect(incident.duplicateOf, isNull);
    });

    test('normalizes verificationStatus enum correctly', () {
      final doc1 = MockDocumentSnapshot('1', {'verificationStatus': 'rejected'});
      expect(IncidentModel.fromFirestore(doc1).verificationStatus, VerificationStatus.rejected);

      final doc2 = MockDocumentSnapshot('2', {'verificationStatus': 'duplicate'});
      expect(IncidentModel.fromFirestore(doc2).verificationStatus, VerificationStatus.duplicate);

      final doc3 = MockDocumentSnapshot('3', {'verificationStatus': 'weird_value'});
      expect(IncidentModel.fromFirestore(doc3).verificationStatus, VerificationStatus.pending);
    });
    
    test('toFirestore serializes correctly', () {
      final now = DateTime.now();
      final incident = IncidentModel(
        id: '1',
        type: 'fire',
        title: 'Title',
        description: 'Desc',
        latitude: 1.0,
        longitude: 2.0,
        reportedBy: 'uid',
        severity: IncidentSeverity.low,
        status: IncidentStatus.rejected,
        verificationStatus: VerificationStatus.duplicate,
        timestamp: now,
        isDuplicate: true,
        duplicateOf: 'orig',
        verifiedBy: 'admin',
        verifiedAt: now,
        rejectionReason: 'Fake',
      );
      
      final map = incident.toFirestore();
      
      expect(map['verificationStatus'], 'duplicate');
      expect(map['isDuplicate'], true);
      expect(map['duplicateOf'], 'orig');
      expect(map['verifiedBy'], 'admin');
      expect(map['rejectionReason'], 'Fake');
      expect(map['verifiedAt'], isA<Timestamp>());
    });
  });
}
