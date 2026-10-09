import '../l10n/generated/app_localizations.dart';

/// Human label for the days remaining until [date].
///
/// Returns null once the date has passed (callers fall back to the date
/// itself), `امروز` for today and `فردا` for tomorrow.
String? examCountdown(AppLocalizations l10n, DateTime date) {
  final now = DateTime.now();
  final days = DateTime(date.year, date.month, date.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  if (days < 0) return null;
  if (days == 0) return l10n.exams_today;
  if (days == 1) return l10n.exams_tomorrow;
  return l10n.exams_daysLeft(days);
}
