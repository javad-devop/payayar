import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/app/state/navigation.dart';
import 'package:payayar/core/data/providers.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/l10n/generated/app_localizations.dart';
import 'package:payayar/features/study/focus_timer.dart';
import 'package:payayar/features/study/focus_timer_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =====================================================================
// AGENTS.md §44.4 — compact focus-timer HUD:
//   * hidden (zero-height) while no session is active
//   * visible everywhere while a session runs, with mm:ss remaining
//   * pause/resume right from the strip
//   * tapping the strip jumps to the study section
// =====================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpHud(WidgetTester tester) async {
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
          home: const Scaffold(body: FocusTimerHud()),
        ),
      ),
    );
  }

  Future<int> startSession({int minutes = 25}) async {
    final subjectId =
        await container.read(studyRepositoryProvider).addSubject('ریاضی');
    container
        .read(focusTimerProvider.notifier)
        .start(subjectId: subjectId, minutes: minutes);
    return subjectId;
  }

  test('formatRemaining uses padded western digits', () {
    expect(FocusTimerHud.formatRemaining(0), '00:00');
    expect(FocusTimerHud.formatRemaining(65), '01:05');
    expect(FocusTimerHud.formatRemaining(1500), '25:00');
  });

  testWidgets('hidden while idle, shows mm:ss while a session runs',
      (tester) async {
    await pumpHud(tester);
    expect(find.text('25:00'), findsNothing);

    await startSession();
    await tester.pump();
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('در حال مطالعه'), findsOneWidget);

    await container.read(focusTimerProvider.notifier).endEarly(record: false);
    await tester.pump();
    expect(find.text('25:00'), findsNothing);
  });

  testWidgets('pause and resume work from the strip', (tester) async {
    await pumpHud(tester);
    await startSession();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.text('متوقف'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    expect(find.text('در حال مطالعه'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await container.read(focusTimerProvider.notifier).endEarly(record: false);
    await tester.pump();
  });

  testWidgets('tapping the strip navigates to the study section',
      (tester) async {
    await pumpHud(tester);
    await startSession();
    await tester.pump();

    await tester.tap(find.text('25:00'));
    await tester.pump();

    expect(
      container.read(sectionProvider),
      AppSection.study,
    );

    await container.read(focusTimerProvider.notifier).endEarly(record: false);
    await tester.pump();
  });
}
