import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Button geometry is shared across the product; only the color
/// treatment differs (design.md §18). AI actions keep the same
/// geometry with a subtle purple treatment — no separate AI button
/// language.
enum AppButtonVariant { primary, secondary, ai, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// When true the button fills its available width.
  final bool expand;

  /// Compact height for dense rows (suggestion cards, quick actions).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null;

    final Color background;
    final Color foreground;
    final BorderSide side;

    switch (variant) {
      case AppButtonVariant.primary:
        background = scheme.primary;
        foreground = scheme.onPrimary;
        side = BorderSide.none;
      case AppButtonVariant.secondary:
        background = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7);
        foreground = scheme.onSurface;
        side = BorderSide(color: scheme.outlineVariant);
      case AppButtonVariant.ai:
        background = isDark
            ? AppColors.ai.withValues(alpha: 0.16)
            : AppColors.ai.withValues(alpha: 0.10);
        foreground = isDark ? AppColors.ai : AppColors.aiStrong;
        side = BorderSide(color: AppColors.ai.withValues(alpha: 0.45));
      case AppButtonVariant.danger:
        background = isDark
            ? AppColors.error.withValues(alpha: 0.16)
            : AppColors.error.withValues(alpha: 0.10);
        foreground = isDark ? AppColors.error : AppColors.errorStrong;
        side = BorderSide(color: AppColors.error.withValues(alpha: 0.45));
    }

    final height = compact ? 34.0 : 44.0;
    final horizontal = compact ? AppSpacing.md : AppSpacing.xl;
    final textStyle = TextStyle(
      fontSize: compact ? AppTypeScale.label : AppTypeScale.body,
      fontWeight: AppFontWeight.semiBold,
      color: foreground,
      height: 1.2,
    );

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: compact ? 16 : 18, color: foreground),
          if (expand) const SizedBox(width: AppSpacing.sm) else const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis)),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : AppOpacity.disabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            height: height,
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: side.color, width: side.width),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Primary action (design.md §18).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) => AppButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        expand: expand,
        variant: AppButtonVariant.primary,
      );
}

/// Secondary action — lower-emphasis outlined/glass style.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) => AppButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        expand: expand,
        variant: AppButtonVariant.secondary,
      );
}

/// AI action — subtle purple, same geometry as everything else.
class AIButton extends StatelessWidget {
  const AIButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expand = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) => AppButton(
        label: label,
        onPressed: onPressed,
        icon: Icons.auto_awesome_outlined,
        expand: expand,
        compact: compact,
        variant: AppButtonVariant.ai,
      );
}
