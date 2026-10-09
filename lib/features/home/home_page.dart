import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/breakpoints.dart';
import '../../app/state/app_settings.dart';
import '../../app/state/navigation.dart';
import '../../core/ai/ai_assist.dart';
import '../../core/data/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables.dart' show TaskStatus, SessionType;
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/util/shamsi.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/quick_action.dart';
import '../../core/widgets/states.dart';
import '../../core/widgets/glass_card.dart';
import '../planning/planning_dashboard.dart';
import '../planning/task_dialog.dart';
import 'mini_calendar.dart';
import 'quick_note.dart';

/// Home is the command center (design.md §11): it summarizes today and
/// points at the next action. It must not become a wall of data, so in
/// this phase every module shows an intentional empty state instead of
/// invented numbers.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final width = MediaQuery.sizeOf(context).width;

    final greeting = settings.userName.isEmpty
        ? l10n.home_greeting
        : settings.isPersian
            ? '${l10n.home_greeting}، ${settings.userName}'
            : '${l10n.home_greeting}, ${settings.userName}';

    final cards = <Widget>[
      const _TodayPlanCard(),
      const _ProgressCard(),
      _CalendarCard(l10n: l10n),
      const _AiCard(),
      const _RecentActivitiesCard(),
      const _LifestyleCard(),
      const _RecentExamsCard(),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.huge,
      ),
      children: [
        // Greeting header with the global AI entry point — the advisor
        // is reachable from every section (PLAN.md phase 2).
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.home_greetingSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            AiAssistAction(
              ask: (aiRef) {
                final dash = aiRef.read(planningDashboardProvider);
                final study = aiRef.read(studySummaryProvider);
                final nextExam = aiRef.read(nextExamProvider);
                final summary = [
                  'today: ${dash.todayCompletedTasks}/${dash.todayPlannedTasks} tasks, '
                      '${dash.weekCompletedMinutes}/${dash.weekPlannedMinutes} min this week, '
                      'overdue: ${dash.overdueTasks}',
                  'study today: ${study.todayMinutes} min, streak: ${study.streakDays} days',
                  if (nextExam != null)
                    'next exam: ${nextExam.title} on '
                        '${nextExam.date.toIso8601String().substring(0, 10)}',
                ].join('\n');
                return askSectionAi(
                  aiRef,
                  prompt: l10n.ai_promptHome,
                  summary: summary,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Summary metrics — placeholders until real data arrives.
        _MetricsRow(width: width, l10n: l10n),
        const SizedBox(height: AppSpacing.xxl),

        // Card layout adapts to the viewport instead of being a
        // desktop grid squeezed onto a phone (design.md §36).
        if (Breakpoints.contentColumns(width) == 1) ...[
          for (final card in cards) ...[
            card,
            const SizedBox(height: AppSpacing.xl),
          ],
        ] else
          _TwoColumnLayout(cards: cards),

        // Quick, low-friction entry points (design.md §19).
        SectionHeader(title: l10n.home_quickActions_title),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _quickAction(
              context,
              ref,
              l10n.action_logStudy,
              Icons.menu_book_outlined,
              AppSection.study,
            ),
            _quickAction(
              context,
              ref,
              l10n.action_logTest,
              Icons.fact_check_outlined,
              AppSection.study,
            ),
            _quickAction(
              context,
              ref,
              l10n.action_logSleep,
              Icons.bedtime_outlined,
              AppSection.lifestyle,
            ),
            _quickAction(
              context,
              ref,
              l10n.action_logExercise,
              Icons.directions_run_outlined,
              AppSection.lifestyle,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Low-friction capture (design.md §12.1) — local persistence only.
        const QuickNoteCard(),
      ],
    );
  }

  Widget _quickAction(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    AppSection target,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    final tileWidth = Breakpoints.isMobile(width)
        ? (width - AppSpacing.xl * 2 - AppSpacing.md) / 2
        : 170.0;

    return SizedBox(
      width: tileWidth,
      child: QuickAction(
        label: label,
        icon: icon,
        onTap: () => ref.read(sectionProvider.notifier).goTo(target),
      ),
    );
  }
}

class _TwoColumnLayout extends StatelessWidget {
  const _TwoColumnLayout({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final split = (cards.length / 2).ceil();

    Widget column(List<Widget> children) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final child in children) ...[
              child,
              const SizedBox(height: AppSpacing.xl),
            ],
          ],
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: column(cards.take(split).toList())),
        const SizedBox(width: AppSpacing.xl),
        Expanded(child: column(cards.skip(split).toList())),
      ],
    );
  }
}

class _MetricsRow extends ConsumerWidget {
  const _MetricsRow({required this.width, required this.l10n});

  final double width;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(planningDashboardProvider);
    final study = ref.watch(studySummaryProvider);
    final nextExam = ref.watch(nextExamProvider);
    final columns = Breakpoints.metricColumns(width);

    String hours(int minutes) =>
        '${(minutes / 60).toStringAsFixed(1)}${l10n.planning_hoursUnit}';

    final examValue = nextExam == null
        ? '—'
        : shamsiShort(nextExam.date);

    final metrics = [
      (
        l10n.home_metric_plannedToday,
        hours(dash.todayPlannedMinutes),
        Icons.event_outlined,
        Theme.of(context).colorScheme.primary,
      ),
      (
        l10n.home_metric_completed,
        '${dash.todayCompletedTasks}/${dash.todayPlannedTasks}',
        Icons.check_circle_outline,
        AppColors.success,
      ),
      (
        l10n.home_metric_remaining,
        '${(dash.todayPlannedTasks - dash.todayCompletedTasks).clamp(0, 1 << 30)}',
        Icons.timelapse_outlined,
        AppColors.warning,
      ),
      (
        l10n.home_metric_nextExam,
        examValue,
        Icons.assignment_outlined,
        AppColors.ai,
      ),
      (
        l10n.home_metric_todayStudy,
        hours(study.todayMinutes),
        Icons.menu_book_outlined,
        Theme.of(context).colorScheme.primary,
      ),
      (
        l10n.home_metric_streak,
        '${study.streakDays}',
        Icons.local_fire_department_outlined,
        AppColors.warning,
      ),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < metrics.length; i += columns) {
      final chunk = metrics.sublist(
        i,
        i + columns > metrics.length ? metrics.length : i + columns,
      );
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              for (final (label, value, icon, color) in chunk)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: MetricCard(
                      label: label,
                      value: value,
                      icon: icon,
                      accent: color,
                    ),
                  ),
                ),
              // Keep the last row visually balanced.
              if (chunk.length < columns)
                for (var j = 0; j < columns - chunk.length; j++)
                  const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

class _TodayPlanCard extends ConsumerWidget {
  const _TodayPlanCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tasks = ref.watch(todayTasksProvider).value ?? const [];

    if (tasks.isEmpty) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: l10n.home_todayPlan_title),
            EmptyState(
              compact: true,
              icon: Icons.calendar_today_outlined,
              title: l10n.home_todayPlan_emptyTitle,
              description: l10n.home_todayPlan_emptyDesc,
              actionLabel: l10n.planning_task_add,
              onAction: () => TaskDialog.show(context),
            ),
          ],
        ),
      );
    }

    final dash = ref.watch(planningDashboardProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: l10n.home_todayPlan_title),
          ProgressRing(
            value: dash.completionRate,
            size: 96,
            strokeWidth: 8,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final task in tasks.take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    task.status == TaskStatus.completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: task.status == TaskStatus.completed
                        ? AppColors.success
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (tasks.length > 4)
            Text(
              '+${tasks.length - 4}',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }
}

class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dash = ref.watch(planningDashboardProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.home_progress_title),
          Center(
            child: ProgressRing(
              value: dash.completionRate,
              size: 132,
              label: l10n.home_metric_completed,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.home_calendar_title),
          const MiniCalendar(),
        ],
      ),
    );
  }
}

class _AiCard extends ConsumerWidget {
  const _AiCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return GlassCard(
      level: GlassLevel.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined, size: 18, color: AppColors.ai),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.home_ai_title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.home_ai_unconfigured,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _AiCta(
              label: l10n.home_ai_cta,
              onTap: () =>
                  ref.read(sectionProvider.notifier).goTo(AppSection.settings),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCta extends StatelessWidget {
  const _AiCta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.ai.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: AppColors.ai.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings_outlined, size: 16, color: AppColors.ai),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.ai
                          : AppColors.aiStrong,
                      fontWeight: AppFontWeight.semiBold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivitiesCard extends ConsumerWidget {
  const _RecentActivitiesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(studySessionsProvider).value ?? const <StudySession>[];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: l10n.home_recentActivities_title),
          if (sessions.isEmpty)
            EmptyState(
              compact: true,
              icon: Icons.history,
              title: l10n.empty_study_title,
              description: l10n.empty_study_desc,
            )
          else
            for (final session in sessions.take(4))
              _SessionRow(session: session),
        ],
      ),
    );
  }
}

class _SessionRow extends ConsumerWidget {
  const _SessionRow({required this.session});

  final StudySession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];
    final subjectName = subjects
        .where((s) => s.id == session.subjectId)
        .firstOrNull
        ?.name;
    final minutes = session.end.difference(session.start).inMinutes;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            switch (session.type) {
              SessionType.learning => Icons.menu_book_outlined,
              SessionType.review => Icons.replay_outlined,
              SessionType.test => Icons.fact_check_outlined,
              SessionType.problemSolving => Icons.extension_outlined,
            },
            size: 16,
            color: scheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              subjectName ?? '—',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$minutes′',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _LifestyleCard extends ConsumerWidget {
  const _LifestyleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(lifestyleEntriesProvider).value ?? const <LifestyleEntry>[];
    final today = DateTime.now();
    final todayEntry = entries
        .where((e) =>
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day)
        .firstOrNull;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.home_lifestyle_title),
          if (todayEntry == null)
            EmptyState(
              compact: true,
              icon: Icons.favorite_outline,
              title: l10n.home_lifestyle_none,
              description: l10n.empty_lifestyle_desc,
            )
          else
            Row(
              children: [
                if (todayEntry.sleepMinutes != null)
                  _LifestyleStat(
                    icon: Icons.bedtime_outlined,
                    label: l10n.lifestyle_sleep,
                    value: '${(todayEntry.sleepMinutes! / 60).toStringAsFixed(1)}${l10n.planning_hoursUnit}',
                  ),
                if (todayEntry.exerciseMinutes != null) ...[
                  const SizedBox(width: AppSpacing.xl),
                  _LifestyleStat(
                    icon: Icons.directions_run_outlined,
                    label: l10n.lifestyle_exercise,
                    value: '${todayEntry.exerciseMinutes}′',
                  ),
                ],
                if (todayEntry.energy != null) ...[
                  const SizedBox(width: AppSpacing.xl),
                  _LifestyleStat(
                    icon: Icons.bolt_outlined,
                    label: l10n.lifestyle_energy,
                    value: '${todayEntry.energy}/5',
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _LifestyleStat extends StatelessWidget {
  const _LifestyleStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: scheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

class _RecentExamsCard extends ConsumerWidget {
  const _RecentExamsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final exams = ref.watch(examsProvider).value ?? const <Exam>[];
    final sorted = exams.toList()..sort((a, b) => b.date.compareTo(a.date));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: l10n.home_recentExams_title),
          if (sorted.isEmpty)
            EmptyState(
              compact: true,
              icon: Icons.assignment_outlined,
              title: l10n.empty_exams_title,
              description: l10n.empty_exams_desc,
              actionLabel: l10n.nav_exams,
              onAction: () =>
                  ref.read(sectionProvider.notifier).goTo(AppSection.exams),
            )
          else
            for (final exam in sorted.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 16,
                      color: AppColors.ai,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        exam.title,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      shamsiShort(exam.date),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
