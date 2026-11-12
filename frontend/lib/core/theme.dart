import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryBlack = Color(0xFF101010);
  static const Color background = Color(0xFFFAF9F6);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8E6E1);
  static const Color secondaryText = Color(0xFF77736D);
  static const Color softBeige = Color(0xFFD8BE95);
  static const Color successGreen = Color(0xFF278A54);
  static const Color warningGold = Color(0xFFC6903C);
  static const Color errorRed = Color(0xFFC84A4A);
  
  // Luxury Dark Cards (for N8 Rewards)
  static const Color darkCardBackground = Color(0xFF1A1A1A);
  static const Color darkCardBorder = Color(0xFF2E2E2E);
  static const Color gold = Color(0xFFC5A880);
  static const Color goldAccent = Color(0xFFD4AF37);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryBlack,
      cardColor: AppColors.cardBackground,
      dividerColor: AppColors.lightBorder,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlack,
        onPrimary: Colors.white,
        secondary: AppColors.softBeige,
        onSecondary: AppColors.primaryBlack,
        surface: AppColors.cardBackground,
        onSurface: AppColors.primaryBlack,
        error: AppColors.errorRed,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.tajawal(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBlack,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.tajawal(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBlack,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlack,
          height: 1.3,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryBlack,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryText,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryText,
          height: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlack,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlack,
          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlack, width: 1.5),
        ),
        hintStyle: GoogleFonts.tajawal(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
      ),
    );
  }
}
