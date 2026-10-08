import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_buttons.dart';

/// Add-card dialog for HANDOFF §45. Save stays disabled while either
/// side is empty — no error strings needed.
class FlashcardDialog extends ConsumerStatefulWidget {
  const FlashcardDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => const FlashcardDialog(),
      );

  @override
  ConsumerState<FlashcardDialog> createState() => _FlashcardDialogState();
}

class _FlashcardDialogState extends ConsumerState<FlashcardDialog> {
  final _front = TextEditingController();
  final _back = TextEditingController();

  @override
  void dispose() {
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _front.text.trim().isNotEmpty && _back.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_canSave) return;
    await ref.read(flashcardRepositoryProvider).addCard(
          front: _front.text.trim(),
          back: _back.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.flashcard_add),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _front,
              autofocus: true,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: l10n.flashcard_front,
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _back,
              maxLength: 2000,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.flashcard_back,
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        PrimaryButton(
          label: l10n.common_save,
          onPressed: _canSave ? _save : null,
        ),
      ],
    );
  }
}
