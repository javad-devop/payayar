import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/ai/ai_assist.dart';
import '../../core/data/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/states.dart';

/// Exam section (AGENTS.md §14): manual exam creation, per-subject
/// results and historical analysis. Stored results stay authoritative.
class ExamsPage extends ConsumerWidget {
  const ExamsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final exams = ref.watch(examsProvider).value ?? const <Exam>[];
    final now = DateTime.now();
    final upcoming = exams.where((e) => !e.date.isBefore(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final past = exams.where((e) => e.date.isBefore(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.huge,
      ),
      children: [
        PageHeader(
          title: l10n.exams_title,
          actions: [
            PrimaryButton(
              label: l10n.exams_add,
              icon: Icons.add,
              onPressed: () => _ExamDialog.show(context),
            ),
            // Contextual AI over exam data only (AGENTS.md §7.A).
            AiAssistAction(
              ask: (aiRef) {
                final results =
                    aiRef.read(allExamResultsProvider).value ?? const [];
                final summary = [
                  'upcoming exams: ${upcoming
                      .map((e) => '${e.title} (${e.date.toIso8601String().split('T').first})')
                      .join('; ')}',
                  'past exams: ${past.take(5).map((e) => e.title).join(', ')}',
                  'results: ${results
                      .take(10)
                      .map((r) => 'correct ${r.correct} / wrong ${r.wrong}${r.score == null ? '' : ' / score ${r.score}'}')
                      .join('; ')}',
                ].join('\n');
                return askSectionAi(
                  aiRef,
                  prompt: l10n.ai_promptExams,
                  summary: summary,
                );
              },
            ),
          ],
        ),
        if (exams.isEmpty)
          GlassCard(
            child: EmptyState(
              icon: Icons.assignment_outlined,
              title: l10n.empty_exams_title,
              description: l10n.empty_exams_desc,
              actionLabel: l10n.exams_add,
              onAction: () => _ExamDialog.show(context),
            ),
          )
        else ...[
          if (upcoming.isNotEmpty) ...[
            _Label(l10n.exams_upcoming),
            for (final exam in upcoming)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _ExamCard(exam: exam),
              ),
          ],
          if (past.isNotEmpty) ...[
            _Label(l10n.exams_past),
            for (final exam in past)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _ExamCard(exam: exam),
              ),
          ],
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: AppFontWeight.semiBold,
            ),
      ),
    );
  }
}

class _ExamCard extends ConsumerStatefulWidget {
  const _ExamCard({required this.exam});

  final Exam exam;

  @override
  ConsumerState<_ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends ConsumerState<_ExamCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return GlassCard(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Text(
                  '${widget.exam.date.day}',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: scheme.primary,
                        fontWeight: AppFontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exam.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_typeLabel(l10n, widget.exam.type)} · ${widget.exam.date.year}/${widget.exam.date.month}/${widget.exam.date.day}',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: AppDurations.fast,
                child: Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: AppSpacing.lg),
            if (widget.exam.description != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Text(
                  widget.exam.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            _ExamResults(examId: widget.exam.id),
            const SizedBox(height: AppSpacing.lg),
            _ExamAnalysis(examId: widget.exam.id),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                SecondaryButton(
                  label: l10n.exams_result_add,
                  icon: Icons.add_chart,
                  onPressed: () => _ResultDialog.show(context, widget.exam),
                ),
                const SizedBox(width: AppSpacing.md),
                SecondaryButton(
                  label: l10n.common_edit,
                  icon: Icons.edit_outlined,
                  onPressed: () => _ExamDialog.show(context, exam: widget.exam),
                ),
                const SizedBox(width: AppSpacing.md),
                IconButton(
                  tooltip: l10n.common_delete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.error,
                  onPressed: () async {
                    final confirmed = await showConfirmDialog(
                      context: context,
                      title: l10n.common_delete,
                      message: l10n.exams_deleteConfirm,
                      confirmLabel: l10n.common_delete,
                      cancelLabel: l10n.common_cancel,
                      destructive: true,
                    );
                    if (confirmed && context.mounted) {
                      await ref.read(examRepositoryProvider).deleteExam(
                            widget.exam.id,
                          );
                    }
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _typeLabel(AppLocalizations l10n, ExamType type) => switch (type) {
        ExamType.mock => l10n.exams_type_mock,
        ExamType.school => l10n.exams_type_school,
        ExamType.personal => l10n.exams_type_personal,
        ExamType.other => l10n.exams_type_other,
      };
}

class _ExamResults extends ConsumerWidget {
  const _ExamResults({required this.examId});

  final int examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final db = ref.watch(databaseProvider);
    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];

    return StreamBuilder<List<ExamResult>>(
      stream: (db.select(db.examResults)
            ..where((r) => r.examId.equals(examId)))
          .watch(),
      builder: (context, snapshot) {
        final results = snapshot.data ?? const <ExamResult>[];
        if (results.isEmpty) {
          return Text(
            l10n.exams_analysis_noResults,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.exams_results,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: AppFontWeight.semiBold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final r in results)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.subjectId == null
                            ? l10n.exams_result_overall
                            : subjects
                                    .where((s) => s.id == r.subjectId)
                                    .firstOrNull
                                    ?.name ??
                                '—',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    _ResultStat(
                      color: AppColors.success,
                      value: '${r.correct}',
                      label: l10n.exams_result_correct,
                    ),
                    _ResultStat(
                      color: AppColors.error,
                      value: '${r.wrong}',
                      label: l10n.exams_result_wrong,
                    ),
                    _ResultStat(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      value: '${r.unanswered}',
                      label: l10n.exams_result_unanswered,
                    ),
                    if (r.score != null)
                      _ResultStat(
                        color: Theme.of(context).colorScheme.primary,
                        value: r.score!.toStringAsFixed(1),
                        label: l10n.exams_result_score,
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 14),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      onPressed: () =>
                          ref.read(examRepositoryProvider).deleteResult(r.id),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.color,
    required this.value,
    required this.label,
  });

  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: color,
                  fontWeight: AppFontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ExamAnalysis extends ConsumerWidget {
  const _ExamAnalysis({required this.examId});

  final int examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final db = ref.watch(databaseProvider);
    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];

    return StreamBuilder<List<ExamResult>>(
      stream: (db.select(db.examResults)
            ..where((r) => r.examId.equals(examId)))
          .watch(),
      builder: (context, snapshot) {
        final results = snapshot.data ?? const <ExamResult>[];
        final perSubject = results
            .where((r) => r.subjectId != null)
            .map((r) => (
                  name: subjects
                          .where((s) => s.id == r.subjectId)
                          .firstOrNull
                          ?.name ??
                      '—',
                  percent: _percent(r),
                ))
            .toList()
          ..sort((a, b) => b.percent.compareTo(a.percent));

        if (perSubject.length < 2) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.exams_analysis,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: AppFontWeight.semiBold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _AnalysisBox(
                    color: AppColors.success,
                    title: l10n.exams_analysis_strong,
                    names: perSubject.take(2).map((e) => e.name).toList(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _AnalysisBox(
                    color: AppColors.error,
                    title: l10n.exams_analysis_weak,
                    names: perSubject.reversed.take(2).map((e) => e.name).toList(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static double _percent(ExamResult r) {
    final total = r.correct + r.wrong + r.unanswered;
    if (total == 0) return 0;
    return (r.correct - r.wrong / 3) / total * 100;
  }
}

class _AnalysisBox extends StatelessWidget {
  const _AnalysisBox({
    required this.color,
    required this.title,
    required this.names,
  });

  final Color color;
  final String title;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: color,
                  fontWeight: AppFontWeight.semiBold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final n in names)
            Text(
              n,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Dialogs
// ---------------------------------------------------------------------

class _ExamDialog extends ConsumerStatefulWidget {
  const _ExamDialog({this.exam});

  final Exam? exam;

  static Future<void> show(BuildContext context, {Exam? exam}) =>
      showDialog(
        context: context,
        builder: (_) => _ExamDialog(exam: exam),
      );

  @override
  ConsumerState<_ExamDialog> createState() => _ExamDialogState();
}

class _ExamDialogState extends ConsumerState<_ExamDialog> {
  late final _title = TextEditingController(text: widget.exam?.title);
  late final _description =
      TextEditingController(text: widget.exam?.description);
  late final _duration = TextEditingController(
    text: widget.exam?.durationMinutes?.toString() ?? '',
  );
  late ExamType _type = widget.exam?.type ?? ExamType.mock;
  late DateTime _date = widget.exam?.date ?? DateTime.now();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final repo = ref.read(examRepositoryProvider);
    final duration = int.tryParse(_duration.text.trim());

    try {
      if (widget.exam == null) {
        await repo.addExam(
          title: title,
          type: _type,
          date: _date,
          durationMinutes: duration,
          description:
              _description.text.trim().isEmpty ? null : _description.text.trim(),
        );
      } else {
        await repo.updateExam(widget.exam!.copyWith(
          title: title,
          type: _type,
          date: _date,
          durationMinutes: Value(duration),
          description: Value(
            _description.text.trim().isEmpty ? null : _description.text.trim(),
          ),
        ));
      }
    } catch (_) {
      // Bug 2: خطای دیتابیس نباید بی‌صدا بلعیده شود (AGENTS.md §20).
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.common_errorTitle} — ${l10n.common_errorDesc}')),
      );
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.panel),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      title: Text(
        widget.exam == null ? l10n.exams_add : l10n.exams_edit,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              autofocus: widget.exam == null,
              // Bug 2: بدون rebuild دکمهٔ ذخیره هرگز فعال نمی‌شد
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.exams_examTitle),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<ExamType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.exams_type),
              items: [
                (ExamType.mock, l10n.exams_type_mock),
                (ExamType.school, l10n.exams_type_school),
                (ExamType.personal, l10n.exams_type_personal),
                (ExamType.other, l10n.exams_type_other),
              ]
                  .map((o) => DropdownMenuItem(
                        value: o.$1,
                        child: Text(o.$2),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(_date.year - 2),
                        lastDate: DateTime(_date.year + 3),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: Text(
                        '${l10n.exams_date}: ${_date.year}/${_date.month}/${_date.day}'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: l10n.exams_duration),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _description,
              maxLines: 2,
              decoration: InputDecoration(labelText: l10n.exams_description),
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          label: l10n.common_cancel,
          variant: AppButtonVariant.secondary,
          compact: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppButton(
          label: l10n.common_save,
          compact: true,
          onPressed: _title.text.trim().isEmpty ? null : _save,
        ),
      ],
    );
  }
}

class _ResultDialog extends ConsumerStatefulWidget {
  const _ResultDialog({required this.exam});

  final Exam exam;

  static Future<void> show(BuildContext context, Exam exam) =>
      showDialog(
        context: context,
        builder: (_) => _ResultDialog(exam: exam),
      );

  @override
  ConsumerState<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends ConsumerState<_ResultDialog> {
  int? _subjectId;
  final _correct = TextEditingController(text: '0');
  final _wrong = TextEditingController(text: '0');
  final _unanswered = TextEditingController(text: '0');
  final _score = TextEditingController();
  final _time = TextEditingController();

  @override
  void dispose() {
    _correct.dispose();
    _wrong.dispose();
    _unanswered.dispose();
    _score.dispose();
    _time.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = ref.read(examRepositoryProvider);
    final correct = int.tryParse(_correct.text.trim()) ?? 0;
    final wrong = int.tryParse(_wrong.text.trim()) ?? 0;
    final unanswered = int.tryParse(_unanswered.text.trim()) ?? 0;

    await repo.addResult(ExamResultsCompanion.insert(
      examId: widget.exam.id,
      subjectId: Value(_subjectId),
      correct: Value(correct),
      wrong: Value(wrong),
      unanswered: Value(unanswered),
      score: Value(double.tryParse(_score.text.trim())),
      timeSpentMinutes: Value(int.tryParse(_time.text.trim())),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.panel),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      title: Text(l10n.exams_result_add,
          style: Theme.of(context).textTheme.titleLarge),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int?>(
                initialValue: _subjectId,
                decoration:
                    InputDecoration(labelText: l10n.exams_result_subject),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.exams_result_overall),
                  ),
                  for (final s in subjects)
                    DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (value) => setState(() => _subjectId = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _correct,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.exams_result_correct,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _wrong,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: l10n.exams_result_wrong),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _unanswered,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.exams_result_unanswered,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _score,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: l10n.exams_result_score),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _time,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.exams_result_timeSpent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          label: l10n.common_cancel,
          variant: AppButtonVariant.secondary,
          compact: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppButton(
          label: l10n.common_save,
          compact: true,
          onPressed: _save,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Score trend chart (used by Exams and Reports)
// ---------------------------------------------------------------------

/// Historical score trend across exams with overall results.
class ScoreTrendChart extends ConsumerWidget {
  const ScoreTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final exams = ref.watch(examsProvider).value ?? const <Exam>[];
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<ExamResult>>(
      stream: db.select(db.examResults).watch(),
      builder: (context, snapshot) {
        final results = snapshot.data ?? const <ExamResult>[];
        final overall = <(Exam, double)>[];
        for (final exam in exams) {
          final r = results
              .where((r) => r.examId == exam.id && r.subjectId == null)
              .firstOrNull;
          if (r == null) continue;
          final total = r.correct + r.wrong + r.unanswered;
          if (total == 0) continue;
          overall.add((exam, (r.correct - r.wrong / 3) / total * 100));
        }
        overall.sort((a, b) => a.$1.date.compareTo(b.$1.date));

        if (overall.length < 2) {
          return EmptyState(
            compact: true,
            icon: Icons.show_chart,
            title: context.l10n.exams_analysis_noResults,
            description: context.l10n.reports_notEnoughData,
          );
        }

        return SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (v) => const FlLine(
                  color: Color(0x1AFFFFFF),
                  strokeWidth: 1,
                ),
              ),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < overall.length; i++)
                      FlSpot(i.toDouble(), overall[i].$2.clamp(0, 100)),
                  ],
                  isCurved: true,
                  color: scheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: scheme.primary.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
