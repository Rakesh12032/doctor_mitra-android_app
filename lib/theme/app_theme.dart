import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static const Color primaryColor = AppColors.primary;
  static const Color accentColor = AppColors.accent;

  static ThemeData getTheme(bool isHindi) {
    final TextTheme baseTextTheme = isHindi
        ? GoogleFonts.notoSansDevanagariTextTheme()
        : GoogleFonts.nunitoTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
        surface: AppColors.cardBg,
      ),
      textTheme: baseTextTheme
          .copyWith(
            displayLarge: baseTextTheme.displayLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
            headlineSmall: baseTextTheme.headlineSmall?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark), // Section heading
            titleLarge: baseTextTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
            titleMedium: baseTextTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark), // Card title
            bodyLarge: baseTextTheme.bodyLarge?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted), // Body/label
            bodyMedium: baseTextTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textMedium),
            bodySmall: baseTextTheme.bodySmall
                ?.copyWith(fontSize: 11, color: AppColors.textMuted),
            labelLarge: baseTextTheme.labelLarge?.copyWith(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            labelSmall: baseTextTheme.labelSmall?.copyWith(
                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          )
          .apply(
            bodyColor: AppColors.textMedium,
            displayColor: AppColors.textDark,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 20, // App bar title
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.2),
          minimumSize: const Size(double.infinity, 52), // Button height 52px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Button radius 12px
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52), // Button height 52px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Button radius 12px
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Card border radius 16px
          side: BorderSide(color: Colors.black.withOpacity(0.015), width: 1),
        ),
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withOpacity(0.08),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Border radius 10px
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        labelStyle: const TextStyle(color: AppColors.textMedium, fontSize: 13),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.textMuted,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBackground,
        labelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Chips rounded 20px
          side: const BorderSide(color: Colors.transparent),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 24),
        selectedLabelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

