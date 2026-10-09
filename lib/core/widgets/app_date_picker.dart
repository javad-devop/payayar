import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/tokens.dart';
import '../util/shamsi.dart';

/// App-wide date picker: a Shamsi (Jalali) calendar for Persian users
/// and Material's Gregorian picker for other locales — every visible
/// date in the app is Shamsi (user requirement).
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  if (Localizations.localeOf(context).languageCode != 'fa') {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _ShamsiDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _ShamsiDatePickerDialog extends StatefulWidget {
  const _ShamsiDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_ShamsiDatePickerDialog> createState() =>
      _ShamsiDatePickerDialogState();
}

class _ShamsiDatePickerDialogState extends State<_ShamsiDatePickerDialog> {
  static const _weekdayHeaders = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
  static const _weekOrder = [6, 7, 1, 2, 3, 4, 5]; // weekday # of شنبه..جمعه

  late ShamsiDate _shown = toShamsi(widget.initialDate);

  /// Gregorian day for a Jalali date within the currently shown month
  /// (day arithmetic from the month's first day).
  DateTime _firstOfMonth = DateTime(2000);

  @override
  void initState() {
    super.initState();
    _refreshFirstOfMonth();
  }

  void _refreshFirstOfMonth() {
    _firstOfMonth = fromShamsi(_shown.year, _shown.month, 1);
  }

  int get _daysInMonth {
    var days = 0;
    while (days <= 31) {
      final s = toShamsi(_firstOfMonth.add(Duration(days: days)));
      if (s.year != _shown.year || s.month != _shown.month) break;
      days++;
    }
    return days;
  }

  bool get _canGoPrev {
    final first = toShamsi(widget.firstDate);
    return _shown.year > first.year ||
        (_shown.year == first.year && _shown.month > first.month);
  }

  bool get _canGoNext {
    final last = toShamsi(widget.lastDate);
    return _shown.year < last.year || _shown.month < last.month;
  }

  void _shiftMonth(int delta) {
    setState(() {
      var month = _shown.month + delta;
      var year = _shown.year;
      if (month < 1) {
        month = 12;
        year -= 1;
      } else if (month > 12) {
        month = 1;
        year += 1;
      }
      _shown = ShamsiDate(year, month, 1);
      _refreshFirstOfMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final days = _daysInMonth;
    final leading = _weekOrder.indexOf(_firstOfMonth.weekday);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _canGoPrev ? () => _shiftMonth(-1) : null,
                    icon: const Icon(Icons.chevron_left, size: 20),
                  ),
                  Expanded(
                    child: Text(
                      '${_shown.monthName} ${toFaDigits('${_shown.year}')}',
                      textAlign: TextAlign.center,
                      style: text.titleMedium!
                          .copyWith(fontWeight: AppFontWeight.semiBold),
                    ),
                  ),
                  IconButton(
                    onPressed: _canGoNext ? () => _shiftMonth(1) : null,
                    icon: const Icon(Icons.chevron_right, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  for (final header in _weekdayHeaders)
                    Expanded(
                      child: Center(
                        child: Text(
                          header,
                          style: text.labelSmall!
                              .copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              for (var week = 0; (week * 7) < (leading + days); week++)
                Row(
                  children: [
                    for (var column = 0; column < 7; column++)
                      Expanded(child: _cell(week * 7 + column - leading, days)),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.common_cancel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(int dayIndex, int days) {
    if (dayIndex < 1 || dayIndex > days) return const SizedBox.shrink();

    final gDay = _firstOfMonth.add(Duration(days: dayIndex - 1));
    final disabled =
        gDay.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day)) ||
            gDay.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day));
    final isToday = toShamsi(DateTime.now()).year == _shown.year &&
        toShamsi(DateTime.now()).month == _shown.month &&
        toShamsi(DateTime.now()).day == dayIndex;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.button),
      onTap: disabled ? null : () => Navigator.of(context).pop(gDay),
      child: SizedBox(
        height: 36,
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: isToday
                ? BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  )
                : null,
            child: Text(
              toFaDigits('$dayIndex'),
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: disabled
                        ? scheme.onSurface.withValues(alpha: 0.35)
                        : isToday
                            ? scheme.primary
                            : scheme.onSurface,
                    fontWeight:
                        isToday ? AppFontWeight.bold : AppFontWeight.regular,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
