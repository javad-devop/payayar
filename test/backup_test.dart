import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/database/tables.dart';
import 'package:payayar/core/util/backup.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('payayar_backup_test');
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('export then restore round-trips rows after a wipe', () async {
    // Seed a couple of tables.
    await db
        .into(db.subjects)
        .insert(SubjectsCompanion.insert(name: 'ریاضی', priority: Priority.high));
    await db.into(db.planTasks).insert(
          PlanTasksCompanion.insert(
            title: 'مرور فصل ۱',
            date: DateTime(2026, 10, 10),
            status: TaskStatus.notStarted,
            priority: Priority.medium,
          ),
        );

    final backupPath = '${tempDir.path}/backup.db';
    await exportBackupTo(db, backupPath);
    expect(await File(backupPath).exists(), isTrue);

    // Wipe everything the user would lose.
    await db.delete(db.planTasks).go();
    await db.delete(db.subjects).go();
    expect((await db.select(db.subjects).get()).length, 0);

    final restored = await restoreBackupFrom(db, backupPath);
    expect(restored, greaterThan(0));

    final subjects = await db.select(db.subjects).get();
    expect(subjects.single.name, 'ریاضی');
    final tasks = await db.select(db.planTasks).get();
    expect(tasks.single.title, 'مرور فصل ۱');

    // Sequences keep working: new rows don't collide with restored ids.
    final id = await db.into(db.subjects).insert(
          SubjectsCompanion.insert(name: 'فیزیک', priority: Priority.low),
        );
    expect(id, greaterThan(subjects.single.id));
  });

  test('restore on a missing backup file throws backup_missing', () async {
    await expectLater(
      restoreBackupFrom(db, '${tempDir.path}/nope.db'),
      throwsA(isA<StateError>()),
    );
  });
}
