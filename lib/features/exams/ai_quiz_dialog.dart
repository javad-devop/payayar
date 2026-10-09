import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_assist.dart';
import '../../core/ai/ai_provider.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/util/shamsi.dart' show toFaDigits;
import '../../core/widgets/app_buttons.dart';

/// One AI-proposed multiple-choice question before the run starts.
typedef AiQuizQuestion = ({
  String question,
  List<String> options,
  int correct,
});

/// Parses the AI reply into quiz questions. Tolerates code fences and
/// prose (first `[` … last `]`); `correct` may be an int index, a digit
/// string or a letter (A–D). Invalid rows are dropped — AI output is
/// untrusted data (AGENTS.md §9).
List<AiQuizQuestion> parseAiQuiz(String raw) {
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

  final questions = <AiQuizQuestion>[];
  for (final item in decoded.take(20)) {
    if (item is! Map) continue;
    final question =
        (item['question'] ?? item['q'] ?? item['title'] ?? '')
            .toString()
            .trim();
    final rawOptions = item['options'] ?? item['choices'];
    if (question.isEmpty || rawOptions is! List) continue;
    final options = rawOptions
        .map((o) => o.toString().trim())
        .where((o) => o.isNotEmpty)
        .take(6)
        .toList(growable: false);
    if (options.length < 2) continue;

    final correct = _correctIndex(item['correct'] ?? item['answer']);
    if (correct < 0 || correct >= options.length) continue;
    questions.add((
      question: question.length > 500
          ? question.substring(0, 500)
          : question,
      options: options,
      correct: correct,
    ));
  }
  return questions;
}

int _correctIndex(dynamic value) {
  if (value is int) return value;
  final text = value?.toString().trim() ?? '';
  if (RegExp(r'^[0-9]+$').hasMatch(text)) return int.parse(text);
  if (RegExp(r'^[a-dA-D]$').hasMatch(text)) {
    return text.toUpperCase().codeUnitAt(0) - 65;
  }
  return -1;
}

/// Interactive practice quiz: topic → AI generates MCQs → the user
/// answers step by step → score. The result is shown, never saved —
/// AI output never mutates local state on its own (AGENTS.md §9).
class AiQuizDialog extends ConsumerStatefulWidget {
  const AiQuizDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => const AiQuizDialog(),
      );

  @override
  ConsumerState<AiQuizDialog> createState() => _AiQuizDialogState();
}

class _AiQuizDialogState extends ConsumerState<AiQuizDialog> {
  final _topic = TextEditingController();
  bool _busy = false;
  List<AiQuizQuestion> _questions = const [];
  int _index = 0;
  int? _picked;
  int _correct = 0;
  bool _finished = false;

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
      _questions = const [];
    });
    try {
      final reply = await askSectionAi(ref, prompt: l10n.ai_quizPrompt(topic));
      final questions = parseAiQuiz(reply);
      if (!mounted) return;
      if (questions.isEmpty) {
        _snack(l10n.ai_cardsParse);
      } else {
        setState(() {
          _questions = questions;
          _index = 0;
          _picked = null;
          _correct = 0;
          _finished = false;
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

  void _next() {
    if (_picked == null) return;
    setState(() {
      if (_picked == _questions[_index].correct) _correct++;
      if (_index + 1 >= _questions.length) {
        _finished = true;
      } else {
        _index++;
        _picked = null;
      }
    });
  }

  void _restart() {
    setState(() {
      _questions = const [];
      _index = 0;
      _picked = null;
      _correct = 0;
      _finished = false;
      _topic.clear();
    });
  }

  String _scoreText(AppLocalizations l10n) {
    final total = _questions.length;
    final isFa = Localizations.localeOf(context).languageCode == 'fa';
    return l10n.ai_quizScore(
      isFa ? '${toFaDigits('$_correct')} از ${toFaDigits('$total')}'
          : '$_correct of $total',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget content;
    if (_busy) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.xl),
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.ai_thinking),
        ],
      );
    } else if (_questions.isEmpty) {
      content = Column(
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
              label: l10n.ai_quizTitle,
              icon: Icons.quiz_outlined,
              onPressed:
                  _topic.text.trim().isEmpty ? null : _generate,
            ),
          ),
        ],
      );
    } else if (_finished) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Icon(
            _correct == _questions.length
                ? Icons.emoji_events_outlined
                : Icons.check_circle_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _scoreText(l10n),
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: AppFontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SecondaryButton(
            label: l10n.ai_quizAgain,
            onPressed: _restart,
          ),
        ],
      );
    } else {
      final question = _questions[_index];
      content = SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${toFaDigits('${_index + 1}')} / ${toFaDigits('${_questions.length}')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: AppFontWeight.semiBold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < question.options.length; i++)
              RadioListTile<int>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: i,
                groupValue: _picked,
                onChanged: (v) => setState(() => _picked = v),
                title: Text(question.options[i]),
              ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Text(l10n.ai_quizTitle),
      content: content,
      actions: [
        SecondaryButton(
          label: l10n.common_cancel,
          onPressed: () => Navigator.pop(context),
        ),
        if (_questions.isNotEmpty && !_busy && !_finished)
          PrimaryButton(
            label: l10n.ai_quizNext,
            onPressed: _picked == null ? null : _next,
          ),
      ],
    );
  }
}
