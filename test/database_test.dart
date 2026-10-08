import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/data/repositories.dart';

// =====================================================================
// Database CRUD tests — in-memory SQLite through the real repositories.
// =====================================================================

AppDatabase _testDb() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return db;
}

void main() {
  late AppDatabase db;

  setUp(() => db = _testDb());
  tearDown(() => db.close());

  test('subject CRUD round-trips', () async {
    final repo = StudyRepository(db);

    final id = await repo.addSubject('ریاضی', category: 'عمومی');
    final subject = await repo.getSubject(id);
    expect(subject.name, 'ریاضی');
    expect(subject.category, 'عمومی');

    await repo.updateSubject(subject.copyWith(name: 'فیزیک'));
    expect((await repo.getSubject(id)).name, 'فیزیک');

    expect(await repo.deleteSubject(id), 1);
    final all = await repo.getSubjects();
    expect(all, isEmpty);
  });

  test('topic CRUD with subtopics', () async {
    final repo = StudyRepository(db);
    final subjectId = await repo.addSubject('Math');

    final topicId = await repo.addTopic(
      subjectId: subjectId,
      name: 'Algebra',
    );
    final subId = await repo.addTopic(
      subjectId: subjectId,
      name: 'Quadratic equations',
      parentTopicId: topicId,
    );

    final topics = await (db.select(db.topics)).get();
    expect(topics.length, 2);
    final sub = topics.firstWhere((t) => t.id == subId);
    expect(sub.parentTopicId, topicId);

    final topic = topics.firstWhere((t) => t.id == topicId);
    await repo.updateTopic(topic.copyWith(mastery: 80, status: TopicStatus.mastered));
    final updated = await (db.select(db.topics)
          ..where((t) => t.id.equals(topicId)))
        .getSingle();
    expect(updated.mastery, 80);
    expect(updated.status, TopicStatus.mastered);
  });

  test('task creation, completion and deletion', () async {
    final repo = PlanningRepository(db);
    final today = DateTime(2026, 9, 25, 0);

    final id = await repo.addTask(PlanTasksCompanion.insert(
      title: 'مرور جبر',
      date: today,
      status: TaskStatus.notStarted,
      priority: Priority.high,
      startMinutes: const Value(480),
      durationMinutes: const Value(90),
    ));

    var tasks = await repo.getTasksOn(today);
    expect(tasks.single.title, 'مرور جبر');
    expect(tasks.single.status, TaskStatus.notStarted);

    await repo.setStatus(id, TaskStatus.completed);
    tasks = await repo.getTasksOn(today);
    expect(tasks.single.status, TaskStatus.completed);
    expect(tasks.single.completedAt, isNotNull);

    await repo.moveTo(id, DateTime(2026, 9, 26));
    final moved = await repo.getTask(id);
    expect(moved.date.day, 26);

    expect(await repo.deleteTask(id), 1);
    expect(await repo.getTasksOn(today), isEmpty);
  });

  test('task stream only exposes active tasks in order', () async {
    final repo = PlanningRepository(db);
    final day = DateTime(2026, 9, 25);

    await repo.addTask(PlanTasksCompanion.insert(
      title: 'later',
      date: day,
      status: TaskStatus.notStarted,
      priority: Priority.low,
      startMinutes: const Value(600),
    ));
    await repo.addTask(PlanTasksCompanion.insert(
      title: 'earlier',
      date: day,
      status: TaskStatus.notStarted,
      priority: Priority.low,
      startMinutes: const Value(480),
    ));

    final tasks = await repo.getTasksOn(day);
    expect(tasks.map((t) => t.title).toList(), ['earlier', 'later']);
  });

  test('exam + per-subject results', () async {
    final examRepo = ExamRepository(db);
    final studyRepo = StudyRepository(db);

    final subjectId = await studyRepo.addSubject('Physics');
    final examId = await examRepo.addExam(
      title: 'آزمون آزمایشی ۱',
      type: ExamType.mock,
      date: DateTime(2026, 10, 2),
      durationMinutes: 180,
    );

    await examRepo.addResult(ExamResultsCompanion.insert(
      examId: examId,
      subjectId: Value(subjectId),
      correct: const Value(30),
      wrong: const Value(6),
      unanswered: const Value(4),
      score: const Value(18.5),
    ));
    await examRepo.addResult(ExamResultsCompanion.insert(
      examId: examId,
      correct: const Value(80),
      wrong: const Value(20),
      unanswered: const Value(10),
    ));

    final results = await examRepo.getResultsForExam(examId);
    expect(results.length, 2);

    // Deleting the exam cascades its results (manual cascade).
    await examRepo.deleteExam(examId);
    expect(await examRepo.getResultsForExam(examId), isEmpty);
    expect(await db.select(db.exams).get(), isEmpty);
  });

  test('lifestyle entry upserts one record per day', () async {
    final repo = LifestyleRepository(db);
    final today = DateTime.now();

    await repo.upsertEntry(LifestyleEntriesCompanion.insert(
      date: today,
      sleepMinutes: const Value(420),
      mood: const Value(4),
    ));
    await repo.upsertEntry(LifestyleEntriesCompanion.insert(
      date: today,
      sleepMinutes: const Value(480),
      energy: const Value(5),
    ));

    final entry = await repo.getEntry(today);
    expect(entry!.sleepMinutes, 480);
    expect(entry.energy, 5);
    expect(await db.select(db.lifestyleEntries).get().then((r) => r.length), 1);
  });

  test('study sessions persist with type', () async {
    final repo = StudyRepository(db);
    final subjectId = await repo.addSubject('Chemistry');

    await repo.addSession(
      subjectId: subjectId,
      start: DateTime(2026, 9, 25, 8),
      end: DateTime(2026, 9, 25, 10, 30),
      type: SessionType.problemSolving,
    );

    final sessions = await (db.select(db.studySessions)).get();
    expect(sessions.single.type, SessionType.problemSolving);
    expect(sessions.single.end.difference(sessions.single.start).inMinutes, 150);
  });

  test('schema v1 created all tables', () async {
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table'",
          readsFrom: {},
        )
        .get();
    final names = tables.map((row) => row.data['name'] as String).toSet();
    for (final expected in [
      'subjects',
      'topics',
      'plan_tasks',
      'study_sessions',
      'exams',
      'exam_results',
      'lifestyle_entries',
      'strategic_plans',
      'milestones',
    ]) {
      expect(names, contains(expected), reason: 'missing table: $expected');
    }
  });
}
