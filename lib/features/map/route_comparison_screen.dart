import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/exceptions/route_exceptions.dart';
import '../../shared/widgets/risk_chip.dart';
import '../../data/models/route_risk_result.dart';
import '../../data/services/route_providers.dart';
import '../../data/services/trip_safety_providers.dart';

class RouteComparisonScreen extends ConsumerWidget {
  const RouteComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final routeAnalysisState = ref.watch(routeAnalysisProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Comparison'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: routeAnalysisState.when(
          data: (results) {
            if (results.isEmpty) {
              return _buildEmptyState(context, 'No routes found for this destination.');
            }
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'Select Safer Route',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...results.map((result) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildRouteOption(
                      context,
                      ref,
                      theme, 
                      result,
                      result.recommendation.contains('recommended') || result.recommendation.contains('Optimal')
                    ),
                  );
                }),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analyzing route safety...'),
              ],
            )
          ),
          error: (error, stackTrace) {
            if (error is BackendUnavailableException) {
              return _buildBackendRequiredState(context, theme, error.message);
            } else if (error is RouteTimeoutException) {
              return _buildBackendRequiredState(context, theme, 'Request timed out. Please try again.');
            } else if (error is BackendRequiredException) {
              return _buildBackendRequiredState(context, theme, error.message);
            }
            return _buildEmptyState(context, 'An error occurred while calculating routes: $error');
          },
        ),
      ),
    );
  }

  Widget _buildBackendRequiredState(BuildContext context, ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 24),
            Text(
              'Backend Offline',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Return to Map'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildRouteOption(BuildContext context, WidgetRef ref, ThemeData theme, RouteRiskResult result, bool isRecommended) {
    return Container(
      decoration: BoxDecoration(
        color: isRecommended ? theme.colorScheme.surface : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended ? AppColors.sentinelBlue : theme.dividerColor,
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: isRecommended ? [
          BoxShadow(
            color: AppColors.sentinelBlue.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ] : [],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sentinelBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'RECOMMENDED',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  result.route.routeName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              RiskChip(level: _mapResultRisk(result.riskLevel)),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(
            result.recommendation.isNotEmpty ? result.recommendation : 'Alternative route.', 
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary)
          ),
          
          const SizedBox(height: 12),
          
          // Safety metrics
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(
              children: [
                Icon(Icons.security, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '\${result.matchedIncidents.length} verified incidents',
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (result.confidence != RiskDataConfidence.high)
                  Text(
                    '(\${result.confidence.name.toUpperCase()} DATA)',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, color: theme.colorScheme.error),
                  )
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.directions_car_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                _formatDuration(result.route.durationSeconds),
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.straighten_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                _formatDistance(result.route.distanceMeters),
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ref.read(tripSafetyProvider.notifier).startTrip(result);
                context.push('/trip_safety_mode');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended ? AppColors.sentinelBlue : Colors.transparent,
                foregroundColor: isRecommended ? Colors.white : theme.colorScheme.onSurface,
                side: isRecommended ? BorderSide.none : BorderSide(color: theme.dividerColor),
                elevation: isRecommended ? 2 : 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isRecommended ? 'Start Navigation' : 'Select This Route', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // Map internal risk enum to the shared RiskChip enum
  RiskLevel _mapResultRisk(dynamic level) {
    // If the enums share names, just convert string, else map.
    // They share exact string names (low, medium, high, critical)
    switch(level.toString().split('.').last) {
      case 'critical': return RiskLevel.high; // Map critical to high for the chip if it only supports high
      case 'high': return RiskLevel.high;
      case 'medium': return RiskLevel.medium;
      case 'low': return RiskLevel.low;
      default: return RiskLevel.low;
    }
  }

  String _formatDuration(int seconds) {
    final mins = (seconds / 60).round();
    return '$mins mins';
  }

  String _formatDistance(int meters) {
    final miles = meters / 1609.34;
    return '${miles.toStringAsFixed(1)} mi';
  }
}
