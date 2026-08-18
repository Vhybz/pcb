import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Palette (Material 3 style)
  static const Color lightPrimary = Color(0xFF0061A4);
  static const Color lightOnPrimary = Colors.white;
  static const Color lightPrimaryContainer = Color(0xFFD1E4FF);
  static const Color lightOnPrimaryContainer = Color(0xFF001D36);
  
  static const Color lightSecondary = Color(0xFF535F70);
  static const Color lightOnSecondary = Colors.white;
  static const Color lightSecondaryContainer = Color(0xFFD7E3F7);
  static const Color lightOnSecondaryContainer = Color(0xFF101C2B);
  
  static const Color lightSurface = Color(0xFFFDFCFF);
  static const Color lightOnSurface = Color(0xFF1A1C1E);
  static const Color lightSurfaceContainerHighest = Color(0xFFDFE2EB);
  static const Color lightOnSurfaceVariant = Color(0xFF43474E);
  static const Color lightOutline = Color(0xFF73777F);

  // Dark Theme Palette (Material 3 style)
  static const Color darkPrimary = Color(0xFF9ECAFF);
  static const Color darkOnPrimary = Color(0xFF003258);
  static const Color darkPrimaryContainer = Color(0xFF00497D);
  static const Color darkOnPrimaryContainer = Color(0xFFD1E4FF);
  
  static const Color darkSecondary = Color(0xFFBBC7DB);
  static const Color darkOnSecondary = Color(0xFF253140);
  static const Color darkSecondaryContainer = Color(0xFF3B4858);
  static const Color darkOnSecondaryContainer = Color(0xFFD7E3F7);
  
  static const Color darkSurface = Color(0xFF1A1C1E);
  static const Color darkOnSurface = Color(0xFFE2E2E6);
  static const Color darkSurfaceContainerHighest = Color(0xFF43474E);
  static const Color darkOnSurfaceVariant = Color(0xFFC3C7CF);
  static const Color darkOutline = Color(0xFF8D9199);

  // Status Colors
  static const Color success = Color(0xFF006D39);
  static const Color successContainer = Color(0xFF97F7B4);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Shared Brand Constants
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0061A4), Color(0xFF00B0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
