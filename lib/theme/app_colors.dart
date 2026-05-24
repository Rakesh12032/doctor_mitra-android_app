import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0B6E4F); // Deep medical green
  static const Color primaryLight = Color(0xFFE8F5F0); // Light medical green tint
  static const Color accent = Color(0xFF00A878); // Bright teal-green for CTAs
  static const Color secondary = Color(0xFF00A878); // Alias to accent for backwards compatibility
  static const Color lightBackground = Color(0xFFE8F5F0); // Backwards compatibility tint
  static const Color background = Color(0xFFF4F6F9); // Soft premium grey-white scaffold background
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0); // Standard light grey border
  
  static const Color textDark = Color(0xFF1A1A2E); // Deep primary text
  static const Color textMedium = Color(0xFF4A4A6A); // Secondary dark text
  static const Color textMuted = Color(0xFF6B7280); // Muted secondary text
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF00A878);
  
  // Premium soft shadow (0px 2px 12px rgba(0,0,0,0.08))
  static List<BoxShadow> get premiumShadow => const [
        BoxShadow(
          color: Color(0x14000000), // rgba(0,0,0,0.08)
          blurRadius: 12,
          offset: Offset(0, 2),
          spreadRadius: 0,
        ),
      ];
}

