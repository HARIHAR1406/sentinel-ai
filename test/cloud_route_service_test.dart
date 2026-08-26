import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:sentinel_ai/data/services/cloud_route_service.dart';
import 'package:sentinel_ai/core/exceptions/route_exceptions.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'cloud_route_service_test.mocks.dart';

@GenerateMocks([FirebaseFunctions, HttpsCallable, HttpsCallableResult])
void main() {
  late MockFirebaseFunctions mockFunctions;
  late MockHttpsCallable mockCallable;
  late CloudRouteService service;

  setUp(() {
    mockFunctions = MockFirebaseFunctions();
    mockCallable = MockHttpsCallable();
    when(mockFunctions.httpsCallable('getSafeRoutes')).thenReturn(mockCallable);
    service = CloudRouteService(functions: mockFunctions);
  });



  group('CloudRouteService API Handling', () {
    test('throws BackendUnavailableException on NOT_FOUND error', () async {
      when(mockCallable.call<Map<String, dynamic>>(any)).thenThrow(
        FirebaseFunctionsException(message: 'Not found', code: 'not-found'),
      );

      expect(
        () => service.getRoutes(const LatLng(0.0, 0.0), const LatLng(1.0, 1.0)),
        throwsA(isA<BackendUnavailableException>()),
      );
    });

    test('throws RouteApiException on general Firebase function error', () async {
      when(mockCallable.call<Map<String, dynamic>>(any)).thenThrow(
        FirebaseFunctionsException(message: 'Internal error', code: 'internal'),
      );

      expect(
        () => service.getRoutes(const LatLng(0.0, 0.0), const LatLng(1.0, 1.0)),
        throwsA(isA<RouteApiException>()),
      );
    });

    test('throws RouteApiException on malformed response', () async {
      final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();
      when(mockResult.data).thenReturn({'invalid_key': []});
      when(mockCallable.call<Map<String, dynamic>>(any)).thenAnswer((_) async => mockResult);

      expect(
        () => service.getRoutes(const LatLng(0.0, 0.0), const LatLng(1.0, 1.0)),
        throwsA(isA<RouteApiException>()),
      );
    });

    test('successfully parses valid backend response', () async {
      final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();
      when(mockResult.data).thenReturn({
        'routes': [
          {
            'id': 'test_route',
            'distanceMeters': 1000,
            'durationSeconds': 600,
            'routeName': 'Test Route',
            'polylinePoints': [{'lat': 0.0, 'lng': 0.0}, {'lat': 1.0, 'lng': 1.0}],
            'startLocation': {'lat': 0.0, 'lng': 0.0},
            'endLocation': {'lat': 1.0, 'lng': 1.0},
          }
        ]
      });
      when(mockCallable.call<Map<String, dynamic>>(any)).thenAnswer((_) async => mockResult);

      final routes = await service.getRoutes(const LatLng(0.0, 0.0), const LatLng(1.0, 1.0));
      
      expect(routes.length, 1);
      expect(routes.first.id, 'test_route');
      expect(routes.first.distanceMeters, 1000);
      expect(routes.first.polylinePoints.length, 2);
    });
  });
}
