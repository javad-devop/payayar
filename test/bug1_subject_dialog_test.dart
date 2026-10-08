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
// Bug 1 — «درس جدید» ذخیره نمی‌شد.
// ریشه: دکمهٔ ذخیره با `controller.text.isEmpty` در زمان build قفل می‌ماند
// چون TextField هیچ onChanged ندارد و rebuild رخ نمی‌دهد → کلیک بی‌اثر.
// =====================================================================

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpStudy(WidgetTester tester) async {
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

    container.read(sectionProvider.notifier).goTo(AppSection.study);
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

  testWidgets('save button enables after typing and subject lands in the list',
      (tester) async {
    final container = await pumpStudy(tester);

    // مودال «درس جدید» را باز کن
    await tester.tap(find.text('درس جدید').first);
    await tester.pumpAndSettle();

    final save = find.widgetWithText(AppButton, 'ذخیره');
    expect(save, findsOneWidget);
    // ورودی خالی → ذخیره غیرفعال (درست)
    expect(tester.widget<AppButton>(save).onPressed, isNull);

    // نام درس را تایپ کن
    await tester.enterText(find.byType(TextField).first, 'ریاضی');
    await tester.pump();

    // ✅ انتظار باگ ۱: بعد از تایپ، دکمه باید فعال شود
    expect(
      tester.widget<AppButton>(save).onPressed,
      isNotNull,
      reason: 'دکمهٔ ذخیره بعد از تایپ نام درس باید فعال شود',
    );

    await tester.tap(save);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // درس باید در لیست ظاهر شده و مودال بسته شده باشد
    expect(find.text('ریاضی'), findsWidgets,
        reason: 'درس باید بعد از ذخیره در لیست ظاهر شود');
    expect(find.widgetWithText(AppButton, 'ذخیره'), findsNothing,
        reason: 'مودال باید بعد از ذخیره بسته شود');

    // از خودِ دیتابیس هم بخوان
    final subjects = await container.read(studyRepositoryProvider).getSubjects();
    expect(subjects.map((s) => s.name), contains('ریاضی'));

    await detach(tester);
  });
}
