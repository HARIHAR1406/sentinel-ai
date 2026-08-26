import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sentinel_ai/data/services/location_risk_analyzer.dart';
import 'package:sentinel_ai/data/models/incident_model.dart';
import 'package:sentinel_ai/data/models/route_risk_result.dart';

void main() {
  group('LocationRiskAnalyzer Tests', () {
    late LocationRiskAnalyzer analyzer;
    final center = const LatLng(0, 0);

    setUp(() {
      analyzer = LocationRiskAnalyzer();
    });

    test('analyzeLocation returns low risk with no incidents', () {
      final result = analyzer.analyzeLocation(
        center: center,
        radiusMeters: 2000,
        incidents: [],
      );

      expect(result.matchedIncidents.length, 0);
      expect(result.totalRiskScore, 0.0);
      expect(result.riskLevel, RouteRiskLevel.low);
    });

    test('analyzeLocation ignores unverified incidents', () {
      final incidents = [
        IncidentModel(
          id: '1',
          title: 'Title',
          reportedBy: 'user1',
          type: 'Theft',
          description: '',
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.now(),
          status: IncidentStatus.pending,
          severity: IncidentSeverity.high,
          verificationStatus: VerificationStatus.pending, // unverified
        )
      ];

      final result = analyzer.analyzeLocation(
        center: center,
        radiusMeters: 2000,
        incidents: incidents,
      );

      expect(result.matchedIncidents.length, 0);
      expect(result.totalRiskScore, 0.0);
    });

    test('analyzeLocation scores verified incidents correctly', () {
      final incidents = [
        IncidentModel(
          id: '1',
          title: 'Title',
          reportedBy: 'user1',
          type: 'Assault',
          description: '',
          latitude: 0.0,
          longitude: 0.0, // distance = 0m
          timestamp: DateTime.now(),
          status: IncidentStatus.pending,
          severity: IncidentSeverity.critical, // weight = 10
          verificationStatus: VerificationStatus.verified,
        ),
        IncidentModel(
          id: '2',
          title: 'Title',
          reportedBy: 'user2',
          type: 'Theft',
          description: '',
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.now(),
          status: IncidentStatus.pending,
          severity: IncidentSeverity.medium, // weight = 2
          verificationStatus: VerificationStatus.verified,
        ),
      ];

      final result = analyzer.analyzeLocation(
        center: center,
        radiusMeters: 2000,
        incidents: incidents,
      );

      expect(result.matchedIncidents.length, 2);
      expect(result.totalRiskScore, 12.0); // 10 + 2
      expect(result.riskLevel, RouteRiskLevel.medium); // 12 is medium
      expect(result.riskBreakdown['Assault'], 1);
      expect(result.riskBreakdown['Theft'], 1);
    });
  });
}
