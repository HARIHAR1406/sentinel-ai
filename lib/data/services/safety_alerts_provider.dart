import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/alert_model.dart';
import '../models/incident_model.dart';
import 'location_service.dart';
import 'database_service.dart';
import '../../core/utils/geo_utils.dart';
import '../../shared/widgets/risk_chip.dart';

class SafetyAlertsNotifier extends StateNotifier<List<AlertModel>> {
  final Ref ref;
  final double alertRadiusMeters = 500.0;
  final Set<String> _alertedIncidentIds = {};

  List<IncidentModel> _latestIncidents = [];
  LatLng? _latestLocation;
  StreamSubscription<List<IncidentModel>>? _incidentSub;

  SafetyAlertsNotifier(this.ref) : super([]) {
    _setupListeners();
  }

  void _setupListeners() {
    ref.listen<LocationState>(locationServiceProvider, (previous, next) {
      if (next.position != null) {
        final newLoc = LatLng(next.position!.latitude, next.position!.longitude);
        _latestLocation = newLoc;
        
        // Re-subscribe to incidents stream centered around new location
        _incidentSub?.cancel();
        _incidentSub = ref.read(databaseServiceProvider)
            .getNearbyIncidents(newLoc.latitude, newLoc.longitude, 2.0)
            .listen((incidents) {
          _latestIncidents = incidents.where((i) => i.verificationStatus == VerificationStatus.verified).toList();
          _evaluateAlerts();
        });

        _evaluateAlerts();
      }
    });
  }

  @override
  void dispose() {
    _incidentSub?.cancel();
    super.dispose();
  }

  void _evaluateAlerts() {
    if (_latestLocation == null || _latestIncidents.isEmpty) return;

    List<AlertModel> newAlerts = [];

    for (final incident in _latestIncidents) {
      if (_alertedIncidentIds.contains(incident.id)) {
        continue;
      }

      final incidentLoc = LatLng(incident.latitude, incident.longitude);
      final distance = GeoUtils.haversineDistance(_latestLocation!, incidentLoc);

      if (distance <= alertRadiusMeters) {
        final alert = AlertModel(
          id: const Uuid().v4(),
          incidentId: incident.id,
          title: _getAlertTitle(incident),
          description: _getAlertDescription(incident, distance),
          level: _mapSeverity(incident.severity),
          distanceMeters: distance.toInt(),
          timestamp: DateTime.now(),
        );

        newAlerts.add(alert);
        _alertedIncidentIds.add(incident.id);
      }
    }

    if (newAlerts.isNotEmpty) {
      final updatedState = [...state, ...newAlerts];
      // Sort: critical > high > medium > low, then by newest
      updatedState.sort((a, b) {
        final levelCompare = b.level.index.compareTo(a.level.index);
        if (levelCompare != 0) return levelCompare;
        return b.timestamp.compareTo(a.timestamp);
      });
      state = updatedState;
    }
  }

  void dismissAlert(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  void markAsRead(String id) {
    state = state.map((a) {
      if (a.id == id) {
        return a.copyWith(isRead: true);
      }
      return a;
    }).toList();
  }

  String _getAlertTitle(IncidentModel incident) {
    switch (incident.severity) {
      case IncidentSeverity.critical:
        return 'CRITICAL SAFETY ALERT';
      case IncidentSeverity.high:
        return 'HIGH RISK ALERT';
      case IncidentSeverity.medium:
        return 'Safety Advisory';
      case IncidentSeverity.low:
        return 'Local Information';
    }
  }

  String _getAlertDescription(IncidentModel incident, double distance) {
    final typeName = incident.type.toUpperCase();
    return 'Verified $typeName reported approx ${distance.toInt()}m away. \n${incident.title}';
  }

  RiskLevel _mapSeverity(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return RiskLevel.critical;
      case IncidentSeverity.high:
        return RiskLevel.high;
      case IncidentSeverity.medium:
        return RiskLevel.medium;
      case IncidentSeverity.low:
        return RiskLevel.low;
    }
  }
  
  // Expose this for testing purposes
  void forceEvaluate(LatLng loc, List<IncidentModel> incidents) {
    _latestLocation = loc;
    _latestIncidents = incidents.where((i) => i.verificationStatus == VerificationStatus.verified).toList();
    _evaluateAlerts();
  }
}

final safetyAlertsProvider = StateNotifierProvider<SafetyAlertsNotifier, List<AlertModel>>((ref) {
  return SafetyAlertsNotifier(ref);
});
