import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class SentinelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isGhost;

  const SentinelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isGhost = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isGhost) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
