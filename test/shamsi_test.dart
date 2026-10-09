import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/util/shamsi.dart';

void main() {
  group('Shamsi conversion (Nowruz anchors)', () {
    test('2026-03-21 is 1405/01/01', () {
      final j = toShamsi(DateTime(2026, 3, 21));
      expect([j.year, j.month, j.day], [1405, 1, 1]);
    });

    test('2025-03-21 is 1404/01/01', () {
      final j = toShamsi(DateTime(2025, 3, 21));
      expect([j.year, j.month, j.day], [1404, 1, 1]);
    });

    test('2024-03-20 is 1403/01/01', () {
      final j = toShamsi(DateTime(2024, 3, 20));
      expect([j.year, j.month, j.day], [1403, 1, 1]);
    });

    test('1403 is a leap year: 2025-03-20 is 1403/12/30', () {
      final j = toShamsi(DateTime(2025, 3, 20));
      expect([j.year, j.month, j.day], [1403, 12, 30]);
    });

    test('ordinary date: 2026-10-09 is 1405/07/17', () {
      final j = toShamsi(DateTime(2026, 10, 9));
      expect([j.year, j.month, j.day], [1405, 7, 17]);
    });

    test('first and last day of a month', () {
      final a = toShamsi(DateTime(2026, 9, 23)); // 1405/07/01 (مهر 1)
      expect([a.year, a.month, a.day], [1405, 7, 1]);
      final b = toShamsi(DateTime(2026, 3, 20)); // 1404/12/29 (1404 not leap)
      expect([b.year, b.month, b.day], [1404, 12, 29]);
    });
  });

  group('Formatting', () {
    test('short form uses Persian digits', () {
      expect(shamsiShort(DateTime(2026, 10, 9)), '۱۴۰۵/۷/۱۷');
    });

    test('long form has Persian month name', () {
      expect(shamsiLong(DateTime(2026, 10, 9)), '۱۷ مهر ۱۴۰۵');
    });

    test('week starts Saturday', () {
      expect(shamsiWeekday(DateTime(2026, 10, 10)), 'شنبه'); // Sat
      expect(shamsiWeekday(DateTime(2026, 10, 11)), 'یکشنبه');
      expect(shamsiWeekday(DateTime(2026, 10, 16)), 'جمعه'); // Fri
    });

    test('toFaDigits converts only digits', () {
      expect(toFaDigits('v2 plan 10'), 'v۲ plan ۱۰');
    });
  });
}
