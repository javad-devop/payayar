import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/app/app.dart';
import 'package:payayar/app/state/navigation.dart';
import 'package:payayar/core/data/providers.dart';
import 'package:payayar/core/data/repositories.dart'
    show SessionType, LifestyleRepository, StudyRepository;
import 'package:payayar/core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =====================================================================
// Bug 3 — نمودارهای خواب، ورزش و تعداد تست در صفحهٔ گزارش‌ها جا مانده بود.
// AGENTS.md §15 می‌گوید: Sleep trends / Exercise trends / Test counts
// باید از دادهٔ محلی SQLite محاسبه شوند.
//
// منبع داده (این پروژه، نه پروژهٔ قدیمی که BUGS.md حدس زده بود):
//   خواب    ← lifestyle_entries.sleep_minutes
//   ورزش    ← lifestyle_entries.exercise_minutes
//   تست     ← study_sessions با type == SessionType.test
//             (جدول test_sessions در این شمای وجود ندارد)
// =====================================================================

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpReports(
    WidgetTester tester,
    AppDatabase db,
  ) async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    // The reports page is a lazy ListView: a child that sits below the
    // viewport (or outside its cache extent) is either built-but-offstage or
    // not built at all, and find.text(skipOffstage: true) will not see it.
    // The assertions below cover four stacked cards at once, so give the
    // test a viewport tall enough to hold the whole page onstage instead of
    // scrolling between assertions (480x800 logical was the cause of the
    // first false failure: sleep was on screen, exercise was not).
    tester.view.physicalSize = const Size(1440, 9600); // logical 480 x 3200
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PayayarApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    container.read(sectionProvider.notifier).goTo(AppSection.reports);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return container;
  }

  AppDatabase seedDb() {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  testWidgets('Reports: sleep, exercise and test charts render', (
    tester,
  ) async {
    final db = seedDb();
    final today = DateTime.now();

    // خواب و ورزش برای امروز
    await LifestyleRepository(db).upsertEntry(
      LifestyleEntriesCompanion.insert(
        date: DateTime(today.year, today.month, today.day),
        sleepMinutes: const Value(7 * 60),
        exerciseMinutes: const Value(45),
      ),
    );

    // یک جلسهٔ تست ثبت‌شده برای امروز
    final studyRepo = StudyRepository(db);
    final subjectId = await studyRepo.addSubject('ریاضی');
    final start = DateTime(today.year, today.month, today.day, 10);
    await studyRepo.addSession(
      subjectId: subjectId,
      start: start,
      end: start.add(const Duration(minutes: 50)),
      type: SessionType.test,
    );

    await pumpReports(tester, db);

    expect(find.text('روند خواب روزانه'), findsOneWidget);
    expect(find.text('ورزش روزانه'), findsOneWidget);
    expect(find.text('تعداد تست روزانه'), findsOneWidget);

    // با داده باید نمودار رندر شود، نه حالت خالی
    expect(find.text('هنوز داده‌ای برای گزارش نیست'), findsNothing);

    // متریک سربرگ: میانگین خواب ۷ ساعت و مجموع ۴۵ دقیقه ورزش
    expect(find.textContaining('میانگین خواب: 7.0'), findsOneWidget);
    expect(find.textContaining('مجموع ورزش: 45'), findsOneWidget);
    expect(find.textContaining('مجموع تست‌ها: 1'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Reports: charts show empty state when no data', (
    tester,
  ) async {
    final db = seedDb();

    await pumpReports(tester, db);

    expect(find.text('روند خواب روزانه'), findsOneWidget);
    expect(find.text('ورزش روزانه'), findsOneWidget);
    expect(find.text('تعداد تست روزانه'), findsOneWidget);

    // بدون داده: هر کارت باید حالت خالی صادقانه نشان دهد
    expect(find.text('هنوز داده‌ای برای گزارش نیست'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
