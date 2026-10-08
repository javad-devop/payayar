import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_buttons.dart';

/// AI suggestion presentation (design.md §12): AI output always looks
/// like a *suggestion* until the user applies, edits or rejects it.
/// Never render it as something the AI already changed.
class AISuggestionCard extends StatelessWidget {
  const AISuggestionCard({
    super.key,
    required this.title,
    required this.body,
    required this.applyLabel,
    required this.editLabel,
    required this.rejectLabel,
    this.onApply,
    this.onEdit,
    this.onReject,
  });

  final String title;
  final Widget body;
  final String applyLabel;
  final String editLabel;
  final String rejectLabel;
  final VoidCallback? onApply;
  final VoidCallback? onEdit;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.ai.withValues(alpha: 0.12)
            : AppColors.ai.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.ai.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined, size: 16, color: AppColors.ai),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: text.labelLarge!.copyWith(
                    color: isDark ? AppColors.ai : AppColors.aiStrong,
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          body,
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: applyLabel,
                onPressed: onApply,
                compact: true,
                variant: AppButtonVariant.primary,
              ),
              AppButton(
                label: editLabel,
                onPressed: onEdit,
                compact: true,
                variant: AppButtonVariant.secondary,
              ),
              AppButton(
                label: rejectLabel,
                onPressed: onReject,
                compact: true,
                variant: AppButtonVariant.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Contextual AI action shown inside a section header or card footer.
/// The label makes it clear the AI operates on the *current* context.
class AIContextAction extends StatelessWidget {
  const AIContextAction({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => AIButton(
        label: label,
        onPressed: onPressed,
        compact: true,
      );
}
