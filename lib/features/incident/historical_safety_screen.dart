import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/risk_chip.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoricalSafetyScreen extends StatelessWidget {
  const HistoricalSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Dummy Data
    final history = [
      {'date': 'Today', 'risk': RiskLevel.low, 'incidents': 0},
      {'date': 'Yesterday', 'risk': RiskLevel.low, 'incidents': 1},
      {'date': 'Oct 12', 'risk': RiskLevel.medium, 'incidents': 3},
      {'date': 'Oct 11', 'risk': RiskLevel.low, 'incidents': 0},
      {'date': 'Oct 10', 'risk': RiskLevel.high, 'incidents': 5},
      {'date': 'Oct 09', 'risk': RiskLevel.low, 'incidents': 0},
      {'date': 'Oct 08', 'risk': RiskLevel.low, 'incidents': 0},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historical Safety'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Past 7 Days Summary',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(theme, 'Avg Risk', 'LOW', AppColors.riskLowDark),
                    _buildStatCol(theme, 'Incidents', '9', theme.colorScheme.onSurface),
                    _buildStatCol(theme, 'Trend', 'STABLE', AppColors.riskLowDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Daily Log',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...history.map((day) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Card(
                elevation: 0,
                color: theme.scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: ListTile(
                  title: Text(
                    day['date'] as String,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${day['incidents']} Incidents',
                    style: GoogleFonts.jetBrainsMono(
                      color: theme.colorScheme.secondary,
                      fontSize: 13,
                    ),
                  ),
                  trailing: RiskChip(level: day['risk'] as RiskLevel),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCol(ThemeData theme, String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
        ),
      ],
    );
  }
}
