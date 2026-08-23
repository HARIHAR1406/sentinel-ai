import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'location_service.dart';

final emergencyServiceProvider = Provider<EmergencyService>((ref) {
  return EmergencyService(
    ref.read(databaseServiceProvider),
    ref.read(locationServiceProvider.notifier),
    ref,
  );
});

class EmergencyService {
  final DatabaseService _dbService;
  final LocationService _locationService;
  final Ref _ref;

  EmergencyService(this._dbService, this._locationService, this._ref);

  /// Triggers the emergency SOS workflow.
  /// 
  /// Fetches the user's current location, constructs an emergency message,
  /// and logs it to Firestore. In Phase 7.5, this abstracts Twilio.
  Future<void> triggerEmergencySOS() async {
    double? lat;
    double? lng;
    String locationText = 'Location unavailable';

    try {
      await _locationService.initializeAndGetLocation();
      final locationState = _ref.read(locationServiceProvider);
      final pos = locationState.position;
      if (pos != null) {
        lat = pos.latitude;
        lng = pos.longitude;
        locationText = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      }
    } catch (e) {
      if (kDebugMode) {
        print('EmergencyService: Could not retrieve fresh location: $e');
      }
    }

    final now = DateTime.now();
    final message = '''
Sentinel AI Emergency Alert:
I may need assistance.
Current location: $locationText
Time: ${now.toIso8601String()}
''';

    await _dbService.logEmergency(message, lat, lng);
  }
}
