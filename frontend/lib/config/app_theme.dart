import 'package:flutter/material.dart';

class CivicTokens {
  CivicTokens._();

  static const Color hero = Color(0xFF083F36);
  static const Color primary = Color(0xFF0C5C4C);
  static const Color mint = Color(0xFFB8E6D5);
  static const Color mintDeep = Color(0xFF2A9D8F);
  static const Color navy = Color(0xFF14202B);
  static const Color ink = Color(0xFF1C2A33);
  static const Color muted = Color(0xFF5B6A72);
  static const Color background = Color(0xFFF3EBDD);
  static const Color surface = Color(0xFFFFFDF8);
  static const Color surfaceAlt = Color(0xFFEFE4D2);
  static const Color sidebar = Color(0xFF0B2E28);
  static const Color border = Color(0x3314202B);
  static const Color info = Color(0xFF1E6FBF);
  static const Color infoContainer = Color(0xFFD7E8F8);
  static const Color amber = Color(0xFFC4841D);
  static const Color amberContainer = Color(0xFFF8E6C4);
  static const Color danger = Color(0xFFC0392B);
  static const Color dangerContainer = Color(0xFFF8D4D0);
  static const Color success = Color(0xFF1B7A4A);
  static const Color successContainer = Color(0xFFD3F0E0);

  static const double radius = 14;
  static const double radiusLg = 20;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: CivicTokens.primary,
      onPrimary: Colors.white,
      secondary: CivicTokens.mintDeep,
      onSecondary: Colors.white,
      error: CivicTokens.danger,
      onError: Colors.white,
      surface: CivicTokens.surface,
      onSurface: CivicTokens.ink,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: CivicTokens.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: CivicTokens.background,
        foregroundColor: CivicTokens.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(color: CivicTokens.navy, fontSize: 20, fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: CivicTokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CivicTokens.radius),
          side: const BorderSide(color: CivicTokens.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CivicTokens.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(CivicTokens.radius)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CivicTokens.primary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CivicTokens.radius)),
        ),
      ),
    );
  }
}
