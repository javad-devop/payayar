import 'package:flutter/material.dart';

/// Central design tokens for PAYAYAR (design.md §6, §9, §10, §35).
///
/// Every reusable visual value must come from this file. Screens and
/// components must not hard-code colors, spacing, radii or durations.
/// Semantic colors keep one meaning across the whole product:
/// blue = primary interaction, green = completed, orange = warning,
/// red/pink = failure, purple = AI, gray = secondary information.

/// Shared semantic accents (identical in Dark and Light mode).
abstract final class AppColors {
  static const Color primary = Color(0xFF4F63F7);
  static const Color success = Color(0xFF35C98A);
  static const Color warning = Color(0xFFF2A13B);
  static const Color error = Color(0xFFF06B78);
  static const Color ai = Color(0xFF8B7CFF);

  // Readable variants of the same semantic hues for Light Mode, so
  // text keeps sufficient contrast without changing meaning.
  static const Color aiStrong = Color(0xFF5B4CE0);
  static const Color errorStrong = Color(0xFFC64251);
  static const Color successStrong = Color(0xFF12865C);
  static const Color warningStrong = Color(0xFFA96412);
}

/// A complete surface palette. Dark mode is the approved reference
/// direction (design.md §2); Light mode is a real adaptation of the
/// same hierarchy, not a naive color inversion (design.md §40).
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.highlight,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color highlight;

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF071426), // Deep Navy
    surface: Color(0xFF10233D), // Surface Navy
    surfaceSoft: Color(0xFF162D4A), // Surface Soft
    textPrimary: Color(0xFFF4F7FF),
    textSecondary: Color(0xFFA9B8CC),
    textMuted: Color(0xFF71839A),
    border: Color(0x1AFFFFFF), // rgba(255,255,255,0.10)
    highlight: Color(0x0FFFFFFF), // rgba(255,255,255,0.06)
  );

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFEEF3FB),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFE5ECF7),
    textPrimary: Color(0xFF0A1B33),
    textSecondary: Color(0xFF45586F),
    textMuted: Color(0xFF6C7D94),
    border: Color(0x1A071426), // rgba(7,20,38,0.10)
    highlight: Color(0x99FFFFFF), // rgba(255,255,255,0.60)
  );

  bool get isDark => brightness == Brightness.dark;
}

/// Spacing rhythm (design.md §9): 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 48;
}

/// Corner radius scale (design.md §10).
abstract final class AppRadius {
  static const double control = 10;
  static const double button = 12;

  /// Icon container inside metric cards (design.md §15.1: 44×44, radius 14).
  static const double icon = 14;
  static const double card = 16;
  static const double panel = 20;
  static const double large = 24;
  static const double pill = 999;
}

/// Vazirmatn weight mapping (design.md §8).
abstract final class AppFontWeight {
  static const FontWeight light = FontWeight.w300; // secondary/supporting
  static const FontWeight regular = FontWeight.w400; // body
  static const FontWeight medium = FontWeight.w500; // labels/nav/forms
  static const FontWeight semiBold = FontWeight.w600; // section titles
  static const FontWeight bold = FontWeight.w700; // page titles/metrics
  static const FontWeight extraBold = FontWeight.w800; // major numeric emphasis
  static const FontWeight black = FontWeight.w900; // rare display text
}

/// Type scale. Most UI text stays Regular/Medium (design.md §8).
abstract final class AppTypeScale {
  static const double display = 34;
  static const double h1 = 28;
  static const double h2 = 22;
  static const double title = 18;
  static const double body = 15;
  static const double label = 13;
  static const double caption = 12;
}

/// Font family registered in pubspec.yaml (Vazirmatn = maintained
/// distribution of the Vazir family, design.md §8).
const String appFontFamily = 'Vazirmatn';

/// Motion (design.md §22): motion is used sparingly and never decorative.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

/// Blur budgets (design.md §43: avoid excessive blur).
abstract final class AppBlur {
  static const double card = 10;
  static const double background = 0; // reserved; image overlay preferred
}

/// Opacity tokens for glass surfaces and the atmospheric overlay.
abstract final class AppOpacity {
  static const double overlay = 0.55;
  static const double backgroundImage = 0.32;
  static const double disabled = 0.45;
}
