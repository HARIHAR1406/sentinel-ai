import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/risk_chip.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RouteComparisonScreen extends StatelessWidget {
  const RouteComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Comparison'),
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
              'Select Safer Route',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRouteOption(
              context, 
              theme, 
              'Route A (Main Highway)', 
              'Fastest, but active accident reported', 
              '24 mins', 
              '12.4 mi', 
              RiskLevel.medium,
              false,
            ),
            const SizedBox(height: 16),
            _buildRouteOption(
              context, 
              theme, 
              'Route B (Scenic Drive)', 
              'Sentinel Recommended', 
              '28 mins', 
              '13.1 mi', 
              RiskLevel.low,
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteOption(BuildContext context, ThemeData theme, String title, String desc, String time, String distance, RiskLevel risk, bool isRecommended) {
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
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              RiskChip(level: risk),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.directions_car_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                time,
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.straighten_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                distance,
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
                // Return to map or start navigation
                context.pop();
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
}
