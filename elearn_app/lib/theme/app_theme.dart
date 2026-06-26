import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF6542A6);
  static const primaryDark = Color(0xFF45247D);
  static const primarySoft = Color(0xFFE8E1FF);

  static const secondary = Color(0xFFF5A45D);
  static const blue = Color(0xFF2AA7F2);
  static const success = Color(0xFF5DDE9B);
  static const warning = Color(0xFFF7BE4B);
  static const error = Color(0xFFF05B63);

  static const background = Color(0xFFF4F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF8F9FB);

  static const textPrimary = Color(0xFF0B1736);
  static const textSecondary = Color(0xFF7D8493);
  static const border = Color(0xFFE8EBEF);

  // Pastel Accents
  static const pastelPurple = Color(0xFFE8E1FF);
  static const pastelBlue = Color(0xFFD9F3FF);
  static const pastelPink = Color(0xFFFFE1E6);
  static const pastelYellow = Color(0xFFFFF1BF);
  static const pastelMint = Color(0xFFDDF8EA);
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  AppRadius._();

  static const small = 10.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const extraLarge = 32.0;
  static const pill = 999.0;
}

class AppTheme {
  AppTheme._();

  // Legacy/Compatibility definitions for widgets using older style references
  static const Color background = AppColors.background;
  static const Color cardWhite = AppColors.surface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color borderLight = AppColors.border;

  // Accents
  static const Color indigoAccent = AppColors.primary;
  static const Color purpleAccent = AppColors.primarySoft;
  static const Color pinkAccent = AppColors.pastelPink;
  static const Color blueAccent = AppColors.blue;
  static const Color emeraldAccent = AppColors.success;
  static const Color amberAccent = AppColors.warning;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient featuredGradient = LinearGradient(
    colors: [AppColors.pastelPurple, Color(0xFFF3E8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [AppColors.pastelBlue, AppColors.pastelPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient playButtonGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient avatarGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionCreateGradient = LinearGradient(
    colors: [AppColors.success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionUploadGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primarySoft],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionScheduleGradient = LinearGradient(
    colors: [AppColors.warning, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy radii compatibility aliases
  static const double radiusFull = AppRadius.pill;
  static const double radiusXL = AppRadius.large;
  static const double radiusLG = AppRadius.medium;
  static const double radiusMD = AppRadius.small;

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: AppColors.textPrimary.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> miniShadow = [
    BoxShadow(
      color: AppColors.textPrimary.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> blueShadow = [
    BoxShadow(
      color: AppColors.blue.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> purpleShadow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  // Base text styles
  static TextStyle h1 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle labelSmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // Global ThemeData configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Plus Jakarta Sans', // Fallbacks to system sans-serif if not found
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        primaryContainer: AppColors.primarySoft,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        background: AppColors.background,
        brightness: Brightness.light,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        headlineLarge: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
        bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.white),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.large),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.primarySoft,
        disabledColor: Colors.transparent,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
