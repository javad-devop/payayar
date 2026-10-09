import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/glass_card.dart';

/// GitHub-style study heatmap for the last 13 weeks (phase 11):
/// rows = Saturday..Friday, one column per week, darker = more minutes
/// studied that day. Pure display over local data.
class HeatmapReport extends ConsumerWidget {
  const HeatmapReport({super.key});

  static const _weeks = 13;
  static const _cell = 14.0;
  static const _gap = 2.0;
  static const _weekdayLabels = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  Color _shade(ColorScheme scheme, int minutes) {
    if (minutes <= 0) return scheme.outlineVariant.withValues(alpha: 0.35);
    if (minutes < 30) return scheme.primary.withValues(alpha: 0.30);
    if (minutes < 60) return scheme.primary.withValues(alpha: 0.55);
    if (minutes < 120) return scheme.primary.withValues(alpha: 0.80);
    return scheme.primary;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(studySessionsProvider).value ?? const [];
    final scheme = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayWeekday = (today.weekday + 1) % 7; // Saturday = 0
    final thisWeekStart = today.subtract(Duration(days: todayWeekday));
    final oldest = thisWeekStart.subtract(const Duration(days: 7 * 12));

    // minutes[weekColumn][weekdayRow]; column 0 is the oldest week.
    final minutes = List.generate(_weeks, (_) => List<int>.filled(7, 0));
    for (final session in sessions) {
      final day = DateTime(
        session.start.year,
        session.start.month,
        session.start.day,
      );
      if (day.isBefore(oldest) || day.isAfter(today)) continue;
      final weeksBack = thisWeekStart.difference(day).inDays ~/ 7;
      final column = _weeks - 1 - weeksBack;
      if (column < 0 || column >= _weeks) continue;
      final row = (day.weekday + 1) % 7;
      minutes[column][row] +=
          session.end.difference(session.start).inMinutes.clamp(0, 24 * 60);
    }

    Widget cell(int column, int row) {
      final day = oldest.add(Duration(days: column * 7 + row));
      final isFuture = day.isAfter(today);
      final isToday = day == today;
      return Container(
        width: _cell,
        height: _cell,
        decoration: BoxDecoration(
          color: isFuture ? Colors.transparent : _shade(scheme, minutes[column][row]),
          borderRadius: BorderRadius.circular(3),
          border: isToday ? Border.all(color: scheme.onSurface) : null,
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reports_heatmap,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: AppFontWeight.semiBold,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekday rail (Saturday at the top).
              Column(
                children: [
                  for (final label in _weekdayLabels)
                    SizedBox(
                      width: 16,
                      height: _cell + _gap,
                      child: Center(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
              // 13 week columns, oldest on the left.
              for (var column = 0; column < _weeks; column++) ...[
                if (column > 0) const SizedBox(width: _gap),
                Column(
                  children: [
                    for (var row = 0; row < 7; row++) ...[
                      if (row > 0) const SizedBox(height: _gap),
                      cell(column, row),
                    ],
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(l10n.heatmap_less,
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(width: AppSpacing.xs),
              for (final m in const [0, 20, 45, 90, 150])
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: _shade(scheme, m),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const SizedBox(width: AppSpacing.xs),
              Text(l10n.heatmap_more,
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
