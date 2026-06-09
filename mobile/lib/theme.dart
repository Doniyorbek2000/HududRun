// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class HududRunTheme {
  // Background & Surface
  static const Color background                 = Color(0xFF131313);
  static const Color surface                    = Color(0xFF131313);
  static const Color surfaceContainerLowest     = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow        = Color(0xFF1C1B1B);
  static const Color surfaceContainer           = Color(0xFF201F1F);
  static const Color surfaceContainerHigh       = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest    = Color(0xFF353534);
  static const Color surfaceBright              = Color(0xFF393939);
  static const Color surfaceVariant             = Color(0xFF353534);

  // Brand — Primary (blue)
  static const Color primary                    = Color(0xFFADC6FF);
  static const Color primaryContainer           = Color(0xFF4B8EFF);
  static const Color onPrimary                  = Color(0xFF002E69);

  // Brand — Secondary (orange)
  static const Color secondary                  = Color(0xFFFFB693);
  static const Color secondaryContainer         = Color(0xFFFE6B00);
  static const Color onSecondary                = Color(0xFF561F00);

  // Brand — Tertiary (green)
  static const Color tertiary                   = Color(0xFF2AE500);
  static const Color tertiaryContainer          = Color(0xFF1DA800);
  static const Color onTertiary                 = Color(0xFF053900);

  // Text
  static const Color onSurface                  = Color(0xFFE5E2E1);
  static const Color onBackground               = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant           = Color(0xFFC1C6D7);
  static const Color outline                    = Color(0xFF8B90A0);
  static const Color outlineVariant             = Color(0xFF414755);

  // Error
  static const Color error                      = Color(0xFFFFB4AB);
  static const Color errorContainer             = Color(0xFF93000A);

  // -----------------------------------------------------------------------
  // ThemeData
  // -----------------------------------------------------------------------
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      error: error,
      errorContainer: errorContainer,
      background: background,
      onBackground: onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: onSurface,
          letterSpacing: -0.5,
          fontFamily: 'Montserrat',
        ),
        displayMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: onSurface,
          fontFamily: 'Montserrat',
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurface,
          fontFamily: 'Montserrat',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
          fontFamily: 'Montserrat',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onSurface,
          fontFamily: 'Montserrat',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: onSurface),
        bodyMedium: TextStyle(fontSize: 14, color: onSurfaceVariant),
        bodySmall: TextStyle(fontSize: 12, color: onSurfaceVariant),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: tertiary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: outline),
        labelStyle: const TextStyle(color: onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tertiary,
          foregroundColor: onTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerLowest,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: outlineVariant,
        thickness: 1,
      ),
    );
  }
}
