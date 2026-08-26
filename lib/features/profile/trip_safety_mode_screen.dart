import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/route_risk_result.dart';
import '../../data/services/trip_safety_providers.dart';
import '../../data/services/safety_alerts_provider.dart';
import '../../shared/widgets/risk_chip.dart';

class TripSafetyModeScreen extends ConsumerWidget {
  const TripSafetyModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tripState = ref.watch(tripSafetyProvider);
    final activeAlerts = ref.watch(safetyAlertsProvider).where((a) => !a.isRead).toList();

    if (tripState.status == TripStatus.idle || tripState.status == TripStatus.completed) {
      return _buildEmptyState(context, theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Safety Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildStatusHeader(theme, tripState),
            const SizedBox(height: 16),
            _buildRouteInformation(theme, tripState),
            const SizedBox(height: 16),
            if (activeAlerts.isNotEmpty) ...[
              _buildContextualWarning(theme, context, activeAlerts),
              const SizedBox(height: 16),
            ],
            _buildRiskSummary(theme, tripState),
            const SizedBox(height: 16),
            _buildCurrentLocation(theme, tripState),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(tripSafetyProvider.notifier).endTrip();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('END TRIP', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Safety Mode')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 64, color: theme.colorScheme.secondary),
              const SizedBox(height: 16),
              Text(
                'No Active Trip',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a destination on the map to start Trip Safety Mode.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Return to Map'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(ThemeData theme, TripModel trip) {
    final bool isDeviated = trip.isDeviated;
    final color = isDeviated ? AppColors.riskHighDark : AppColors.sentinelBlue;
    final icon = isDeviated ? Icons.warning_amber_rounded : Icons.shield_rounded;
    final text = isDeviated ? 'Route Deviation Detected' : 'Active Monitoring ON';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 16),
          Text(
            text,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInformation(ThemeData theme, TripModel trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ROUTE INFORMATION', style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.2)),
            const Divider(),
            _infoRow(theme, Icons.my_location, 'Origin', 'Current Location'),
            const SizedBox(height: 8),
            _infoRow(theme, Icons.location_on, 'Destination', trip.selectedRoute?.routeName ?? 'Selected Destination'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metricBox(theme, Icons.straighten, 'Distance', _formatDistance(trip.distanceRemainingMeters.toInt())),
                if (trip.expectedEndTime != null)
                  _metricBox(theme, Icons.access_time, 'ETA', _formatTime(trip.expectedEndTime!)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskSummary(ThemeData theme, TripModel trip) {
    final result = trip.riskResult;
    if (result == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RISK SUMMARY', style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.2)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calculated Risk', style: theme.textTheme.titleMedium),
                RiskChip(level: _mapRiskLevel(result.riskLevel)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result.matchedIncidents.isEmpty 
                ? 'Insufficient verified safety data or no known incidents.' 
                : '${result.matchedIncidents.length} verified incident(s) near route.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocation(ThemeData theme, TripModel trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENT STATUS', style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.2)),
            const Divider(),
            Row(
              children: [
                Icon(
                  trip.isDeviated ? Icons.error_outline : Icons.check_circle_outline, 
                  color: trip.isDeviated ? AppColors.riskHighDark : AppColors.riskLowDark
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.isDeviated ? 'You have deviated from the selected route.' : 'You are on the selected route.',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualWarning(ThemeData theme, BuildContext context, List activeAlerts) {
    final highestAlert = activeAlerts.first; // Already sorted by priority

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Safety Alert', 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  )
                ),
              ],
            ),
            const Divider(),
            Text(
              highestAlert.description,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.secondary),
        const SizedBox(width: 8),
        Text('$label: ', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary)),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _metricBox(ThemeData theme, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
        Text(value, style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  RiskLevel _mapRiskLevel(RouteRiskLevel rrl) {
    switch (rrl) {
      case RouteRiskLevel.low: return RiskLevel.low;
      case RouteRiskLevel.medium: return RiskLevel.medium;
      case RouteRiskLevel.high: return RiskLevel.high;
      case RouteRiskLevel.critical: return RiskLevel.critical;
    }
  }

  String _formatDistance(int meters) {
    final miles = meters / 1609.34;
    return '${miles.toStringAsFixed(1)} mi';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
