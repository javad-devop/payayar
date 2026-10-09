import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Surface levels (design.md §7): primary, secondary and inset.
/// Every card in the product uses this component instead of inventing
/// a new card style, so the UI stays one designed product.
enum GlassLevel { primary, secondary, inset }

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.level = GlassLevel.primary,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final GlassLevel level;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final Color fill;
    final Color border;

    switch (level) {
      case GlassLevel.primary:
        fill = isDark
            ? scheme.surface.withValues(alpha: 0.86)
            : scheme.surface.withValues(alpha: 0.94);
        border = palette.outlineVariant;
      case GlassLevel.secondary:
        fill = isDark
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.72)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.9);
        border = palette.outlineVariant;
      case GlassLevel.inset:
        fill = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04);
        border = palette.outlineVariant;
    }

    final radius = BorderRadius.circular(borderRadius ?? AppRadius.card);

    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(color: border),
        // Soft-UI shadows: layered, low-alpha, no hard edges (plan item 1).
        boxShadow: switch ((isDark, level)) {
          (true, GlassLevel.primary) => const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          (false, GlassLevel.primary) => const [
              BoxShadow(color: Color(0x0F071426), blurRadius: 2, offset: Offset(0, 1)),
              BoxShadow(color: Color(0x14071426), blurRadius: 12, offset: Offset(0, 4)),
            ],
          (false, GlassLevel.secondary) => const [
              BoxShadow(color: Color(0x0A071426), blurRadius: 3, offset: Offset(0, 1)),
            ],
          _ => null,
        },
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      ),
    );
  }
}
