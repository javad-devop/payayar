import 'package:flutter/material.dart';

import 'tokens.dart';

/// The atmospheric background system (design.md §5 and §29).
///
/// The background is atmospheric, never content: a darkened, cool-blue
/// base with a controlled glow. A scenic image may be configured once,
/// centrally, through [backgroundImageAsset]; when no image is available
/// the widget falls back to the same dark navy visual system instead of
/// inventing a different theme.
///
/// Settings are centralized here on purpose so no individual screen can
/// change, remove or restyle the background treatment.
abstract final class AppBackgroundConfig {
  /// Optional scenic image asset. Keep `null` to use the gradient-only
  /// fallback — the approved direction must not be replaced by random
  /// stock imagery (design.md §29).
  static const String? backgroundImageAsset = null;

  /// Centralized treatment values (design.md §29: opacity, overlay and
  /// strength live in the design system, not inside screens).
  static const double imageOpacity = AppOpacity.backgroundImage;
  static const double overlayStrength = AppOpacity.overlay;

  static const List<Color> baseGradient = [
    Color(0xFF0A1729),
    Color(0xFF071426), // AppPalette.dark.background
    Color(0xFF050E1C),
  ];
}

class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base surface. Light mode keeps the same structure with a
        // brighter, calm navy-tinted gradient.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? AppBackgroundConfig.baseGradient
                  : const [
                      Color(0xFFF6F9FF),
                      Color(0xFFE9F0FA),
                      Color(0xFFDDE7F5),
                    ],
            ),
          ),
        ),

        // Controlled glow — one soft accent, never a neon effect.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.7, -0.9),
              radius: 1.1,
              colors: [Color(0x334F63F7), Color(0x004F63F7)],
            ),
          ),
        ),

        // Optional scenic image, kept subtle and behind everything.
        if (AppBackgroundConfig.backgroundImageAsset != null)
          Opacity(
            opacity: AppBackgroundConfig.imageOpacity,
            child: Image.asset(
              AppBackgroundConfig.backgroundImageAsset!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),

        // Dark translucent overlay that guarantees readability above
        // the image/gradient (design.md §5).
        if (isDark)
          ColoredBox(
            color: const Color(0xFF071426)
                .withValues(alpha: AppBackgroundConfig.overlayStrength),
          )
        else
          const SizedBox.shrink(),

        child,
      ],
    );
  }
}
