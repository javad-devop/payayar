import 'package:flutter/material.dart';

import 'tokens.dart';

/// Theme factory for PAYAYAR (design.md §6, §8, §40).
///
/// Dark Mode is the approved reference direction; Light Mode is a real
/// adaptation of the same hierarchy rather than an inverted palette.
/// Both themes derive from the same token sets, so components never
/// carry separate Dark/Light implementations.
abstract final class AppTheme {
  static ThemeData get dark => darkFor(AccentTheme.defaultId);

  static ThemeData get light => lightFor(AccentTheme.defaultId);

  /// Dark palette for one of the six selectable accent themes.
  static ThemeData darkFor(String accentId) =>
      _build(AppPalette.dark, AccentTheme.byId(accentId));

  /// Light palette for one of the six selectable accent themes.
  static ThemeData lightFor(String accentId) =>
      _build(AppPalette.light, AccentTheme.byId(accentId));

  static ThemeData _build(AppPalette palette, AccentTheme accent) {
    final isDark = palette.isDark;
    final seed = accent.seed;
    // Dark mode keeps navy ink (design.md reference); light mode flips
    // to navy ink on bright accents (amber) for readable buttons.
    final onPrimary = isDark || seed.computeLuminance() > 0.4
        ? const Color(0xFF071426)
        : Colors.white;

    final colorScheme = ColorScheme(
      brightness: palette.brightness,
      primary: seed,
      onPrimary: onPrimary,
      primaryContainer:
          isDark ? seed.withValues(alpha: 0.22) : Color.lerp(seed, Colors.white, 0.85)!,
      onPrimaryContainer: isDark
          ? Color.lerp(seed, Colors.white, 0.78)!
          : Color.lerp(seed, const Color(0xFF071426), 0.55)!,
      secondary: AppColors.ai,
      onSecondary: isDark ? const Color(0xFF071426) : Colors.white,
      secondaryContainer: AppColors.ai.withValues(alpha: isDark ? 0.22 : 0.16),
      onSecondaryContainer: isDark ? const Color(0xFFD6D1FF) : const Color(0xFF3A2F9E),
      tertiary: AppColors.success,
      onTertiary: isDark ? const Color(0xFF071426) : Colors.white,
      error: AppColors.error,
      onError: isDark ? const Color(0xFF071426) : Colors.white,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      surfaceContainerHighest: palette.surfaceSoft,
      outline: palette.textMuted,
      outlineVariant: palette.border,
      shadow: Colors.black,
      scrim: Colors.black.withValues(alpha: 0.4),
      inverseSurface: isDark ? const Color(0xFFF4F7FF) : const Color(0xFF071426),
      onInverseSurface: isDark ? const Color(0xFF071426) : const Color(0xFFF4F7FF),
      inversePrimary: isDark ? Color.lerp(seed, Colors.white, 0.35)! : seed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      fontFamily: appFontFamily,
      textTheme: _buildTextTheme(palette),
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.highlight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: TextStyle(
          color: palette.textMuted,
          fontWeight: AppFontWeight.regular,
          fontSize: AppTypeScale.body,
        ),
        labelStyle: TextStyle(
          color: palette.textSecondary,
          fontWeight: AppFontWeight.medium,
          fontSize: AppTypeScale.body,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: seed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: seed,
        selectionColor: seed.withValues(alpha: 0.32),
        selectionHandleColor: seed,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: seed,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.surfaceSoft,
        contentTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: AppTypeScale.body,
          fontWeight: AppFontWeight.regular,
        ),
      ),
    );
  }

  /// Weight-driven hierarchy (design.md §8): hierarchy comes from
  /// weight before size, most text stays Regular/Medium.
  static TextTheme _buildTextTheme(AppPalette palette) {
    TextStyle base(double fontSize, FontWeight weight, {double height = 1.45, Color? color}) {
      return TextStyle(
        fontFamily: appFontFamily,
        fontSize: fontSize,
        fontWeight: weight,
        height: height,
        color: color ?? palette.textPrimary,
      );
    }

    return TextTheme(
      displaySmall: base(AppTypeScale.display, AppFontWeight.bold, height: 1.25),
      headlineMedium: base(AppTypeScale.h1, AppFontWeight.bold, height: 1.3),
      headlineSmall: base(AppTypeScale.h2, AppFontWeight.bold, height: 1.3),
      titleLarge: base(AppTypeScale.title, AppFontWeight.semiBold, height: 1.35),
      titleMedium: base(AppTypeScale.body, AppFontWeight.semiBold),
      titleSmall: base(AppTypeScale.label, AppFontWeight.semiBold),
      bodyLarge: base(AppTypeScale.title, AppFontWeight.regular, height: 1.6),
      bodyMedium: base(AppTypeScale.body, AppFontWeight.regular),
      bodySmall: base(AppTypeScale.caption, AppFontWeight.regular, color: palette.textSecondary),
      labelLarge: base(AppTypeScale.body, AppFontWeight.medium),
      labelMedium: base(AppTypeScale.label, AppFontWeight.medium),
      labelSmall: base(AppTypeScale.caption, AppFontWeight.medium, color: palette.textMuted),
    );
  }
}
