import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_buttons.dart';

/// Confirmation for destructive actions (design.md §42): explain
/// exactly what will be removed, keep the destructive action visually
/// distinct, and never delete user data silently.
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

      return AlertDialog(
        backgroundColor: isDark ? scheme.surface : scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.panel),
          side: BorderSide(
            color: destructive ? AppColors.error.withValues(alpha: 0.45) : scheme.outlineVariant,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(dialogContext).textTheme.titleLarge,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            message,
            style: Theme.of(dialogContext).textTheme.bodyMedium!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        actions: [
          AppButton(
            label: cancelLabel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            variant: AppButtonVariant.secondary,
            compact: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            label: confirmLabel,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            variant: destructive ? AppButtonVariant.danger : AppButtonVariant.primary,
            compact: true,
          ),
        ],
      );
    },
  );

  return result ?? false;
}
