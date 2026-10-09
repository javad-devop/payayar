import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_assist.dart';
import '../../core/data/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/util/shamsi.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/states.dart';
import 'planning_dashboard.dart';
import 'task_dialog.dart';

/// The planning workspace (AGENTS.md §10): weekly grid, daily 24h
/// timeline, dashboard and manual mock-exam drafts.
class PlanningPage extends ConsumerStatefulWidget {
  const PlanningPage({super.key});

  @override
  ConsumerState<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends ConsumerState<PlanningPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      l10n.planning_tab_week,
      l10n.planning_tab_day,
      l10n.planning_tab_dashboard,
      l10n.planning_tab_mock,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.huge,
      ),
      children: [
        PageHeader(
          title: l10n.planning_title,
          actions: [
            PrimaryButton(
              label: l10n.planning_task_add,
              icon: Icons.add,
              onPressed: () => TaskDialog.show(context),
            ),
            // Contextual AI over plan + exam context only (AGENTS.md §7.A).
            AiAssistAction(
              ask: (aiRef) {
                final dash = aiRef.read(planningDashboardProvider);
                final tasks =
                    aiRef.read(planTasksProvider).value ?? const <PlanTask>[];
                final exams =
                    aiRef.read(examsProvider).value ?? const <Exam>[];
                final subjects =
                    aiRef.read(subjectsProvider).value ?? const <Subject>[];
                final summary = [
                  'subjects: ${subjects.map((s) => s.name).join(', ')}',
                  'today: ${dash.todayCompletedTasks}/${dash.todayPlannedTasks} tasks done, overdue: ${dash.overdueTasks}',
                  'week minutes: ${dash.weekCompletedMinutes}/${dash.weekPlannedMinutes}',
                  'upcoming exams: ${exams.map((e) => e.title).take(5).join(', ')}',
                  'total plan tasks: ${tasks.length}',
                ].join('\n');
                return askSectionAi(
                  aiRef,
                  prompt: l10n.ai_promptPlanning,
                  summary: summary,
                );
              },
            ),
          ],
        ),
        _SegmentedTabs(
          labels: tabs,
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: AppSpacing.xl),
        switch (_tab) {
          0 => const _WeeklyView(),
          1 => const _DailyView(),
          2 => const _DashboardView(),
          _ => const _MockExamView(),
        },
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(AppRadius.control),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index
                        ? scheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Text(
                    labels[i],
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: i == index
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                          fontWeight: i == index
                              ? AppFontWeight.semiBold
                              : AppFontWeight.medium,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Weekly view
// ---------------------------------------------------------------------

class _WeeklyView extends ConsumerStatefulWidget {
  const _WeeklyView();

  @override
  ConsumerState<_WeeklyView> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends ConsumerState<_WeeklyView> {
  late DateTime _weekStart = _startOfWeek(DateTime.now());

  static DateTime _startOfWeek(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    // Saturday is the first day of the week in the Iranian calendar.
    return day.subtract(Duration(days: (day.weekday + 1) % 7));
  }

  void _shift(int days) =>
      setState(() => _weekStart = _weekStart.add(Duration(days: days)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tasks = ref.watch(planTasksProvider).value ?? const <PlanTask>[];
    final weekEnd = _weekStart.add(const Duration(days: 7));
    final weekTasks = tasks
        .where((t) =>
            !t.date.isBefore(_weekStart) && t.date.isBefore(weekEnd))
        .toList();
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.planning_week_prev,
              onPressed: () => _shift(-7),
              icon: const Icon(Icons.chevron_right, size: 22),
            ),
            const Spacer(),
            TextButton(
              onPressed: () =>
                  setState(() => _weekStart = _startOfWeek(DateTime.now())),
              child: Text(l10n.planning_week_today),
            ),
            const Spacer(),
            IconButton(
              tooltip: l10n.planning_week_next,
              onPressed: () => _shift(7),
              icon: const Icon(Icons.chevron_left, size: 22),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (weekTasks.isEmpty)
          GlassCard(
            child: EmptyState(
              icon: Icons.calendar_month_outlined,
              title: l10n.empty_planning_title,
              description: l10n.empty_planning_desc,
              actionLabel: l10n.planning_task_add,
              onAction: () => TaskDialog.show(context, initialDate: _weekStart),
            ),
          )
        else if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: _DayColumn(
                      date: _weekStart.add(Duration(days: i)),
                      tasks: weekTasks,
                    ),
                  ),
                ),
            ],
          )
        else
          Column(
            children: [
              for (var i = 0; i < 7; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _DayColumn(
                    date: _weekStart.add(Duration(days: i)),
                    tasks: weekTasks,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DayColumn extends ConsumerWidget {
  const _DayColumn({required this.date, required this.tasks});

  final DateTime date;
  final List<PlanTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dayTasks = tasks
        .where((t) =>
            t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day)
        .toList();
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    final weekdayNames = [
      l10n.planning_week_today,
      '', '', '', '', '', '',
    ];

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
              horizontal: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isToday
                  ? scheme.primary.withValues(alpha: 0.16)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Text(
              shamsiDayLabel(date),
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: isToday ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: AppFontWeight.semiBold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (dayTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                l10n.planning_day_empty,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            )
          else
            for (final task in dayTasks)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _TaskCard(task: task, weekdayNames: weekdayNames),
              ),
          TextButton.icon(
            onPressed: () => TaskDialog.show(context, initialDate: date),
            icon: const Icon(Icons.add, size: 16),
            label: Text(
              l10n.common_add,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Task card (shared)
// ---------------------------------------------------------------------

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task, this.weekdayNames});

  final PlanTask task;
  final List<String>? weekdayNames;

  Color _priorityColor(BuildContext context) => switch (task.priority) {
        Priority.high => AppColors.error,
        Priority.medium => AppColors.warning,
        Priority.low => Theme.of(context).colorScheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];
    final subjectName = task.subjectId == null
        ? null
        : subjects.where((s) => s.id == task.subjectId).firstOrNull?.name;
    final done = task.status == TaskStatus.completed;
    final inactive = task.status == TaskStatus.cancelled ||
        task.status == TaskStatus.skipped ||
        task.status == TaskStatus.moved;

    final timeLabel = task.startMinutes == null
        ? ''
        : '${(task.startMinutes! ~/ 60).toString().padLeft(2, '0')}:${(task.startMinutes! % 60).toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () => _openMenu(context, ref, l10n),
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: done
              ? scheme.primary.withValues(alpha: 0.08)
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(
            color: inactive
                ? scheme.outlineVariant.withValues(alpha: 0.5)
                : scheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    final repo = ref.read(planningRepositoryProvider);
                    await repo.setStatus(
                      task.id,
                      done ? TaskStatus.notStarted : TaskStatus.completed,
                    );
                  },
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Icon(
                    done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: done ? AppColors.success : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          decoration:
                              done || inactive ? TextDecoration.lineThrough : null,
                          color: inactive
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _priorityColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                if (timeLabel.isNotEmpty)
                  _MetaChip(
                    icon: Icons.schedule,
                    text: timeLabel,
                  ),
                if (task.durationMinutes != null)
                  _MetaChip(
                    icon: Icons.timer_outlined,
                    text: '${task.durationMinutes}${l10n.planning_minutes}',
                  ),
                if (subjectName != null)
                  _MetaChip(icon: Icons.menu_book_outlined, text: subjectName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMenu(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final repo = ref.read(planningRepositoryProvider);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.planning_task_edit),
              onTap: () => Navigator.pop(sheetContext, 'edit'),
            ),
            if (task.status == TaskStatus.completed)
              ListTile(
                leading: const Icon(Icons.undo),
                title: Text(l10n.planning_task_reopen),
                onTap: () => Navigator.pop(sheetContext, 'reopen'),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.planning_task_complete),
                onTap: () => Navigator.pop(sheetContext, 'complete'),
              ),
              ListTile(
                leading: const Icon(Icons.event_repeat_outlined),
                title: Text(l10n.planning_task_moveTo),
                onTap: () => Navigator.pop(sheetContext, 'move'),
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: Text(l10n.planning_task_cancel),
                onTap: () => Navigator.pop(sheetContext, 'cancel'),
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: Text(l10n.planning_task_skip),
                onTap: () => Navigator.pop(sheetContext, 'skip'),
              ),
            ],
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(sheetContext).brightness == Brightness.dark
                    ? AppColors.error
                    : AppColors.errorStrong,
              ),
              title: Text(l10n.planning_task_delete),
              onTap: () => Navigator.pop(sheetContext, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;
    switch (action) {
      case 'edit':
        await TaskDialog.show(context, task: task);
      case 'complete':
        await repo.setStatus(task.id, TaskStatus.completed);
      case 'reopen':
        await repo.setStatus(task.id, TaskStatus.notStarted);
      case 'cancel':
        await repo.setStatus(task.id, TaskStatus.cancelled);
      case 'skip':
        await repo.setStatus(task.id, TaskStatus.skipped);
      case 'move':
        final picked = await showDatePicker(
          context: context,
          initialDate: task.date,
          firstDate: DateTime(task.date.year - 1),
          lastDate: DateTime(task.date.year + 2),
        );
        if (picked != null) await repo.moveTo(task.id, picked);
      case 'delete':
        final confirmed = await showConfirmDialog(
          context: context,
          title: l10n.planning_task_delete,
          message: l10n.planning_task_deleteConfirm,
          confirmLabel: l10n.common_delete,
          cancelLabel: l10n.common_cancel,
          destructive: true,
        );
        if (confirmed) await repo.deleteTask(task.id);
    }
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: scheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Daily 24h view
// ---------------------------------------------------------------------

class _DailyView extends ConsumerWidget {
  const _DailyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tasks = ref.watch(todayTasksProvider).value ?? const <PlanTask>[];
    final now = DateTime.now();
    final todayTasks = tasks
        .where((t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day)
        .toList()
      ..sort((a, b) =>
          (a.startMinutes ?? 24 * 60).compareTo(b.startMinutes ?? 24 * 60));

    if (todayTasks.isEmpty) {
      return GlassCard(
        child: EmptyState(
          icon: Icons.schedule_outlined,
          title: l10n.planning_day_empty,
          description: l10n.empty_planning_desc,
          actionLabel: l10n.planning_task_add,
          onAction: () => TaskDialog.show(context, initialDate: now),
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final task in todayTasks)
            _TimelineRow(
              task: task,
              isLast: task == todayTasks.last,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.task, required this.isLast});

  final PlanTask task;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final time = task.startMinutes == null
        ? '--:--'
        : '${(task.startMinutes! ~/ 60).toString().padLeft(2, '0')}:${(task.startMinutes! % 60).toString().padLeft(2, '0')}';
    final done = task.status == TaskStatus.completed;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                time,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: AppSpacing.lg),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.success : scheme.primary,
                  border: Border.all(color: scheme.outlineVariant),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: scheme.outlineVariant),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _TaskCard(task: task),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------

class _DashboardView extends ConsumerWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dash = ref.watch(planningDashboardProvider);

    if (dash.isEmpty) {
      return GlassCard(
        child: EmptyState(
          icon: Icons.insights_outlined,
          title: l10n.empty_planning_title,
          description: l10n.empty_planning_desc,
        ),
      );
    }

    String hours(int minutes) =>
        '${(minutes / 60).toStringAsFixed(1)} ${l10n.planning_hoursUnit}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          child: Row(
            children: [
              ProgressRing(
                value: dash.completionRate,
                size: 110,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashRow(
                        label: l10n.planning_dashboard_planned,
                        value: hours(dash.weekPlannedMinutes)),
                    _DashRow(
                        label: l10n.planning_dashboard_actual,
                        value: hours(dash.weekCompletedMinutes)),
                    _DashRow(
                        label: l10n.planning_dashboard_completion,
                        value:
                            '${(dash.completionRate * 100).round()}٪'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _DashTile(
                  icon: Icons.error_outline,
                  color: AppColors.warning,
                  label: l10n.planning_dashboard_overdue,
                  value: '${dash.overdueTasks}',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _DashTile(
                  icon: Icons.today_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  label: l10n.planning_dashboard_today,
                  value:
                      '${dash.todayCompletedTasks}/${dash.todayPlannedTasks}',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _DashTile(
                  icon: Icons.upcoming_outlined,
                  color: AppColors.ai,
                  label: l10n.planning_dashboard_upcoming,
                  value: '${dash.upcomingTasks}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashRow extends StatelessWidget {
  const _DashRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  const _DashTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: AppFontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Mock exams
// ---------------------------------------------------------------------

class _MockExamView extends ConsumerWidget {
  const _MockExamView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final exams = ref.watch(examsProvider).value ?? const <Exam>[];
    final mocks = exams.where((e) => e.type == ExamType.mock).toList();
    final now = DateTime.now();
    final upcoming = mocks.where((e) => !e.date.isBefore(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final past = mocks.where((e) => e.date.isBefore(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.planning_mock_desc,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: l10n.planning_mock_add,
          icon: Icons.add,
          onPressed: () => _addMock(context),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (mocks.isEmpty)
          GlassCard(
            child: EmptyState(
              icon: Icons.quiz_outlined,
              title: l10n.empty_exams_title,
              description: l10n.empty_exams_desc,
              actionLabel: l10n.planning_mock_add,
              onAction: () => _addMock(context),
            ),
          )
        else ...[
          if (upcoming.isNotEmpty) ...[
            _SectionLabel(l10n.exams_upcoming),
            for (final exam in upcoming)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _MockExamCard(exam: exam),
              ),
          ],
          if (past.isNotEmpty) ...[
            _SectionLabel(l10n.exams_past),
            for (final exam in past)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _MockExamCard(exam: exam),
              ),
          ],
        ],
      ],
    );
  }

  Future<void> _addMock(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _MockExamDialog(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: AppFontWeight.semiBold,
            ),
      ),
    );
  }
}

class _MockExamCard extends ConsumerWidget {
  const _MockExamCard({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () {},
      child: Row(
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
              toFaDigits('${toShamsi(exam.date).day}'),
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
                  exam.title,
                  style: Theme.of(context).textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${shamsiShort(exam.date)}'
                      '${exam.description == null ? '' : ' · ${exam.description}'}',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: scheme.onSurfaceVariant,
            onPressed: () async {
              final l10n = AppLocalizations.of(context);
              final repo = ref.read(examRepositoryProvider);
              final confirmed = await showConfirmDialog(
                context: context,
                title: l10n.planning_task_delete,
                message: l10n.exams_deleteConfirm,
                confirmLabel: l10n.common_delete,
                cancelLabel: l10n.common_cancel,
                destructive: true,
              );
              if (confirmed) await repo.deleteExam(exam.id);
            },
          ),
        ],
      ),
    );
  }
}

class _MockExamDialog extends ConsumerStatefulWidget {
  const _MockExamDialog();

  @override
  ConsumerState<_MockExamDialog> createState() => _MockExamDialogState();
}

class _MockExamDialogState extends ConsumerState<_MockExamDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  late DateTime _date = DateTime.now().add(const Duration(days: 14));

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final repo = ref.read(examRepositoryProvider);
    try {
      await repo.addExam(
        title: title,
        type: ExamType.mock,
        date: _date,
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
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
      title: Text(l10n.planning_mock_add,
          style: Theme.of(context).textTheme.titleLarge),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              // Bug 2: بدون rebuild دکمهٔ ذخیره هرگز فعال نمی‌شد
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.exams_examTitle,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Text(
                  '${l10n.exams_date}: ${shamsiLong(_date)}'),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _description,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.planning_mock_subjects,
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
          onPressed: _title.text.trim().isEmpty ? null : _save,
        ),
      ],
    );
  }
}
