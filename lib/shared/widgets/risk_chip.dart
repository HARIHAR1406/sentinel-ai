import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

enum RiskLevel { low, medium, high, critical }

class RiskChip extends StatelessWidget {
  final RiskLevel level;
  const RiskChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color color;
    IconData icon;
    String label;

    switch (level) {
      case RiskLevel.low:
        color = isDark ? AppColors.riskLowDark : AppColors.riskLowLight;
        icon = Icons.shield_outlined;
        label = 'Low Risk';
        break;
      case RiskLevel.medium:
        color = isDark ? AppColors.riskMediumDark : AppColors.riskMediumLight;
        icon = Icons.warning_amber_rounded;
        label = 'Medium Risk';
        break;
      case RiskLevel.high:
        color = isDark ? AppColors.riskHighDark : AppColors.riskHighLight;
        icon = Icons.gpp_bad_outlined;
        label = 'High Risk';
        break;
      case RiskLevel.critical:
        color = isDark ? AppColors.riskCriticalDark : AppColors.riskCriticalLight;
        icon = Icons.emergency_outlined;
        label = 'Critical';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
