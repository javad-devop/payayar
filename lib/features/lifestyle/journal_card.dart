import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/util/shamsi.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/glass_card.dart';

/// Journal section of the lifestyle page (phase 11): dated free-text
/// entries, newest first — local-only (HANDOFF offline rule).
class JournalCard extends ConsumerStatefulWidget {
  const JournalCard({super.key});

  @override
  ConsumerState<JournalCard> createState() => _JournalCardState();
}

class _JournalCardState extends ConsumerState<JournalCard> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final text = _text.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    await ref.read(journalRepositoryProvider).addEntry(
          date: DateTime(now.year, now.month, now.day),
          text: text,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.journal_added)));
  }

  void _openComposer() {
    final l10n = AppLocalizations.of(context);
    _text.clear();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.journal_add),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: _text,
            autofocus: true,
            maxLines: 6,
            maxLength: 4000,
            decoration: InputDecoration(
              hintText: l10n.journal_hint,
              counterText: '',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          PrimaryButton(
            label: l10n.common_confirm,
            onPressed: () {
              Navigator.pop(dialogContext);
              _save();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(journalEntriesProvider).value ?? const [];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.journal_title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: AppFontWeight.semiBold,
                      ),
                ),
              ),
              PrimaryButton(
                label: l10n.journal_add,
                icon: Icons.edit_outlined,
                onPressed: _openComposer,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            Text(
              l10n.journal_empty,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            for (final entry in entries) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.control),
                      ),
                      child: Text(
                        shamsiLong(entry.date),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        entry.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.common_delete,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => ref
                          .read(journalRepositoryProvider)
                          .deleteEntry(entry.id),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}
