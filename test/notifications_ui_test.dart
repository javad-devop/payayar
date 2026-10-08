import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/data/providers.dart';
import 'package:payayar/core/data/repositories.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/l10n/generated/app_localizations.dart';
import 'package:payayar/features/notifications/bell_button.dart';

// =====================================================================
// UI tests for HANDOFF §43.1 — top-bar bell badge + history panel:
//   * badge counts pending (created/unread) rows only
//   * opening the panel marks rows read (badge clears)
//   * «انجام وظیفه» completes the linked task from the panel
// =====================================================================

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late NotificationRepository notifications;
  late PlanningRepository planning;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    notifications = NotificationRepository(db);
    planning = PlanningRepository(db);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpBell(WidgetTester tester) async {
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
            body: Row(children: [BellButton()]),
          ),
        ),
      ),
    );
    // Two pumps: one for the first build, one for the stream's first emit.
    await tester.pump();
    await tester.pump();
  }

  testWidgets('bell shows no badge when nothing is pending', (tester) async {
    await pumpBell(tester);

    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('badge counts pending rows; opening the panel clears it',
      (tester) async {
    await notifications.addNotification(title: 'یادآوری درس');
    await notifications.addNotification(title: 'وقت استراحت');
    await pumpBell(tester);

    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(find.text('یادآوری درس'), findsOneWidget);
    expect(find.text('وقت استراحت'), findsOneWidget);
    expect(find.text('اعلانی نداری'), findsNothing);
    expect(find.text('2'), findsNothing,
        reason: 'opening the panel marks rows read → badge clears');
  });

  testWidgets('empty history shows the empty state', (tester) async {
    await pumpBell(tester);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(find.text('اعلانی نداری'), findsOneWidget);
  });

  testWidgets('«انجام وظیفه» completes the linked task from the panel',
      (tester) async {
    final taskId = await planning.addTask(PlanTasksCompanion.insert(
      title: 'مرور ریاضی',
      date: DateTime(2026, 10, 8),
      status: TaskStatus.notStarted,
      priority: Priority.high,
    ));
    await notifications.addNotification(title: 'وقت مطالعه', taskId: taskId);
    await pumpBell(tester);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'انجام وظیفه'));
    await tester.pumpAndSettle();

    final task = await (db.select(db.planTasks)
          ..where((t) => t.id.equals(taskId)))
        .getSingle();
    expect(task.status, TaskStatus.completed);
    expect(find.text('انجام شد'), findsOneWidget,
        reason: 'row settles into the actioned state');
  });
}
