import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    StrategicPlans,
    Milestones,
    Subjects,
    Topics,
    PlanTasks,
    StudySessions,
    Exams,
    ExamResults,
    LifestyleEntries,
    AIConversations,
    AIMessages,
    Notifications,
    Flashcards,
    ReviewItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test-only constructor (in-memory database).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations must preserve user data (AGENTS.md §21).
          if (from < 2) {
            await m.createTable(notifications);
          }
          if (from < 3) {
            await m.createTable(flashcards);
            await m.createTable(reviewItems);
          }
          if (from < 4) {
            await m.addColumn(lifestyleEntries, lifestyleEntries.exerciseType);
            await m.addColumn(lifestyleEntries, lifestyleEntries.sleepQuality);
            await m.addColumn(lifestyleEntries, lifestyleEntries.nutrition);
            await m.addColumn(lifestyleEntries, lifestyleEntries.restMinutes);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'payayar.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
