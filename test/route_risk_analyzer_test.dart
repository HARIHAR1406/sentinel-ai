import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sentinel_ai/data/models/incident_model.dart';
import 'package:sentinel_ai/data/models/incident_ai_analysis.dart';
import 'package:sentinel_ai/data/models/route_model.dart';
import 'package:sentinel_ai/data/models/route_risk_result.dart';
import 'package:sentinel_ai/data/services/route_risk_analyzer.dart';

void main() {
  group('RouteRiskAnalyzer', () {
    late RouteRiskAnalyzer analyzer;

    setUp(() {
      analyzer = RouteRiskAnalyzer();
    });

    final defaultRoute = RouteModel(
      id: 'route_1',
      distanceMeters: 2000,
      durationSeconds: 600,
      routeName: 'Main St',
      polylinePoints: const [
        LatLng(0.0, 0.0),
        LatLng(0.01, 0.0), // Approx 1.1km north
      ],
      startLocation: const LatLng(0.0, 0.0),
      endLocation: const LatLng(0.01, 0.0),
    );

    IncidentModel createIncident({
      required String id,
      required double lat,
      required double lng,
      VerificationStatus status = VerificationStatus.verified,
      IncidentSeverity severity = IncidentSeverity.low,
      IncidentAIAnalysis? aiAnalysis,
    }) {
      return IncidentModel(
        id: id,
        type: 'Test',
        title: 'Test Incident',
        description: 'Testing',
        latitude: lat,
        longitude: lng,
        reportedBy: 'user_1',
        severity: severity,
        status: IncidentStatus.verified,
        verificationStatus: status,
        timestamp: DateTime.now(),
        aiAnalysis: aiAnalysis,
      );
    }

    test('ignores non-verified incidents', () {
      final incidents = [
        createIncident(id: '1', lat: 0.005, lng: 0.0, status: VerificationStatus.pending),
        createIncident(id: '2', lat: 0.005, lng: 0.0, status: VerificationStatus.rejected),
        createIncident(id: '3', lat: 0.005, lng: 0.0, status: VerificationStatus.duplicate),
      ];

      final results = analyzer.analyzeRoutes([defaultRoute], incidents);
      
      expect(results.length, 1);
      expect(results.first.matchedIncidents.isEmpty, isTrue);
      expect(results.first.riskLevel, RouteRiskLevel.low);
    });

    test('matches verified incident on route corridor', () {
      final incidents = [
        createIncident(id: '1', lat: 0.005, lng: 0.0), // Directly on polyline
      ];

      final results = analyzer.analyzeRoutes([defaultRoute], incidents);
      
      expect(results.first.matchedIncidents.length, 1);
      expect(results.first.matchedIncidents.first.id, '1');
    });

    test('ignores verified incident outside route corridor', () {
      final incidents = [
        createIncident(id: '1', lat: 0.005, lng: 0.1), // Way too far East
      ];

      final results = analyzer.analyzeRoutes([defaultRoute], incidents);
      
      expect(results.first.matchedIncidents.isEmpty, isTrue);
    });

    test('applies weighting based on severity and AI priority', () {
      final incidents = [
        createIncident(
          id: '1', 
          lat: 0.005, 
          lng: 0.0,
          severity: IncidentSeverity.critical,
          aiAnalysis: IncidentAIAnalysis(
            category: 'Test',
            subCategory: 'Test',
            severity: 'Critical',
            priority: 'High',
            confidence: 0.9,
            riskLevel: 'critical', // x1.5 multiplier
            reason: '',
            summary: '',
            recommendedAction: '',
            duplicateStatus: '',
            analyzedAt: DateTime.now(),
          )
        ),
      ];

      final results = analyzer.analyzeRoutes([defaultRoute], incidents);
      
      // Critical severity = 10.0
      // AI Risk Level Critical = * 1.5
      // Total score = 15.0
      expect(results.first.totalRiskScore, 15.0);
      expect(results.first.riskLevel, RouteRiskLevel.medium); // score <= 15 is medium
    });

    test('generates balanced recommendations for multiple routes', () {
      final routeA = RouteModel(
        id: 'A',
        distanceMeters: 2000,
        durationSeconds: 600,
        routeName: 'Route A',
        polylinePoints: const [LatLng(0.0, 0.0), LatLng(0.01, 0.0)], // Middle is 0.005, 0.0
        startLocation: const LatLng(0.0, 0.0),
        endLocation: const LatLng(0.01, 0.0),
      );

      final routeB = RouteModel(
        id: 'B',
        distanceMeters: 2500, // Longer
        durationSeconds: 700,
        routeName: 'Route B',
        polylinePoints: const [LatLng(0.0, 0.0), LatLng(0.0, 0.01), LatLng(0.01, 0.0)],
        startLocation: const LatLng(0.0, 0.0),
        endLocation: const LatLng(0.01, 0.0),
      );

      // Place 10 incidents on Route A
      final incidents = List.generate(10, (i) => createIncident(
        id: 'inc_\$i',
        lat: 0.005,
        lng: 0.0,
        severity: IncidentSeverity.high,
      ));

      final results = analyzer.analyzeRoutes([routeA, routeB], incidents);
      
      expect(results.length, 2);
      
      // Route B is safest (0 incidents)
      final resB = results.firstWhere((r) => r.route.id == 'B');
      expect(resB.matchedIncidents.isEmpty, isTrue);
      expect(resB.recommendation, contains('Safer route recommended'));
      
      // Route A is shortest but high risk
      final resA = results.firstWhere((r) => r.route.id == 'A');
      expect(resA.matchedIncidents.length, 10);
      expect(resA.recommendation, contains('Shortest route, but higher incident risk'));
    });
  });
}
