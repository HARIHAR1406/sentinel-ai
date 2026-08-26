import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/risk_chip.dart';
import '../../data/services/location_risk_providers.dart';
import '../../data/models/route_risk_result.dart';

class LocationRiskScreen extends ConsumerWidget {
  const LocationRiskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final riskAsyncValue = ref.watch(locationRiskProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Risk Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: riskAsyncValue.when(
          data: (result) {
            final isDark = theme.brightness == Brightness.dark;
            final uiRiskLevel = _mapRiskLevel(result.riskLevel);
            
            Color riskColor;
            IconData riskIcon;
            switch (uiRiskLevel) {
              case RiskLevel.low:
                riskColor = isDark ? AppColors.riskLowDark : AppColors.riskLowLight;
                riskIcon = Icons.shield_outlined;
                break;
              case RiskLevel.medium:
                riskColor = isDark ? AppColors.riskMediumDark : AppColors.riskMediumLight;
                riskIcon = Icons.warning_amber_rounded;
                break;
              case RiskLevel.high:
                riskColor = isDark ? AppColors.riskHighDark : AppColors.riskHighLight;
                riskIcon = Icons.gpp_bad_outlined;
                break;
              case RiskLevel.critical:
                riskColor = isDark ? AppColors.riskCriticalDark : AppColors.riskCriticalLight;
                riskIcon = Icons.emergency_outlined;
                break;
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'Current Zone',
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current Location', // Fallback without reverse geocoding
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: riskColor, width: 4),
                          ),
                          child: Column(
                            children: [
                              Icon(riskIcon, color: riskColor, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                uiRiskLevel.name.toUpperCase(),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: riskColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          result.matchedIncidents.isEmpty 
                            ? 'No verified incidents reported within 2km in the last 24 hours.' 
                            : '${result.matchedIncidents.length} verified incident(s) reported in your vicinity.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Risk Factors',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (result.riskBreakdown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text('No prominent risk factors found.', style: theme.textTheme.bodyMedium),
                    ),
                  )
                else
                  ...result.riskBreakdown.entries.map((e) {
                    // Map frequency to a rough risk for display
                    RiskLevel factorRisk = RiskLevel.low;
                    if (e.value > 5) { factorRisk = RiskLevel.critical; }
                    else if (e.value > 2) { factorRisk = RiskLevel.high; }
                    else if (e.value > 1) { factorRisk = RiskLevel.medium; }

                    return _buildFactorRow(theme, e.key, factorRisk);
                  }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context.push('/nearby_incidents'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sentinelBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('View Nearby Incidents', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Failed to load risk data:\n$error', textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
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

  Widget _buildFactorRow(ThemeData theme, String title, RiskLevel risk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.bodyLarge),
          RiskChip(level: risk),
        ],
      ),
    );
  }
}
