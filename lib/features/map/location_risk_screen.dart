import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/risk_chip.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationRiskScreen extends StatelessWidget {
  const LocationRiskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Risk Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
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
                      'Downtown Financial District',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.riskMediumDark, width: 4),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.riskMediumDark, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'MEDIUM',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.riskMediumDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Elevated property crime and traffic incidents reported in the last 24 hours.',
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
            _buildFactorRow(theme, 'Property Crime', RiskLevel.medium),
            _buildFactorRow(theme, 'Violent Crime', RiskLevel.low),
            _buildFactorRow(theme, 'Traffic/Pedestrian', RiskLevel.high),
            _buildFactorRow(theme, 'Lighting/Visibility', RiskLevel.low),
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
        ),
      ),
    );
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
