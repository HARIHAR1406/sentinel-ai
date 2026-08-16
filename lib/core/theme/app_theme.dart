import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark Mode (Primary)
  static const Color midnightCanvas = Color(0xFF0A0F1E);
  static const Color cardSurfaceDark = Color(0xFF111827);
  static const Color raisedSurfaceDark = Color(0xFF1C2537);
  static const Color sentinelBlue = Color(0xFF2563EB);
  static const Color aiHorizon = Color(0xFF0EA5E9);
  static const Color textPrimaryLight = Color(0xFFF0F4FF);
  static const Color textSecondaryLight = Color(0xFF8B98B8);
  static const Color borderDark = Color(0x14FFFFFF); // 8% white

  // Light Mode (Secondary)
  static const Color slateWhite = Color(0xFFF8FAFC);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color elevatedLight = Color(0xFFF1F5F9);
  static const Color deepSkyBlue = Color(0xFF0284C7);
  static const Color textPrimaryDark = Color(0xFF0F172A);
  static const Color textSecondaryDark = Color(0xFF64748B);
  static const Color borderLight = Color(0x14000000); // 8% black

  // Semantic Risk Colors (Dark)
  static const Color riskLowDark = Color(0xFF22C55E);
  static const Color riskMediumDark = Color(0xFFF59E0B);
  static const Color riskHighDark = Color(0xFFEF4444);
  static const Color riskCriticalDark = Color(0xFFDC2626);
  static const Color successDark = Color(0xFF10B981);
  static const Color emergencyDark = Color(0xFFFF2D55);

  // Semantic Risk Colors (Light)
  static const Color riskLowLight = Color(0xFF16A34A);
  static const Color riskMediumLight = Color(0xFFD97706);
  static const Color riskHighLight = Color(0xFFDC2626);
  static const Color riskCriticalLight = Color(0xFFB91C1C);
  static const Color successLight = Color(0xFF059669);
  static const Color emergencyLight = Color(0xFFE11D48);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: primaryTextColor,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.midnightCanvas,
      primaryColor: AppColors.sentinelBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.sentinelBlue,
        surface: AppColors.cardSurfaceDark,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.riskHighDark,
        tertiary: AppColors.aiHorizon,
      ),
      textTheme: _buildTextTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
      cardTheme: CardTheme(
        color: AppColors.cardSurfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.raisedSurfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sentinelBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.sentinelBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.riskHighDark, width: 1),
        ),
        errorStyle: GoogleFonts.outfit(color: AppColors.riskHighDark),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.slateWhite,
      primaryColor: AppColors.sentinelBlue,
      colorScheme: const ColorScheme.light(
        primary: AppColors.sentinelBlue,
        surface: AppColors.pureWhite,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.riskHighLight,
        tertiary: AppColors.deepSkyBlue,
      ),
      textTheme: _buildTextTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
      cardTheme: CardTheme(
        color: AppColors.pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.elevatedLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sentinelBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.sentinelBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.riskHighLight, width: 1),
        ),
        errorStyle: GoogleFonts.outfit(color: AppColors.riskHighLight),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }
}
