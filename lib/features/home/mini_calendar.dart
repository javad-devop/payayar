import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// Compact month view used inside the Home calendar card.
///
/// Week start follows the active locale (Saturday for Persian,
/// Sunday for English) and every label comes from the platform's
/// localization so Persian renders with Persian digits and names.
class MiniCalendar extends StatelessWidget {
  const MiniCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final materialL10n = MaterialLocalizations.of(context);
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';

    final firstOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Week order: Saturday-first for Persian, Sunday-first otherwise.
    final startWeekday = isPersian ? DateTime.saturday : DateTime.sunday;
    final weekOrder = [
      for (var i = 0; i < 7; i++) ((startWeekday - 1 + i) % 7) + 1,
    ];

    final leadingBlanks = weekOrder.indexOf(firstOfMonth.weekday);

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++) _DayCell(day: day, isToday: day == now.day),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Month label — localized by MaterialLocalizations.
        Text(
          materialL10n.formatMediumDate(firstOfMonth),
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: AppFontWeight.medium,
              ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Weekday headers.
        Row(
          children: [
            for (final weekday in weekOrder)
              Expanded(
                child: Center(
                  child: Text(
                    materialL10n.narrowWeekdays[weekday % 7],
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Day grid, 7 equal columns per row.
        for (var start = 0; start < cells.length; start += 7)
          Row(
            children: [
              for (var column = 0; column < 7; column++)
                Expanded(
                  child: (start + column < cells.length)
                      ? cells[start + column]
                      : const SizedBox.shrink(),
                ),
            ],
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isToday});

  final int day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final materialL10n = MaterialLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 34,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      decoration: isToday
          ? BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.button),
            )
          : null,
      child: Text(
        materialL10n.formatDecimal(day),
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: isToday ? scheme.onPrimary : scheme.onSurface,
              fontWeight: isToday ? AppFontWeight.bold : AppFontWeight.regular,
            ),
      ),
    );
  }
}
