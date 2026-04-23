import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Colors (Modern Soft UI Palette) ─────────────────────────────────────
  static const Color background = Color(0xFFF9FAFB);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFF3F4F6);
  
  // Pastel Accents
  static const Color indigoAccent = Color(0xFF818CF8);
  static const Color purpleAccent = Color(0xFFA78BFA);
  static const Color pinkAccent = Color(0xFFF472B6);
  static const Color blueAccent = Color(0xFF60A5FA);
  static const Color emeraldAccent = Color(0xFF34D399);
  static const Color amberAccent = Color(0xFFFBBF24);

  // Gradients from Redesign
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF818CF8), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient featuredGradient = LinearGradient(
    colors: [Color(0xFFF5F3FF), Color(0xFFFDF2F8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient playButtonGradient = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy/Compatibility Gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient avatarGradient = LinearGradient(
    colors: [Color(0xFF818CF8), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionCreateGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionUploadGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionScheduleGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadow System (Soft UI) ─────────────────────────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF6366F1).withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> miniShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> blueShadow = [
    BoxShadow(
      color: const Color(0xFF60A5FA).withOpacity(0.2),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> purpleShadow = [
    BoxShadow(
      color: const Color(0xFFA78BFA).withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Border Radius ────────────────────────────────────────────────────────
  static const double radiusXL = 24.0;
  static const double radiusLG = 20.0;
  static const double radiusMD = 16.0;
  static const double radiusFull = 100.0;

  // ── Text Styles ──────────────────────────────────────────────────────────
  static TextStyle h1 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle labelSmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );
}
