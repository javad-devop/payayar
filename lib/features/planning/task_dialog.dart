import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_buttons.dart';

/// Add / edit a plan task. All fields are manual — the student owns
/// the plan (AGENTS.md §2.3).
class TaskDialog extends ConsumerStatefulWidget {
  const TaskDialog({super.key, this.task, this.initialDate});

  final PlanTask? task;
  final DateTime? initialDate;

  static Future<bool?> show(BuildContext context,
      {PlanTask? task, DateTime? initialDate}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => TaskDialog(task: task, initialDate: initialDate),
    );
  }

  @override
  ConsumerState<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends ConsumerState<TaskDialog> {
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _duration;
  late DateTime _date;
  TimeOfDay? _start;
  Priority _priority = Priority.medium;
  int? _subjectId;
  int? _topicId;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
    _duration = TextEditingController(
      text: t?.durationMinutes?.toString() ?? '',
    );
    _date = t?.date ?? widget.initialDate ?? DateTime.now();
    _start = t?.startMinutes == null
        ? null
        : TimeOfDay(hour: t!.startMinutes! ~/ 60, minute: t.startMinutes! % 60);
    _priority = t?.priority ?? Priority.medium;
    _subjectId = t?.subjectId;
    _topicId = t?.topicId;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _duration.dispose();
    super.dispose();
  }

  bool get _isValid => _title.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_isValid) return;
    final repo = ref.read(planningRepositoryProvider);
    final startMinutes = _start == null
        ? null
        : _start!.hour * 60 + _start!.minute;
    final duration = int.tryParse(_duration.text.trim());

    if (widget.task == null) {
      await repo.addTask(PlanTasksCompanion.insert(
        title: _title.text.trim(),
        date: _date,
        subjectId: Value(_subjectId),
        topicId: Value(_topicId),
        startMinutes: Value(startMinutes),
        durationMinutes: Value(duration),
        priority: _priority,
        status: TaskStatus.notStarted,
        notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
      ));
    } else {
      await repo.updateTask(widget.task!.copyWith(
        title: _title.text.trim(),
        date: _date,
        subjectId: Value(_subjectId),
        topicId: Value(_topicId),
        startMinutes: Value(startMinutes),
        durationMinutes: Value(duration),
        priority: _priority,
        notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
      ));
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];
    final topics = ref.watch(allTopicsProvider).value ?? const <Topic>[];
    final subjectTopics =
        topics.where((t) => t.subjectId == _subjectId).toList();

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.panel),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      title: Text(
        widget.task == null ? l10n.planning_task_add : l10n.planning_task_edit,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                autofocus: widget.task == null,
                decoration: InputDecoration(
                  labelText: l10n.planning_task_title,
                  hintText: l10n.planning_task_titleHint,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<int?>(
                initialValue: _subjectId,
                decoration:
                    InputDecoration(labelText: l10n.planning_task_subject),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.planning_task_subjectNone),
                  ),
                  for (final s in subjects)
                    DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (value) => setState(() {
                  _subjectId = value;
                  _topicId = null;
                }),
              ),
              if (_subjectId != null) ...[
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<int?>(
                  initialValue: _topicId,
                  decoration:
                      InputDecoration(labelText: l10n.planning_task_topic),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.planning_task_topicNone),
                    ),
                    for (final t in subjectTopics)
                      DropdownMenuItem(value: t.id, child: Text(t.name)),
                  ],
                  onChanged: (value) => setState(() => _topicId = value),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: l10n.planning_task_date,
                      date: _date,
                      onPicked: (d) => setState(() => _date = d),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _TimeField(
                      label: l10n.planning_task_start,
                      time: _start,
                      onPicked: (t) => setState(() => _start = t),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _duration,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.planning_task_duration,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<Priority>(
                      initialValue: _priority,
                      decoration: InputDecoration(
                        labelText: l10n.planning_task_priority,
                      ),
                      items: [
                        (Priority.low, l10n.planning_priority_low),
                        (Priority.medium, l10n.planning_priority_medium),
                        (Priority.high, l10n.planning_priority_high),
                      ]
                          .map((o) => DropdownMenuItem(
                                value: o.$1,
                                child: Text(o.$2),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _priority = value ?? Priority.medium),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _notes,
                maxLines: 2,
                decoration:
                    InputDecoration(labelText: l10n.planning_task_notes),
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppButton(
          label: l10n.common_save,
          compact: true,
          onPressed: _isValid ? _save : null,
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(date.year - 2),
          lastDate: DateTime(date.year + 3),
        );
        if (picked != null) onPicked(picked);
      },
      child: Text(
        '$label: ${MaterialLocalizations.of(context).formatShortDate(date)}',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontFamily: locale == 'fa' ? appFontFamily : null),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.time,
    required this.onPicked,
  });

  final String label;
  final TimeOfDay? time;
  final ValueChanged<TimeOfDay?> onPicked;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
        );
        onPicked(picked);
      },
      child: Text(
        time == null
            ? label
            : '$label: ${time!.format(context)}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
