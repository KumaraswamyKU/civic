import 'package:flutter/material.dart';

/// Civic visual identity — deep teal, warm paper, navy type.
class CivicTokens {
  CivicTokens._();

  static const Color hero = Color(0xFF083F36);
  static const Color heroEnd = Color(0xFF0C5C4C);
  static const Color primary = Color(0xFF0C5C4C);
  static const Color primarySoft = Color(0xFF1A7A66);
  static const Color mint = Color(0xFFB8E6D5);
  static const Color mintDeep = Color(0xFF2A9D8F);
  static const Color info = Color(0xFF1E6FBF);
  static const Color infoContainer = Color(0xFFD7E8F8);
  static const Color amber = Color(0xFFC4841D);
  static const Color amberContainer = Color(0xFFF8E6C4);
  static const Color danger = Color(0xFFC0392B);
  static const Color dangerContainer = Color(0xFFF8D4D0);
  static const Color success = Color(0xFF1B7A4A);
  static const Color successContainer = Color(0xFFD3F0E0);
  static const Color navy = Color(0xFF14202B);
  static const Color ink = Color(0xFF1C2A33);
  static const Color muted = Color(0xFF5B6A72);
  static const Color background = Color(0xFFF3EBDD);
  static const Color canvas = Color(0xFF0B221E);
  static const Color surface = Color(0xFFFFFDF8);
  static const Color surfaceAlt = Color(0xFFEFE4D2);
  static const Color border = Color(0x3314202B);

  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  static const double radiusPill = 999;

  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;

  static const double phoneWidth = 390;
  static const double phoneHeight = 844;
  static const double phoneFrameBreakpoint = 520;
  static const double maxContentWidth = 430;
  static const double touchTarget = 48;
  static const double buttonHeight = 52;
  static const double thumbnailWidth = 92;
  static const double thumbnailHeight = 112;
  static const double navHeight = 64;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: CivicTokens.primary,
      onPrimary: Colors.white,
      primaryContainer: CivicTokens.mint,
      onPrimaryContainer: CivicTokens.hero,
      secondary: CivicTokens.mintDeep,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD8F3EA),
      onSecondaryContainer: CivicTokens.hero,
      tertiary: CivicTokens.info,
      onTertiary: Colors.white,
      error: CivicTokens.danger,
      onError: Colors.white,
      surface: CivicTokens.surface,
      onSurface: CivicTokens.ink,
      onSurfaceVariant: CivicTokens.muted,
      outline: CivicTokens.border,
      outlineVariant: Color(0x2214202B),
      inverseSurface: CivicTokens.navy,
      onInverseSurface: CivicTokens.background,
      inversePrimary: CivicTokens.mint,
      surfaceTint: Colors.transparent,
    );

    final radius = BorderRadius.circular(CivicTokens.radiusMd);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: CivicTokens.background,
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, height: 1.1, color: CivicTokens.navy, letterSpacing: -0.8),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, color: CivicTokens.navy, letterSpacing: -0.6),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2, color: CivicTokens.navy),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: CivicTokens.navy),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: CivicTokens.navy),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: CivicTokens.navy),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: CivicTokens.ink),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: CivicTokens.ink),
        bodySmall: TextStyle(fontSize: 12, height: 1.35, color: CivicTokens.muted),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: CivicTokens.navy),
        displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: CivicTokens.navy, letterSpacing: -1),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CivicTokens.background,
        foregroundColor: CivicTokens.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: CivicTokens.navy,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: CivicTokens.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: CivicTokens.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CivicTokens.surface,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: CivicTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: CivicTokens.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CivicTokens.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(CivicTokens.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CivicTokens.navy,
          minimumSize: const Size(CivicTokens.touchTarget, CivicTokens.buttonHeight),
          side: const BorderSide(color: CivicTokens.border, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CivicTokens.primary,
          minimumSize: const Size(CivicTokens.touchTarget, CivicTokens.touchTarget),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: CivicTokens.mint,
        backgroundColor: CivicTokens.surface,
        side: const BorderSide(color: CivicTokens.border),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, color: CivicTokens.navy),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CivicTokens.radiusPill),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: CivicTokens.surface,
        indicatorColor: CivicTokens.mint,
        elevation: 0,
        height: CivicTokens.navHeight,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CivicTokens.navy,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
