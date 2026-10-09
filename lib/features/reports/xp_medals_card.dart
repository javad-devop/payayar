import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/gamification.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/util/shamsi.dart' show toFaDigits;
import '../../core/widgets/glass_card.dart';
import '../../features/planning/planning_dashboard.dart';

/// Level + XP + medal grid derived from local activity (phase 11).
class XpMedalsCard extends ConsumerWidget {
  const XpMedalsCard({super.key});

  static const _medalIcons = <String, IconData>{
    'first_session': Icons.directions_walk,
    'streak_7': Icons.local_fire_department,
    'sessions_10': Icons.menu_book_outlined,
    'hours_10': Icons.timer_outlined,
    'tasks_20': Icons.checklist,
    'exams_5': Icons.assignment_turned_in_outlined,
  };

  String _medalTitle(AppLocalizations l10n, String id) => switch (id) {
        'first_session' => l10n.medal_first,
        'streak_7' => l10n.medal_streak7,
        'sessions_10' => l10n.medal_sessions10,
        'hours_10' => l10n.medal_hours10,
        'tasks_20' => l10n.medal_tasks20,
        'exams_5' => l10n.medal_exams5,
        _ => id,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(studySessionsProvider).value ?? const [];
    final tasks = ref.watch(planTasksProvider).value ?? const [];
    final results = ref.watch(allExamResultsProvider).value ?? const [];
    final summary = ref.watch(studySummaryProvider);
    final scheme = Theme.of(context).colorScheme;

    final stats = GamificationStats(
      studyMinutes: sessions.fold<int>(
        0,
        (sum, s) => sum + s.end.difference(s.start).inMinutes.clamp(0, 24 * 60),
      ),
      sessions: sessions.length,
      streakDays: summary.streakDays,
      tasksDone: tasks.where((t) => t.completedAt != null).length,
      exams: results.length,
    );
    final xp = totalXp(stats);
    final level = levelFor(xp);
    final earned = earnedMedals(stats);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.xp_title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: AppFontWeight.semiBold,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(alpha: 0.14),
                  border: Border.all(color: scheme.primary, width: 2),
                ),
                child: Text(
                  toFaDigits('$level'),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: AppFontWeight.bold,
                        color: scheme.primary,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.xp_level} ${toFaDigits('$level')}'
                      '  ·  ${toFaDigits('$xp')} ${l10n.xp_xp}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: AppFontWeight.semiBold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: levelProgress(xp),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final id in medalIds)
                Tooltip(
                  message: _medalTitle(l10n, id),
                  child: Chip(
                    avatar: Icon(
                      earned.contains(id)
                          ? _medalIcons[id]
                          : Icons.lock_outline,
                      size: 18,
                      color: earned.contains(id)
                          ? scheme.primary
                          : scheme.outline,
                    ),
                    label: Text(
                      _medalTitle(l10n, id),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: earned.contains(id)
                                ? scheme.onSurface
                                : scheme.outline,
                          ),
                    ),
                    side: BorderSide(
                      color: earned.contains(id)
                          ? scheme.primary.withValues(alpha: 0.6)
                          : scheme.outlineVariant,
                    ),
                    backgroundColor: earned.contains(id)
                        ? scheme.primary.withValues(alpha: 0.10)
                        : Colors.transparent,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
