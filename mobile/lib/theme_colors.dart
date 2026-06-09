// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

/// HududRun brand color constants — single source of truth.
/// Import this file anywhere you need raw Color values.
abstract final class AppColors {
  // ── Surface / Background ──────────────────────────────────────────────────
  static const Color background                 = Color(0xFF131313);
  static const Color surface                    = Color(0xFF131313);
  static const Color surfaceContainerLowest     = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow        = Color(0xFF1C1B1B);
  static const Color surfaceContainer           = Color(0xFF201F1F);
  static const Color surfaceContainerHigh       = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest    = Color(0xFF353534);
  static const Color surfaceBright              = Color(0xFF393939);
  static const Color surfaceVariant             = Color(0xFF353534);

  // ── Primary (blue) ────────────────────────────────────────────────────────
  static const Color primary                    = Color(0xFFADC6FF);
  static const Color primaryContainer           = Color(0xFF4B8EFF);
  static const Color onPrimary                  = Color(0xFF002E69);

  // ── Secondary (orange) ────────────────────────────────────────────────────
  static const Color secondary                  = Color(0xFFFFB693);
  static const Color secondaryContainer         = Color(0xFFFE6B00);
  static const Color onSecondary                = Color(0xFF561F00);

  // ── Tertiary (green) ──────────────────────────────────────────────────────
  static const Color tertiary                   = Color(0xFF2AE500);
  static const Color tertiaryContainer          = Color(0xFF1DA800);
  static const Color onTertiary                 = Color(0xFF053900);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color onSurface                  = Color(0xFFE5E2E1);
  static const Color onBackground               = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant           = Color(0xFFC1C6D7);
  static const Color outline                    = Color(0xFF8B90A0);
  static const Color outlineVariant             = Color(0xFF414755);

  // ── Error ─────────────────────────────────────────────────────────────────
  static const Color error                      = Color(0xFFFFB4AB);
  static const Color errorContainer             = Color(0xFF93000A);

  // ── Gradients (helper shorthands) ─────────────────────────────────────────
  /// Orange conquest gradient (button background)
  static const List<Color> conquestGradient = [
    Color(0xFFFE6B00),
    Color(0xFF7A3000),
  ];

  /// Subtle dark gradient for screens
  static const List<Color> backgroundGradient = [
    Color(0xFF0E0E0E),
    Color(0xFF131313),
  ];
}
