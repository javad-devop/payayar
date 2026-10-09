import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/data/repositories.dart' show FlashcardWithBox;
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/glass_card.dart';
import 'ai_flashcard_dialog.dart';
import 'flashcard_dialog.dart';
import 'flashcard_review_sheet.dart';

/// Study-page card for HANDOFF §45: how many cards are due today plus
/// entries to the review session, the add dialog and the management
/// list. Spaced repetition state lives in `ReviewItems` — this widget
/// only renders [dueFlashcardsProvider] / [allFlashcardsProvider].
class FlashcardsCard extends ConsumerWidget {
  const FlashcardsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final due = ref.watch(dueFlashcardsProvider).value ?? const [];
    final all =
        ref.watch(allFlashcardsProvider).value ?? const <FlashcardWithBox>[];

    if (all.isEmpty) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.flashcard_empty_title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.flashcard_empty_desc),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: l10n.flashcard_add,
              icon: Icons.add,
              onPressed: () => FlashcardDialog.show(context),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: l10n.ai_makeCards,
              icon: Icons.auto_awesome_outlined,
              onPressed: () => AiFlashcardDialog.show(context),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.flashcard_title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l10n.flashcard_manage,
                icon: const Icon(Icons.style_outlined),
                onPressed: () => _showManage(context, l10n),
              ),
              IconButton(
                tooltip: l10n.flashcard_add,
                icon: const Icon(Icons.add),
                onPressed: () => FlashcardDialog.show(context),
              ),
              IconButton(
                tooltip: l10n.ai_makeCards,
                icon: const Icon(Icons.auto_awesome_outlined),
                onPressed: () => AiFlashcardDialog.show(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            due.isEmpty ? l10n.flashcard_dueNone : l10n.flashcard_due(due.length),
          ),
          if (due.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: l10n.flashcard_review,
              icon: Icons.play_arrow_rounded,
              onPressed: () => FlashcardReviewSheet.show(context, due),
            ),
          ],
        ],
      ),
    );
  }

  /// Management list: every card with its box, delete one at a time.
  void _showManage(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.6,
          child: Consumer(
            builder: (context, ref, _) {
              final all = ref.watch(allFlashcardsProvider).value ??
                  const <FlashcardWithBox>[];
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                children: [
                  Text(
                    l10n.flashcard_manage,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final item in all)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.card.front),
                      subtitle: Text(
                        '${l10n.flashcard_box(item.box)} · ${item.card.back}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        tooltip: l10n.flashcard_delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(l10n.flashcard_delete),
                              content: Text(item.card.front),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: Text(l10n.common_cancel),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  child: Text(l10n.common_delete),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
                          await ref
                              .read(flashcardRepositoryProvider)
                              .deleteCard(item.card.id);
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
