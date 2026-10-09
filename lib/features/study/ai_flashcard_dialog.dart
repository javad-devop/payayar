import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_assist.dart';
import '../../core/ai/ai_provider.dart';
import '../../core/data/providers.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/util/shamsi.dart' show toFaDigits;
import '../../core/widgets/app_buttons.dart';

/// One AI-proposed card before it is saved.
typedef AiCardDraft = ({String front, String back});

/// Parses the AI reply into card drafts: tolerates code fences and
/// surrounding prose — everything from the first `[` to the last `]` is
/// decoded as a JSON array of `{front|q|question, back|a|answer}` pairs.
/// Returns an empty list when nothing usable is found (AGENTS.md §9:
/// AI output is untrusted data — only validated rows reach the DB).
List<AiCardDraft> parseAiCards(String raw) {
  final cleaned = raw
      .replaceAll(RegExp(r'```[a-zA-Z]*'), '')
      .replaceAll('`', '')
      .trim();
  final start = cleaned.indexOf('[');
  final end = cleaned.lastIndexOf(']');
  if (start < 0 || end <= start) return [];

  final dynamic decoded;
  try {
    decoded = jsonDecode(cleaned.substring(start, end + 1));
  } on FormatException {
    return [];
  }
  if (decoded is! List) return [];

  final cards = <AiCardDraft>[];
  for (final item in decoded.take(20)) {
    if (item is! Map) continue;
    final front = (item['front'] ?? item['q'] ?? item['question'] ?? '')
        .toString()
        .trim();
    final back =
        (item['back'] ?? item['a'] ?? item['answer'] ?? '').toString().trim();
    if (front.isEmpty || back.isEmpty) continue;
    cards.add((
      front: front.length > 500 ? front.substring(0, 500) : front,
      back: back.length > 2000 ? back.substring(0, 2000) : back,
    ));
  }
  return cards;
}

/// Generate flashcards from a topic with the configured AI provider.
/// The user previews the drafts and saves them explicitly — the model
/// never writes to the database itself (AGENTS.md §9).
class AiFlashcardDialog extends ConsumerStatefulWidget {
  const AiFlashcardDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => const AiFlashcardDialog(),
      );

  @override
  ConsumerState<AiFlashcardDialog> createState() => _AiFlashcardDialogState();
}

class _AiFlashcardDialogState extends ConsumerState<AiFlashcardDialog> {
  final _topic = TextEditingController();
  bool _busy = false;
  List<AiCardDraft> _drafts = const [];
  final Set<int> _selected = <int>{};

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _generate() async {
    final topic = _topic.text.trim();
    if (topic.isEmpty || _busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _drafts = const [];
      _selected.clear();
    });
    try {
      final reply = await askSectionAi(
        ref,
        prompt: l10n.ai_makeCardsPrompt(topic),
      );
      final drafts = parseAiCards(reply);
      if (!mounted) return;
      if (drafts.isEmpty) {
        _snack(l10n.ai_cardsParse);
      } else {
        setState(() {
          _drafts = drafts;
          _selected.addAll(List.generate(drafts.length, (i) => i));
        });
      }
    } on AiException catch (e) {
      _snack(friendlyAiError(l10n, e.message));
    } catch (_) {
      _snack(l10n.ai_errorNetwork);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(flashcardRepositoryProvider);
    final toSave =
        _selected.map((i) => _drafts[i]).toList(growable: false);
    Navigator.pop(context);
    for (final card in toSave) {
      await repo.addCard(front: card.front, back: card.back);
    }
    // Best-effort confirmation after the dialog is gone.
    if (mounted) _snack(l10n.ai_cardsSaved(toSave.length));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.ai_makeCards),
      content: SizedBox(
        width: 420,
        child: _busy
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.ai_thinking),
                ],
              )
            : _drafts.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _topic,
                        autofocus: true,
                        maxLength: 120,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _generate(),
                        decoration: InputDecoration(
                          labelText: l10n.ai_cardsTopic,
                          helperText: l10n.ai_cardsHint,
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: l10n.ai_makeCards,
                          icon: Icons.auto_awesome_outlined,
                          onPressed: _topic.text.trim().isEmpty
                              ? null
                              : _generate,
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    height: 360,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: Text(
                            l10n.ai_cardsPreview(_drafts.length),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _drafts.length,
                            itemBuilder: (context, index) {
                              final card = _drafts[index];
                              return CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: _selected.contains(index),
                                onChanged: (checked) => setState(() {
                                  if (checked == true) {
                                    _selected.add(index);
                                  } else {
                                    _selected.remove(index);
                                  }
                                }),
                                title: Text(
                                  card.front,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontWeight: AppFontWeight.medium,
                                      ),
                                ),
                                subtitle: Text(
                                  card.back,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      actions: [
        SecondaryButton(
          label: l10n.common_cancel,
          onPressed: () => Navigator.pop(context),
        ),
        if (_drafts.isNotEmpty && !_busy)
          PrimaryButton(
            label: '${l10n.ai_cardsSave} (${toFaDigits('${_selected.length}')})',
            onPressed: _selected.isEmpty ? null : _save,
          ),
      ],
    );
  }
}
