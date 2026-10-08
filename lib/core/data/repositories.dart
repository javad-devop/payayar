import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

export '../database/app_database.dart'
    show
        Subject,
        Topic,
        StudySession,
        PlanTask,
        StrategicPlan,
        Milestone,
        Exam,
        ExamResult,
        LifestyleEntry,
        AIConversation,
        AIMessage;
export '../database/tables.dart'
    show
        Priority,
        TaskStatus,
        TopicStatus,
        SessionType,
        ExamType;

/// Study domain: subjects, topics, sessions.
class StudyRepository {
  StudyRepository(this._db);
  final AppDatabase _db;

  // ---- Subjects ----

  Stream<List<Subject>> watchSubjects() =>
      (_db.select(_db.subjects)
            ..orderBy([(s) => OrderingTerm(expression: s.name)]))
          .watch();

  Future<List<Subject>> getSubjects() =>
      (_db.select(_db.subjects)
            ..orderBy([(s) => OrderingTerm(expression: s.name)]))
          .get();

  Future<Subject> getSubject(int id) async =>
      (await (_db.select(_db.subjects)..where((s) => s.id.equals(id))).get())
          .single;

  Future<int> addSubject(String name, {String? category, Priority priority = Priority.medium}) {
    return _db.into(_db.subjects).insert(
          SubjectsCompanion.insert(
            name: name,
            category: Value(category),
            priority: priority,
          ),
        );
  }

  Future<void> updateSubject(Subject subject) =>
      _db.update(_db.subjects).replace(subject);

  Future<int> deleteSubject(int id) =>
      (_db.delete(_db.subjects)..where((s) => s.id.equals(id))).go();

  // ---- Topics ----

  Stream<List<Topic>> watchTopics(int subjectId) =>
      (_db.select(_db.topics)
            ..where((t) => t.subjectId.equals(subjectId))
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .watch();

  Stream<List<Topic>> watchAllTopics() =>
      (_db.select(_db.topics)
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .watch();

  Future<int> addTopic({
    required int subjectId,
    required String name,
    int? parentTopicId,
  }) {
    return _db.into(_db.topics).insert(
          TopicsCompanion.insert(
            subjectId: subjectId,
            name: name,
            parentTopicId: Value(parentTopicId),
            status: TopicStatus.notStarted,
          ),
        );
  }

  Future<void> updateTopic(Topic topic) => _db.update(_db.topics).replace(topic);

  Future<int> deleteTopic(int id) =>
      (_db.delete(_db.topics)..where((t) => t.id.equals(id))).go();

  // ---- Study sessions ----

  Stream<List<StudySession>> watchSessions({int? subjectId, int? topicId}) {
    final query = _db.select(_db.studySessions);
    if (subjectId != null) query.where((s) => s.subjectId.equals(subjectId));
    if (topicId != null) query.where((s) => s.topicId.equals(topicId));
    query.orderBy([(s) => OrderingTerm(expression: s.start, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<int> addSession({
    required int subjectId,
    int? topicId,
    required DateTime start,
    required DateTime end,
    required SessionType type,
    String? notes,
  }) {
    return _db.into(_db.studySessions).insert(
          StudySessionsCompanion.insert(
            subjectId: subjectId,
            start: start,
            end: end,
            type: type,
            topicId: Value(topicId),
            notes: Value(notes),
          ),
        );
  }

  Future<int> deleteSession(int id) =>
      (_db.delete(_db.studySessions)..where((s) => s.id.equals(id))).go();
}

/// Planning domain: strategic plans, milestones, plan tasks.
class PlanningRepository {
  PlanningRepository(this._db);
  final AppDatabase _db;

  // ---- Strategic plan ----

  Stream<List<StrategicPlan>> watchPlans() =>
      (_db.select(_db.strategicPlans)
            ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]))
          .watch();

  Future<int> addPlan({
    required String goal,
    String? targetExam,
    DateTime? targetDate,
    String? notes,
  }) {
    return _db.into(_db.strategicPlans).insert(
          StrategicPlansCompanion.insert(
            goal: goal,
            targetExam: Value(targetExam),
            targetDate: Value(targetDate),
            notes: Value(notes),
          ),
        );
  }

  Future<void> updatePlan(StrategicPlan plan) =>
      _db.update(_db.strategicPlans).replace(plan);

  Future<int> deletePlan(int id) =>
      (_db.delete(_db.strategicPlans)..where((p) => p.id.equals(id))).go();

  // ---- Milestones ----

  Stream<List<Milestone>> watchMilestones(int planId) =>
      (_db.select(_db.milestones)
            ..where((m) => m.planId.equals(planId))
            ..orderBy([(m) => OrderingTerm(expression: m.sortOrder)]))
          .watch();

  Future<int> addMilestone({
    required int planId,
    required String title,
    DateTime? dueDate,
    int sortOrder = 0,
  }) {
    return _db.into(_db.milestones).insert(
          MilestonesCompanion.insert(
            planId: planId,
            title: title,
            dueDate: Value(dueDate),
            sortOrder: Value(sortOrder),
          ),
        );
  }

  Future<void> updateMilestone(Milestone m) =>
      _db.update(_db.milestones).replace(m);

  Future<int> deleteMilestone(int id) =>
      (_db.delete(_db.milestones)..where((m) => m.id.equals(id))).go();

  // ---- Plan tasks ----

  Stream<List<PlanTask>> watchTasks() =>
      (_db.select(_db.planTasks)
            ..orderBy([
              (t) => OrderingTerm(expression: t.date),
              (t) => OrderingTerm(expression: t.startMinutes),
            ]))
          .watch();

  Stream<List<PlanTask>> watchTasksOn(DateTime date) =>
      (_db.select(_db.planTasks)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(DateTime(date.year, date.month, date.day)) &
                t.date.isSmallerThanValue(
                    DateTime(date.year, date.month, date.day + 1)))
            ..orderBy([(t) => OrderingTerm(expression: t.startMinutes)]))
          .watch();

  Future<List<PlanTask>> getTasksOn(DateTime date) =>
      (_db.select(_db.planTasks)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(DateTime(date.year, date.month, date.day)) &
                t.date.isSmallerThanValue(
                    DateTime(date.year, date.month, date.day + 1)))
            ..orderBy([(t) => OrderingTerm(expression: t.startMinutes)]))
          .get();

  Future<PlanTask> getTask(int id) async =>
      (await (_db.select(_db.planTasks)..where((t) => t.id.equals(id))).get())
          .single;

  Future<int> addTask(PlanTasksCompanion entry) =>
      _db.into(_db.planTasks).insert(entry);

  Future<void> updateTask(PlanTask task) =>
      _db.update(_db.planTasks).replace(task);

  Future<int> deleteTask(int id) =>
      (_db.delete(_db.planTasks)..where((t) => t.id.equals(id))).go();

  Future<void> setStatus(int id, TaskStatus status) {
    return (_db.update(_db.planTasks)..where((t) => t.id.equals(id))).write(
      PlanTasksCompanion(
        status: Value(status),
        completedAt: Value(
          status == TaskStatus.completed ? DateTime.now() : null,
        ),
      ),
    );
  }

  /// Moves a task to another day (rescheduling).
  Future<void> moveTo(int id, DateTime date) {
    return (_db.update(_db.planTasks)..where((t) => t.id.equals(id)))
        .write(PlanTasksCompanion(date: Value(date)));
  }
}

/// Exams domain.
class ExamRepository {
  ExamRepository(this._db);
  final AppDatabase _db;

  Stream<List<Exam>> watchExams() =>
      (_db.select(_db.exams)
            ..orderBy([(e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc)]))
          .watch();

  Stream<List<Exam>> watchUpcoming(DateTime now) =>
      (_db.select(_db.exams)
            ..where((e) => e.date.isBiggerOrEqualValue(now))
            ..orderBy([(e) => OrderingTerm(expression: e.date)]))
          .watch();

  Future<Exam> getExam(int id) async =>
      (await (_db.select(_db.exams)..where((e) => e.id.equals(id))).get())
          .single;

  Future<int> addExam({
    required String title,
    required ExamType type,
    required DateTime date,
    int? durationMinutes,
    String? description,
    String? notes,
  }) {
    return _db.into(_db.exams).insert(
          ExamsCompanion.insert(
            title: title,
            type: type,
            date: date,
            durationMinutes: Value(durationMinutes),
            description: Value(description),
            notes: Value(notes),
          ),
        );
  }

  Future<void> updateExam(Exam exam) => _db.update(_db.exams).replace(exam);

  Future<int> deleteExam(int id) async {
    await (_db.delete(_db.examResults)..where((r) => r.examId.equals(id))).go();
    return (_db.delete(_db.exams)..where((e) => e.id.equals(id))).go();
  }

  // ---- Results ----

  Stream<List<ExamResult>> watchResults(int examId) =>
      (_db.select(_db.examResults)..where((r) => r.examId.equals(examId)))
          .watch();

  Future<List<ExamResult>> getResultsForExam(int examId) =>
      (_db.select(_db.examResults)..where((r) => r.examId.equals(examId)))
          .get();

  Future<List<ExamResult>> getAllResults() => _db.select(_db.examResults).get();

  Future<int> addResult(ExamResultsCompanion entry) =>
      _db.into(_db.examResults).insert(entry);

  Future<void> updateResult(ExamResult result) =>
      _db.update(_db.examResults).replace(result);

  Future<int> deleteResult(int id) =>
      (_db.delete(_db.examResults)..where((r) => r.id.equals(id))).go();
}

/// Lifestyle domain — one record per day.
class LifestyleRepository {
  LifestyleRepository(this._db);
  final AppDatabase _db;

  Stream<List<LifestyleEntry>> watchEntries() =>
      (_db.select(_db.lifestyleEntries)
            ..orderBy([(l) => OrderingTerm(expression: l.date, mode: OrderingMode.desc)]))
          .watch();

  Future<LifestyleEntry?> getEntry(DateTime date) async {
    // Day-range match (start inclusive, end exclusive) — the same pattern
    // as PlanningRepository.getTasksOn. Comparing extracted year/month/day
    // would use UTC parts, which mismatches locally-created timestamps
    // around midnight offsets (Iran is UTC+3:30).
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.lifestyleEntries)
          ..where((l) =>
              l.date.isBiggerOrEqualValue(start) &
              l.date.isSmallerThanValue(end)))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Insert or update today's entry (idempotent per day).
  Future<void> upsertEntry(LifestyleEntriesCompanion entry) async {
    final existing = await getEntry(entry.date.value);
    if (existing == null) {
      await _db.into(_db.lifestyleEntries).insert(entry);
    } else {
      await (_db.update(_db.lifestyleEntries)
            ..where((l) => l.id.equals(existing.id)))
          .write(entry);
    }
  }

  Future<int> deleteEntry(int id) =>
      (_db.delete(_db.lifestyleEntries)..where((l) => l.id.equals(id))).go();
}

/// AI advisor conversations.
class AIRepository {
  AIRepository(this._db);
  final AppDatabase _db;

  Stream<List<AIConversation>> watchConversations() =>
      (_db.select(_db.aIConversations)
            ..orderBy([(c) => OrderingTerm(expression: c.createdAt, mode: OrderingMode.desc)]))
          .watch();

  Future<int> createConversation() =>
      _db.into(_db.aIConversations).insert(AIConversationsCompanion.insert());

  Stream<List<AIMessage>> watchMessages(int conversationId) =>
      (_db.select(_db.aIMessages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm(expression: m.createdAt)]))
          .watch();

  Future<int> addMessage({
    required int conversationId,
    required String role,
    required String content,
  }) {
    return _db.into(_db.aIMessages).insert(
          AIMessagesCompanion.insert(
            conversationId: conversationId,
            role: role,
            content: content,
          ),
        );
  }

  Future<int> deleteConversation(int id) async {
    await (_db.delete(_db.aIMessages)
          ..where((m) => m.conversationId.equals(id)))
        .go();
    return (_db.delete(_db.aIConversations)..where((c) => c.id.equals(id)))
        .go();
  }
}
