/// Jalali (Shamsi) date conversion and Persian formatting.
///
/// Pure Dart, offline, no dependencies (PLAN.md: everything local-first).
/// Conversion valid for Gregorian years 1799–2256 CE — well beyond the
/// app's range (user requirement: all visible dates are Shamsi).
library;

const List<String> _months = [
  'فروردین',
  'اردیبهشت',
  'خرداد',
  'تیر',
  'مرداد',
  'شهریور',
  'مهر',
  'آبان',
  'آذر',
  'دی',
  'بهمن',
  'اسفند',
];

/// Weekday names, week starts Saturday (Iranian week).
const List<String> _weekdays = [
  'شنبه',
  'یکشنبه',
  'دوشنبه',
  'سه‌شنبه',
  'چهارشنبه',
  'پنجشنبه',
  'جمعه',
];

const List<String> _digits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

/// Converts ASCII digits in [input] to Persian digits.
String toFaDigits(String input) => input.replaceAllMapped(
      RegExp(r'[0-9]'),
      (m) => _digits[int.parse(m.group(0)!)],
    );

/// A Jalali calendar date.
class ShamsiDate {
  const ShamsiDate(this.year, this.month, this.day);

  final int year;
  final int month; // 1..12
  final int day;

  String get monthName => _months[month - 1];

  /// `۱۴۰۵/۷/۱۸`
  String get short => toFaDigits('$year/$month/$day');

  /// `۱۸ مهر ۱۴۰۵`
  String get long => toFaDigits('$day $monthName $year');
}

/// Weekday name for a Gregorian date: شنبه (week starts Saturday).
String shamsiWeekday(DateTime date) => _weekdays[(date.weekday + 1) % 7];

/// Inverse of [toShamsi]: the Gregorian day matching a Jalali date.
///
/// A bounded day-by-day search around the expected year — conversion runs
/// once per user pick, so correctness beats cleverness here.
DateTime fromShamsi(int jy, int jm, int jd) {
  var candidate = DateTime(jy + 620, 1, 1);
  final end = DateTime(jy + 623, 1, 1);
  while (candidate.isBefore(end)) {
    final s = toShamsi(candidate);
    if (s.year == jy && s.month == jm && s.day == jd) return candidate;
    candidate = candidate.add(const Duration(days: 1));
  }
  // Unreachable for a valid Jalali date; Nowruz of the requested year.
  return DateTime(jy + 621, 3, 21);
}

/// Gregorian → Jalali.
ShamsiDate toShamsi(DateTime g) {
  const gdm = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
  int gy = g.year;
  final gm = g.month;
  final gd = g.day;

  int jy;
  if (gy > 1600) {
    jy = 979;
    gy -= 1600;
  } else {
    jy = 0;
    gy -= 621;
  }

  final gy2 = gm > 2 ? gy + 1 : gy;
  var days = 365 * gy +
      ((gy2 + 3) ~/ 4) -
      ((gy2 + 99) ~/ 100) +
      ((gy2 + 399) ~/ 400) -
      80 +
      gd +
      gdm[gm - 1];

  jy += 33 * (days ~/ 12053);
  days %= 12053;
  jy += 4 * (days ~/ 1461);
  days %= 1461;
  if (days > 365) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }

  final jm = days < 186 ? 1 + days ~/ 31 : 7 + (days - 186) ~/ 30;
  final jd = days < 186 ? 1 + days % 31 : 1 + (days - 186) % 30;
  return ShamsiDate(jy, jm, jd);
}

/// `شنبه ۱۷ مهر`
String shamsiDayLabel(DateTime d) {
  final s = toShamsi(d);
  return '${shamsiWeekday(d)} ${toFaDigits('${s.day} ${s.monthName}')}';
}

/// Convenience: `۱۴۰۵/۷/۱۸`
String shamsiShort(DateTime d) => toShamsi(d).short;

/// Convenience: `۱۸ مهر ۱۴۰۵`
String shamsiLong(DateTime d) => toShamsi(d).long;
