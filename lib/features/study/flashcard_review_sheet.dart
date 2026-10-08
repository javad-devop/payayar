import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/data/repositories.dart' show Flashcard;
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/glass_card.dart';

/// Review session for HANDOFF §45 — flip a card, grade it, next card.
/// Grading delegates to [FlashcardRepository.grade]; the queue is
/// snapshotted when the sheet opens so grading doesn't reshuffle it.
class FlashcardReviewSheet extends ConsumerStatefulWidget {
  const FlashcardReviewSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const FlashcardReviewSheet(),
      );

  @override
  ConsumerState<FlashcardReviewSheet> createState() =>
      _FlashcardReviewSheetState();
}

class _FlashcardReviewSheetState extends ConsumerState<FlashcardReviewSheet> {
  late final Future<List<Flashcard>> _dueFuture;
  List<Flashcard> _queue = const [];
  int _index = 0;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _dueFuture = ref.read(flashcardRepositoryProvider).watchDue().first;
  }

  Future<void> _grade(bool known) async {
    final card = _queue[_index];
    await ref.read(flashcardRepositoryProvider).grade(card.id, known: known);
    if (!mounted) return;
    setState(() {
      _index++;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: FutureBuilder<List<Flashcard>>(
          future: _dueFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final queue = snapshot.data ?? const <Flashcard>[];
            if (_queue.isEmpty && queue.isNotEmpty) _queue = queue;

            if (_queue.isEmpty) {
              return SizedBox(
                height: 160,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.flashcard_dueNone,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: l10n.common_close,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            }

            if (_index >= _queue.length) {
              return SizedBox(
                height: 240,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.celebration_outlined, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(l10n.flashcard_done,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: l10n.common_close,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            }

            final card = _queue[_index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.flashcard_remaining(_queue.length - _index),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          card.front,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (_revealed) ...[
                          const SizedBox(height: AppSpacing.lg),
                          const Divider(height: 1),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            card.back,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!_revealed)
                  PrimaryButton(
                    label: l10n.flashcard_reveal,
                    icon: Icons.visibility_outlined,
                    onPressed: () => setState(() => _revealed = true),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: l10n.flashcard_forgot,
                          onPressed: () => _grade(false),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PrimaryButton(
                          label: l10n.flashcard_knew,
                          onPressed: () => _grade(true),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
