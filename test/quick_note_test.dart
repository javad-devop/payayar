import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/data/providers.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/l10n/generated/app_localizations.dart';
import 'package:payayar/core/widgets/app_buttons.dart';
import 'package:payayar/features/home/quick_note.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =====================================================================
// design.md §12.1 — Quick Note
//   * textarea with a 100px minimum height
//   * primary Save + danger Clear
//   * auto-save to LOCAL persistence only (AGENTS.md §1 — no backend)
//   * clearing a non-empty note always asks first (design.md §42)
// =====================================================================

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpNote(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('fa'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(
            body: SingleChildScrollView(child: QuickNoteCard()),
          ),
        ),
      ),
    );
    await tester.pump();
    // Let the stored note load from SharedPreferences.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 700));
  }

  Finder field() => find.byType(TextField);
  Finder save() => find.widgetWithText(AppButton, 'ذخیره');
  Finder clear() => find.widgetWithText(AppButton, 'پاک کردن');

  test('note is local-only storage', () async {
    final notifier = container.read(quickNoteProvider.notifier);
    final prefs = await SharedPreferences.getInstance();

    notifier.edit('متن آزمایشی');
    expect(container.read(quickNoteProvider), 'متن آزمایشی');
    expect(prefs.getString(QuickNoteNotifier.storageKey), isNull,
        reason: 'editing only touches memory until save() runs');

    await notifier.save();
    expect(prefs.getString(QuickNoteNotifier.storageKey), 'متن آزمایشی',
        reason: '§12.1 — persisted locally, never remotely');

    await notifier.clear();
    expect(container.read(quickNoteProvider), isEmpty);
    expect(prefs.getString(QuickNoteNotifier.storageKey), isNull);
  });

  testWidgets('field honours the 100px minimum and actions start disabled',
      (tester) async {
    await pumpNote(tester);

    expect(find.text('یادداشت سریع'), findsOneWidget);
    expect(tester.widget<TextField>(field()).minLines, greaterThanOrEqualTo(4),
        reason: '4+ lines ≈ the §12.1 100px minimum height');

    expect(tester.widget<AppButton>(save()).onPressed, isNull,
        reason: 'nothing to save yet');
    expect(tester.widget<AppButton>(clear()).onPressed, isNull,
        reason: 'nothing to clear yet');
  });

  testWidgets('typing enables Save and writes to local storage', (tester) async {
    await pumpNote(tester);
    final prefs = await SharedPreferences.getInstance();

    await tester.enterText(field(), 'فردا ریاضی بخوان');
    await tester.pump();

    expect(tester.widget<AppButton>(save()).onPressed, isNotNull,
        reason: 'Save must enable once there is text');
    expect(container.read(quickNoteProvider), 'فردا ریاضی بخوان');

    await tester.tap(save());
    await tester.pump();

    expect(prefs.getString(QuickNoteNotifier.storageKey), 'فردا ریاضی بخوان');
  });

  testWidgets('auto-save fires after typing settles (§12.1)', (tester) async {
    await pumpNote(tester);
    final prefs = await SharedPreferences.getInstance();

    await tester.enterText(field(), 'یادداشت خودکار');
    await tester.pump();
    expect(prefs.getString(QuickNoteNotifier.storageKey), isNull,
        reason: 'nothing is written before the debounce elapses');

    await tester.pump(QuickNoteNotifier.autoSaveDelay);
    await tester.pump();

    expect(prefs.getString(QuickNoteNotifier.storageKey), 'یادداشت خودکار');
  });

  testWidgets('clearing a non-empty note asks first, then erases it',
      (tester) async {
    await pumpNote(tester);
    final prefs = await SharedPreferences.getInstance();

    await tester.enterText(field(), 'متن برای حذف');
    await tester.pump();

    await tester.tap(clear());
    await tester.pumpAndSettle();

    // Destructive actions must confirm (design.md §42).
    expect(find.text('پاک کردن یادداشت؟'), findsOneWidget,
        reason: 'clearing must never happen silently');

    // Cancel keeps the note.
    await tester.tap(find.widgetWithText(AppButton, 'انصراف'));
    await tester.pumpAndSettle();
    expect(container.read(quickNoteProvider), 'متن برای حذف');

    // Confirm erases it — the dialog's own button is the last match.
    await tester.tap(clear());
    await tester.pumpAndSettle();
    await tester.tap(clear().last);
    await tester.pumpAndSettle();

    expect(container.read(quickNoteProvider), isEmpty);
    expect(prefs.getString(QuickNoteNotifier.storageKey), isNull);
    expect(tester.widget<TextField>(field()).controller!.text, isEmpty,
        reason: 'the visible field must reflect the cleared state');
  });
}
