import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_assist.dart';
import '../../core/data/providers.dart';
import '../../core/data/repositories.dart'
    show SessionType, Priority, TopicStatus;
import '../../core/database/app_database.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/util/shamsi.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/states.dart';
import 'flashcards_card.dart';
import 'focus_timer_card.dart';

/// Study section (AGENTS.md §13): subject tree with topics,
/// subtopics, mastery and study-session history. Subjects are fully
/// user-defined — nothing is hard-coded.
class StudyPage extends ConsumerWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.huge,
      ),
      children: [
        PageHeader(
          title: l10n.study_title,
          actions: [
            PrimaryButton(
              label: l10n.study_addSubject,
              icon: Icons.add,
              onPressed: () => _SubjectDialog.show(context),
            ),
            // Contextual AI over study data only (AGENTS.md §7.A).
            AiAssistAction(
              ask: (aiRef) {
                final subjects =
                    aiRef.read(subjectsProvider).value ?? const [];
                final topics = aiRef.read(allTopicsProvider).value ?? const [];
                final due = aiRef.read(dueFlashcardsProvider).value ?? const [];
                final summary = [
                  'subjects: ${subjects.map((s) => s.name).join(', ')}',
                  'topics: ${topics.length}',
                  'due flashcards: ${due.length}',
                ].join('\n');
                return askSectionAi(
                  aiRef,
                  prompt: l10n.ai_promptStudy,
                  summary: summary,
                );
              },
            ),
          ],
        ),
        // Focus / Pomodoro session (AGENTS.md §44). App-scoped state, so
        // leaving this page never interrupts a running session (§44.4).
        const FocusTimerCard(),
        const SizedBox(height: AppSpacing.lg),
        // Spaced-repetition queue + management (HANDOFF §45).
        const FlashcardsCard(),
        const SizedBox(height: AppSpacing.lg),
        if (subjects.isEmpty)
          GlassCard(
            child: EmptyState(
              icon: Icons.menu_book_outlined,
              title: l10n.empty_topics_title,
              description: l10n.empty_topics_desc,
              actionLabel: l10n.study_addSubject,
              onAction: () => _SubjectDialog.show(context),
            ),
          )
        else
          for (final subject in subjects)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _SubjectCard(subject: subject),
            ),
      ],
    );
  }
}

class _SubjectCard extends ConsumerStatefulWidget {
  const _SubjectCard({required this.subject});

  final Subject subject;

  @override
  ConsumerState<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends ConsumerState<_SubjectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final topics = ref.watch(allTopicsProvider).value ?? const <Topic>[];
    final subjectTopics = topics
        .where((t) => t.subjectId == widget.subject.id && t.parentTopicId == null)
        .toList();

    return GlassCard(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Text(
                  widget.subject.name.isEmpty
                      ? '؟'
                      : widget.subject.name.characters.first,
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
                      widget.subject.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (widget.subject.category != null)
                      Text(
                        widget.subject.category!,
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
                child: Icon(
                  Icons.expand_more,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: AppSpacing.lg),
            for (final topic in subjectTopics)
              _TopicRow(topic: topic, depth: 0),
            TextButton.icon(
              onPressed: () => _TopicDialog.show(
                context,
                subjectId: widget.subject.id,
              ),
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.study_addTopic),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopicRow extends ConsumerStatefulWidget {
  const _TopicRow({required this.topic, required this.depth});

  final Topic topic;
  final int depth;

  @override
  ConsumerState<_TopicRow> createState() => _TopicRowState();
}

class _TopicRowState extends ConsumerState<_TopicRow> {
  bool _open = false;

  Color get _statusColor => switch (widget.topic.status) {
        TopicStatus.notStarted => AppColors.warning,
        TopicStatus.learning => Theme.of(context).colorScheme.primary,
        TopicStatus.reviewing => AppColors.ai,
        TopicStatus.mastered => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final topics = ref.watch(allTopicsProvider).value ?? const <Topic>[];
    final children = topics
        .where((t) => t.parentTopicId == widget.topic.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(AppRadius.control),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ).copyWith(
              left: AppSpacing.sm + widget.depth * AppSpacing.xxl,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: 8,
                  color: _statusColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.topic.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 64,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: widget.topic.mastery / 100,
                      minHeight: 4,
                      backgroundColor: scheme.outlineVariant,
                      color: _statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${widget.topic.mastery}٪',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        if (_open) ...[
          _TopicDetail(topic: widget.topic),
          for (final child in children)
            _TopicRow(topic: child, depth: widget.depth + 1),
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xxl + widget.depth * AppSpacing.xxl,
            ),
            child: TextButton.icon(
              onPressed: () => _TopicDialog.show(
                context,
                subjectId: widget.topic.subjectId,
                parentId: widget.topic.id,
              ),
              icon: const Icon(Icons.add, size: 14),
              label: Text(
                l10n.study_addSubtopic,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TopicDetail extends ConsumerStatefulWidget {
  const _TopicDetail({required this.topic});

  final Topic topic;

  @override
  ConsumerState<_TopicDetail> createState() => _TopicDetailState();
}

class _TopicDetailState extends ConsumerState<_TopicDetail> {
  late double _mastery = widget.topic.mastery.toDouble();
  late int _difficulty = widget.topic.difficulty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sessions = ref.watch(studySessionsProvider).value ?? const <StudySession>[];
    final topicSessions = sessions
        .where((s) => s.topicId == widget.topic.id)
        .toList()
      ..sort((a, b) => b.start.compareTo(a.start));
    final totalMinutes = topicSessions.fold<int>(
      0,
      (sum, s) => sum + s.end.difference(s.start).inMinutes,
    );

    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<TopicStatus>(
            initialValue: widget.topic.status,
            decoration: InputDecoration(
              labelText: l10n.study_topicStatus,
              isDense: true,
            ),
            items: [
              (TopicStatus.notStarted, l10n.study_status_notStarted),
              (TopicStatus.learning, l10n.study_status_learning),
              (TopicStatus.reviewing, l10n.study_status_reviewing),
              (TopicStatus.mastered, l10n.study_status_mastered),
            ]
                .map((o) => DropdownMenuItem(
                      value: o.$1,
                      child: Text(o.$2),
                    ))
                .toList(),
            onChanged: (value) async {
              if (value == null) return;
              final repo = ref.read(studyRepositoryProvider);
              await repo.updateTopic(
                widget.topic.copyWith(status: value),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  l10n.study_mastery,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _mastery,
                  max: 100,
                  divisions: 20,
                  label: '${_mastery.round()}٪',
                  onChanged: (value) => setState(() => _mastery = value),
                  onChangeEnd: (value) async {
                    final repo = ref.read(studyRepositoryProvider);
                    await repo.updateTopic(
                      widget.topic.copyWith(mastery: value.round()),
                    );
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  l10n.study_difficulty,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _difficulty.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '$_difficulty',
                  onChanged: (value) => setState(() => _difficulty = value.round()),
                  onChangeEnd: (value) async {
                    final repo = ref.read(studyRepositoryProvider);
                    await repo.updateTopic(
                      widget.topic.copyWith(difficulty: value.round()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: l10n.study_session_add,
                  icon: Icons.play_arrow,
                  onPressed: () => _SessionDialog.show(
                    context,
                    subjectId: widget.topic.subjectId,
                    topicId: widget.topic.id,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                tooltip: l10n.study_deleteTopic,
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.error,
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context: context,
                    title: l10n.study_deleteTopic,
                    message: l10n.study_deleteTopicConfirm,
                    confirmLabel: l10n.common_delete,
                    cancelLabel: l10n.common_cancel,
                    destructive: true,
                  );
                  if (confirmed && context.mounted) {
                    await ref
                        .read(studyRepositoryProvider)
                        .deleteTopic(widget.topic.id);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${l10n.study_sessionsTotal}: ${l10n.planning_hoursUnit == 'h' ? (totalMinutes / 60).toStringAsFixed(1) : (totalMinutes / 60).toStringAsFixed(1)} ${l10n.planning_hoursUnit} · ${topicSessions.length} جلسه',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Dialogs
// ---------------------------------------------------------------------

class _SubjectDialog extends ConsumerStatefulWidget {
  const _SubjectDialog();

  static Future<void> show(BuildContext context) =>
      showDialog(context: context, builder: (_) => const _SubjectDialog());

  @override
  ConsumerState<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends ConsumerState<_SubjectDialog> {
  final _name = TextEditingController();
  final _category = TextEditingController();
  late final Priority _priority = Priority.medium;

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final repo = ref.read(studyRepositoryProvider);
    try {
      await repo.addSubject(
        name,
        category: _category.text.trim().isEmpty ? null : _category.text.trim(),
        priority: _priority,
      );
    } catch (_) {
      // Bug 1: خطا دیگر بی‌صدا بلعیده نمی‌شود — به کاربر نمایش داده می‌شود
      // (AGENTS.md §20: حالت خطا باید آشکار باشد).
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.common_errorTitle} — ${l10n.common_errorDesc}')),
      );
      return; // دیالوگ باز می‌ماند تا کاربر دوباره تلاش کند
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
      title: Text(l10n.study_addSubject,
          style: Theme.of(context).textTheme.titleLarge),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              // Bug 1: بدون rebuild، دکمهٔ ذخیره هرگز فعال نمی‌شد
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.study_subjectName,
                hintText: l10n.study_subjectNameHint,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _category,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.study_subjectCategory,
              ),
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
          onPressed: _name.text.trim().isEmpty ? null : _save,
        ),
      ],
    );
  }
}

class _TopicDialog extends ConsumerStatefulWidget {
  const _TopicDialog({required this.subjectId, this.parentId});

  final int subjectId;
  final int? parentId;

  static Future<void> show(
    BuildContext context, {
    required int subjectId,
    int? parentId,
  }) =>
      showDialog(
        context: context,
        builder: (_) => _TopicDialog(subjectId: subjectId, parentId: parentId),
      );

  @override
  ConsumerState<_TopicDialog> createState() => _TopicDialogState();
}

class _TopicDialogState extends ConsumerState<_TopicDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final repo = ref.read(studyRepositoryProvider);
    try {
      await repo.addTopic(
        subjectId: widget.subjectId,
        name: name,
        parentTopicId: widget.parentId,
      );
    } catch (_) {
      // Bug 2: نمایش خطای آشکار به‌جای سکوت (AGENTS.md §20).
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
        widget.parentId == null ? l10n.study_addTopic : l10n.study_addSubtopic,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SizedBox(
        width: 360,
        child: TextField(
          controller: _name,
          autofocus: true,
          // Bug 2: بدون rebuild دکمهٔ ذخیره هرگز فعال نمی‌شد
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: l10n.study_topicName),
          onSubmitted: (_) => _save(),
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
          onPressed: _name.text.trim().isEmpty ? null : _save,
        ),
      ],
    );
  }
}

class _SessionDialog extends ConsumerStatefulWidget {
  const _SessionDialog({required this.subjectId, required this.topicId});

  final int subjectId;
  final int topicId;

  static Future<void> show(
    BuildContext context, {
    required int subjectId,
    required int topicId,
  }) =>
      showDialog(
        context: context,
        builder: (_) =>
            _SessionDialog(subjectId: subjectId, topicId: topicId),
      );

  @override
  ConsumerState<_SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends ConsumerState<_SessionDialog> {
  late DateTime _start = DateTime.now().subtract(const Duration(hours: 1));
  late DateTime _end = DateTime.now();
  SessionType _type = SessionType.learning;

  Future<void> _save() async {
    if (!_end.isAfter(_start)) return;
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(studyRepositoryProvider);
    await repo.addSession(
      subjectId: widget.subjectId,
      topicId: widget.topicId,
      start: _start,
      end: _end,
      type: _type,
    );
    // Logged sessions are announced in the bell history (§43.1).
    await ref.read(notificationRepositoryProvider).addNotification(
          title: l10n.notif_sessionLogged(_end.difference(_start).inMinutes),
        );
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
      title: Text(l10n.study_session_add,
          style: Theme.of(context).textTheme.titleLarge),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<SessionType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.study_session_type,
              ),
              items: [
                (SessionType.learning, l10n.study_session_type_learning),
                (SessionType.review, l10n.study_session_type_review),
                (SessionType.test, l10n.study_session_type_test),
                (SessionType.problemSolving, l10n.study_session_type_problemSolving),
              ]
                  .map((o) => DropdownMenuItem(
                        value: o.$1,
                        child: Text(o.$2),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DateTimeField(
              label: l10n.study_session_start,
              value: _start,
              onChanged: (d) => setState(() => _start = d),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DateTimeField(
              label: l10n.study_session_end,
              value: _end,
              onChanged: (d) => setState(() => _end = d),
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
          onPressed: _end.isAfter(_start) ? _save : null,
        ),
      ],
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(value.year - 2),
          lastDate: DateTime(value.year + 2),
        );
        if (date == null || !context.mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
        );
        if (time == null) return;
        onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
      },
      child: Text(
        '$label: ${shamsiShort(value)} ${toFaDigits('${value.hour}:${value.minute.toString().padLeft(2, '0')}')}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
