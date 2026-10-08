import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/data/providers.dart';
import '../../core/data/repositories.dart' show SessionType;
import '../../core/database/app_database.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/states.dart';
import '../exams/exams_page.dart';
import '../planning/planning_dashboard.dart';

/// Reports (AGENTS.md §15): computed locally from stored data.
/// Not enough data = honest empty state; nothing is invented.
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  bool _isWeek = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.huge,
      ),
      children: [
        PageHeader(title: l10n.reports_title),
        _Segmented(
          labels: [l10n.reports_range_week, l10n.reports_range_month],
          index: _isWeek ? 0 : 1,
          onChanged: (i) => setState(() => _isWeek = i == 0),
        ),
        const SizedBox(height: AppSpacing.xl),
        _StudyReport(isWeek: _isWeek),
        const SizedBox(height: AppSpacing.lg),
        // Bug 3 (AGENTS.md §15): sleep / exercise / test-count charts.
        _SleepReport(isWeek: _isWeek),
        const SizedBox(height: AppSpacing.lg),
        _ExerciseReport(isWeek: _isWeek),
        const SizedBox(height: AppSpacing.lg),
        _TestCountReport(isWeek: _isWeek),
        const SizedBox(height: AppSpacing.lg),
        _SubjectDistributionReport(isWeek: _isWeek),
        const SizedBox(height: AppSpacing.lg),
        _PlanningReport(),
        const SizedBox(height: AppSpacing.lg),
        _MasteryReport(),
        const SizedBox(height: AppSpacing.lg),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reports_exams_scores,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const ScoreTrendChart(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
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
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? scheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Text(
                    labels[i],
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

DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

// ---------------------------------------------------------------------
// Study report
// ---------------------------------------------------------------------

class _StudyReport extends ConsumerWidget {
  const _StudyReport({required this.isWeek});

  final bool isWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(studySessionsProvider).value ?? const <StudySession>[];
    final now = _dayStart(DateTime.now());
    final days = isWeek ? 7 : 30;
    final start = now.subtract(Duration(days: days - 1));

    final inRange = sessions.where((s) => !s.start.isBefore(start)).toList();
    final totalMinutes = inRange.fold<int>(
      0,
      (sum, s) => sum + s.end.difference(s.start).inMinutes.clamp(0, 24 * 60),
    );

    // Daily buckets.
    final daily = List.filled(days, 0);
    for (final s in inRange) {
      final day = _dayStart(s.start);
      final index = day.difference(start).inDays;
      if (index >= 0 && index < days) {
        daily[index] += s.end.difference(s.start).inMinutes.clamp(0, 24 * 60);
      }
    }

    final hasData = totalMinutes > 0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.reports_study_daily,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: AppFontWeight.semiBold,
                      ),
                ),
              ),
              Text(
                '${l10n.reports_study_total}: ${(totalMinutes / 60).toStringAsFixed(1)}${l10n.planning_hoursUnit}',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (!hasData)
            EmptyState(
              compact: true,
              icon: Icons.show_chart,
              title: l10n.empty_reports_title,
              description: l10n.reports_notEnoughData,
            )
          else
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (var i = 0; i < days; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: daily[i] / 60.0,
                            width: isWeek ? 18 : 6,
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Subject distribution
// ---------------------------------------------------------------------

class _SubjectDistributionReport extends ConsumerWidget {
  const _SubjectDistributionReport({required this.isWeek});

  final bool isWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sessions = ref.watch(studySessionsProvider).value ?? const <StudySession>[];
    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];
    final start = _dayStart(DateTime.now())
        .subtract(Duration(days: isWeek ? 6 : 29));

    final perSubject = <int, int>{};
    for (final s in sessions) {
      if (s.start.isBefore(start)) continue;
      perSubject[s.subjectId] =
          (perSubject[s.subjectId] ?? 0) + s.end.difference(s.start).inMinutes;
    }

    if (perSubject.isEmpty) return const SizedBox.shrink();

    final entries = perSubject.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    const palette = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.ai,
      AppColors.error,
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reports_study_subjectDistribution,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: AppFontWeight.semiBold,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette[i % palette.length],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      subjects
                              .where((s) => s.id == entries[i].key)
                              .firstOrNull
                              ?.name ??
                          '—',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${(entries[i].value / 60).toStringAsFixed(1)}${l10n.planning_hoursUnit}',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '${(entries[i].value / total * 100).round()}٪',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: palette[i % palette.length],
                          fontWeight: AppFontWeight.semiBold,
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

// ---------------------------------------------------------------------
// Planning completion
// ---------------------------------------------------------------------

class _PlanningReport extends ConsumerWidget {
  const _PlanningReport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dash = ref.watch(planningDashboardProvider);

    if (dash.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reports_planning_completion,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: AppFontWeight.semiBold,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.reports_planning_plannedVsDone,
                  value:
                      '${dash.weekCompletedMinutes}/${dash.weekPlannedMinutes}′',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: l10n.planning_dashboard_completion,
                  value: '${(dash.completionRate * 100).round()}٪',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: l10n.planning_dashboard_overdue,
                  value: '${dash.overdueTasks}',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: color,
                fontWeight: AppFontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
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
// Topic mastery / weak topics
// ---------------------------------------------------------------------

class _MasteryReport extends ConsumerWidget {
  const _MasteryReport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final topics = ref.watch(allTopicsProvider).value ?? const <Topic>[];
    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];
    final weak = topics.where((t) => t.mastery < 50).toList()
      ..sort((a, b) => a.mastery.compareTo(b.mastery));

    if (topics.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reports_subjects_weak,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: AppFontWeight.semiBold,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (weak.isEmpty)
            Text(
              l10n.reports_notEnoughData,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            )
          else
            for (final topic in weak.take(8))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subjects
                                    .where((s) => s.id == topic.subjectId)
                                    .firstOrNull
                                    ?.name ??
                                '',
                            style:
                                Theme.of(context).textTheme.labelSmall!.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: topic.mastery / 100,
                          minHeight: 4,
                          backgroundColor: scheme.outlineVariant,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${topic.mastery}٪',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: AppColors.error,
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

// ---------------------------------------------------------------------
// Bug 3 — sleep / exercise / test-count charts (AGENTS.md §15)
// Source of truth is local SQLite; nothing here is invented.
// ---------------------------------------------------------------------

/// Shared card chrome for the three trend reports: title, one headline
/// metric, and an honest empty state when the range has no data.
class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.value,
    required this.hasData,
    required this.icon,
    required this.child,
  });

  final String title;
  final String value;
  final bool hasData;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: AppFontWeight.semiBold,
                      ),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (!hasData)
            EmptyState(
              compact: true,
              icon: icon,
              title: l10n.empty_reports_title,
              description: l10n.reports_notEnoughData,
            )
          else
            child,
        ],
      ),
    );
  }
}

/// Daily buckets for the selected range: index 0 = first day, length =
/// 7 or 30. Shared by all three charts so their axes stay comparable.
List<DateTime> _rangeStart(int days) => [
      for (var i = days - 1; i >= 0; i--)
        _dayStart(DateTime.now()).subtract(Duration(days: i)),
    ];

/// Sleep hours per day, from `lifestyle_entries.sleep_minutes`.
/// Reported as an average; only days the user actually logged count.
class _SleepReport extends ConsumerWidget {
  const _SleepReport({required this.isWeek});

  final bool isWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries =
        ref.watch(lifestyleEntriesProvider).value ?? const <LifestyleEntry>[];
    final days = isWeek ? 7 : 30;
    final start = _rangeStart(days);

    final daily = List<double?>.filled(days, null);
    for (final e in entries) {
      if (e.sleepMinutes == null) continue;
      final index = _dayStart(e.date).difference(start.first).inDays;
      if (index < 0 || index >= days) continue;
      daily[index] = e.sleepMinutes! / 60;
    }

    final recorded = daily.whereType<double>();
    final hasData = recorded.isNotEmpty;
    final avg =
        hasData ? recorded.reduce((a, b) => a + b) / recorded.length : 0.0;

    return _TrendCard(
      title: l10n.reports_sleep_daily,
      value:
          '${l10n.reports_sleep_avg}: ${avg.toStringAsFixed(1)}${l10n.planning_hoursUnit}',
      hasData: hasData,
      icon: Icons.nightlight_outlined,
      child: SizedBox(
        height: 180,
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
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < days; i++)
                    if (daily[i] != null) FlSpot(i.toDouble(), daily[i]!),
                ],
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Exercise minutes per day, from `lifestyle_entries.exercise_minutes`.
class _ExerciseReport extends ConsumerWidget {
  const _ExerciseReport({required this.isWeek});

  final bool isWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries =
        ref.watch(lifestyleEntriesProvider).value ?? const <LifestyleEntry>[];
    final days = isWeek ? 7 : 30;
    final start = _rangeStart(days);

    final daily = List.filled(days, 0);
    for (final e in entries) {
      if (e.exerciseMinutes == null) continue;
      final index = _dayStart(e.date).difference(start.first).inDays;
      if (index < 0 || index >= days) continue;
      daily[index] += e.exerciseMinutes!;
    }

    final total = daily.fold<int>(0, (sum, v) => sum + v);
    final hasData = total > 0;

    return _TrendCard(
      title: l10n.reports_exercise_daily,
      value: '${l10n.reports_exercise_total}: $total′',
      hasData: hasData,
      icon: Icons.fitness_center_outlined,
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            titlesData: const FlTitlesData(show: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < days; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: daily[i].toDouble(),
                      width: isWeek ? 18 : 6,
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Test sessions per day, from `study_sessions` where `type == test`.
/// Counts logged sessions (the schema has no per-session test count),
/// so the metric is "test sessions", not individual question counts.
class _TestCountReport extends ConsumerWidget {
  const _TestCountReport({required this.isWeek});

  final bool isWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessions =
        ref.watch(studySessionsProvider).value ?? const <StudySession>[];
    final days = isWeek ? 7 : 30;
    final start = _rangeStart(days);

    final daily = List.filled(days, 0);
    for (final s in sessions) {
      if (s.type != SessionType.test) continue;
      final index = _dayStart(s.start).difference(start.first).inDays;
      if (index < 0 || index >= days) continue;
      daily[index] += 1;
    }

    final total = daily.fold<int>(0, (sum, v) => sum + v);
    final hasData = total > 0;

    return _TrendCard(
      title: l10n.reports_tests_daily,
      value: '${l10n.reports_tests_total}: $total',
      hasData: hasData,
      icon: Icons.fact_check_outlined,
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            titlesData: const FlTitlesData(show: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < days; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: daily[i].toDouble(),
                      width: isWeek ? 18 : 6,
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
