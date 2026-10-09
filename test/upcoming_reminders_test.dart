import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/data/providers.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/database/tables.dart';
import 'package:payayar/core/l10n/generated/app_localizations.dart';
import 'package:payayar/core/notifications/upcoming_reminders.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  testWidgets('staged reminders create rows once and dedupe on rerun',
      (tester) async {
    final today = (() {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    })();

    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            title: 'ریاضی',
            type: ExamType.school,
            date: today.add(const Duration(days: 3)),
          ),
        );
    await db.into(db.planTasks).insert(
          PlanTasksCompanion.insert(
            title: 'مرور فصل ۲',
            date: today.add(const Duration(days: 1)),
            status: TaskStatus.notStarted,
            priority: Priority.medium,
          ),
        );

    late BuildContext context;
    late WidgetRef ref;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Consumer(
            builder: (c, r, _) {
              context = c;
              ref = r;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    await generateUpcomingReminders(context, ref);
    await tester.pump();

    final rows = await db.select(db.notifications).get();
    expect(rows, hasLength(2), reason: 'exam (3 days) + task (tomorrow)');
    expect(
      rows.map((n) => n.title),
      anyElement(contains('exam in 3 days')),
    );
    expect(
      rows.map((n) => n.title),
      anyElement(contains('due tomorrow')),
    );
    // Task rows link back to the task so the bell can re-check status.
    expect(rows.any((n) => n.taskId != null), isTrue);

    // Idempotent: a second run (e.g. app reboot) must not duplicate.
    await generateUpcomingReminders(context, ref);
    await tester.pump();
    expect(await db.select(db.notifications).get(), hasLength(2));
  });
}
