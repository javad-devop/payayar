import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/app/app.dart';
import 'package:payayar/app/state/navigation.dart';
import 'package:payayar/core/data/providers.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/widgets/app_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =====================================================================
// Bug 2 — «آزمون جدید» ذخیره نمی‌شد.
// ریشهٔ مشترک با باگ ۱: `onPressed: _title.text.isEmpty ? null : _save`
// بدون onChanged/setState → دکمهٔ ذخیره برای همیشه غیرفعال می‌ماند.
// هر ۴ سایت هم‌ریشه: exams_page، planning_page (_MockExamDialog)،
// study_page (_SubjectDialog + _TopicDialog).
// =====================================================================

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpSection(
    WidgetTester tester,
    AppSection section,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(1440, 2400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PayayarApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    container.read(sectionProvider.notifier).goTo(section);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    return container;
  }

  Future<void> detach(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
  }

  testWidgets('Exams: «آزمون جدید» saves after typing', (tester) async {
    final container = await pumpSection(tester, AppSection.exams);

    await tester.tap(find.text('آزمون جدید').first);
    await tester.pumpAndSettle();

    final save = find.widgetWithText(AppButton, 'ذخیره');
    expect(save, findsOneWidget);
    expect(tester.widget<AppButton>(save).onPressed, isNull,
        reason: 'ورودی خالی → ذخیره غیرفعال');

    await tester.enterText(find.byType(TextField).first, 'آزمون آزمایشی ۱');
    await tester.pump();

    expect(
      tester.widget<AppButton>(save).onPressed,
      isNotNull,
      reason: 'دکمهٔ ذخیره بعد از تایپ عنوان آزمون باید فعال شود',
    );

    await tester.tap(save);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text('آزمون آزمایشی ۱'), findsWidgets,
        reason: 'آزمون باید بعد از ذخیره در لیست ظاهر شود');
    expect(find.widgetWithText(AppButton, 'ذخیره'), findsNothing);

    // نکته: از خواندن آینده‌ای استفاده می‌شود نه استریم؛
    // `watchExams().first` باعث هنگ شدن teardown تست می‌شد.
    final db = container.read(databaseProvider);
    final exams = await db.select(db.exams).get();
    expect(exams.map((e) => e.title), contains('آزمون آزمایشی ۱'));

    await detach(tester);
  });

  testWidgets('Planning: «ثبت آزمون آزمایشی» saves after typing',
      (tester) async {
    final container = await pumpSection(tester, AppSection.planning);

    // صفحهٔ برنامه‌ریزی تب‌بندی است؛ دکمه در تب «آزمون آزمایشی» است.
    await tester.tap(find.text('آزمون آزمایشی').first);
    await tester.pumpAndSettle();
    expect(find.text('ثبت آزمون آزمایشی'), findsWidgets,
        reason: 'دکمهٔ ثبت باید بعد از رفتن به تب آزمون آزمایشی دیده شود');

    await tester.tap(find.text('ثبت آزمون آزمایشی').first);
    await tester.pumpAndSettle();

    final save = find.widgetWithText(AppButton, 'ذخیره');
    expect(save, findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'آزمون هفته ۱۴');
    await tester.pump();

    expect(
      tester.widget<AppButton>(save).onPressed,
      isNotNull,
      reason: 'دکمهٔ ذخیرهٔ مودال آزمون آزمایشی باید بعد از تایپ فعال شود',
    );

    await tester.tap(save);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text('آزمون هفته ۱۴'), findsWidgets);

    // خواندن آینده‌ای به‌جای استریم (جلوگیری از هنگ teardown).
    final db = container.read(databaseProvider);
    final exams = await db.select(db.exams).get();
    expect(exams.map((e) => e.title), contains('آزمون هفته ۱۴'));

    await detach(tester);
  });
}
