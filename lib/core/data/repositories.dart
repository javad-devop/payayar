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
        AIMessage,
        Notification,
        Flashcard,
        ReviewItem;
export '../database/tables.dart'
    show
        Priority,
        TaskStatus,
        TopicStatus,
        SessionType,
        ExamType,
        AppNotificationStatus;

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

/// Local notifications (HANDOFF §43.1): SQLite rows — no push server.
/// Drives the bell badge (pending rows) and the history panel, and
/// implements the «انجام وظیفه» action which ALWAYS re-checks the
/// linked task's *current* status before touching anything.
class NotificationRepository {
  NotificationRepository(this._db);
  final AppDatabase _db;

  static const _settled = [
    AppNotificationStatus.read,
    AppNotificationStatus.actioned,
    AppNotificationStatus.dismissed,
  ];

  /// Pending rows (created/unread), newest first — bell badge source.
  Stream<List<Notification>> watchActive() =>
      (_db.select(_db.notifications)
            ..where((n) => n.status.isNotIn(_settled.map((s) => s.index)))
            ..orderBy([
              (n) => OrderingTerm.desc(n.createdAt),
              (n) => OrderingTerm.desc(n.id),
            ]))
          .watch();

  /// Full history, newest first — history panel source.
  Stream<List<Notification>> watchHistory() =>
      (_db.select(_db.notifications)
            ..orderBy([
              (n) => OrderingTerm.desc(n.createdAt),
              (n) => OrderingTerm.desc(n.id),
            ]))
          .watch();

  Future<int> addNotification({
    required String title,
    String? body,
    int? taskId,
  }) {
    return _db.into(_db.notifications).insert(
          NotificationsCompanion.insert(
            title: title,
            body: Value(body),
            taskId: Value(taskId),
          ),
        );
  }

  /// Panel opened: every pending row becomes `read`.
  Future<void> markAllRead() {
    return (_db.update(_db.notifications)
          ..where((n) => n.status.isNotIn(_settled.map((s) => s.index))))
        .write(NotificationsCompanion(
      status: const Value(AppNotificationStatus.read),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> dismiss(int id) {
    return (_db.update(_db.notifications)..where((n) => n.id.equals(id)))
        .write(NotificationsCompanion(
      status: const Value(AppNotificationStatus.dismissed),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// «انجام وظیفه» — the mandated live re-check (HANDOFF §43.1):
  /// * notification missing        → null
  /// * no linked task             → `read` (nothing to complete)
  /// * task deleted meanwhile      → `dismissed`
  /// * task already completed     → `actioned`, task untouched
  /// * otherwise                  → complete the task → `actioned`
  Future<AppNotificationStatus?> actionTask(int id) async {
    final n = await (_db.select(_db.notifications)
          ..where((x) => x.id.equals(id)))
        .getSingleOrNull();
    if (n == null) return null;
    final now = DateTime.now();
    final taskId = n.taskId;

    if (taskId == null) {
      await (_db.update(_db.notifications)..where((x) => x.id.equals(id)))
          .write(NotificationsCompanion(
        status: const Value(AppNotificationStatus.read),
        updatedAt: Value(now),
      ));
      return AppNotificationStatus.read;
    }

    final task = await (_db.select(_db.planTasks)
          ..where((t) => t.id.equals(taskId)))
        .getSingleOrNull();
    if (task == null) {
      await dismiss(id);
      return AppNotificationStatus.dismissed;
    }

    if (task.status != TaskStatus.completed) {
      await (_db.update(_db.planTasks)..where((t) => t.id.equals(task.id)))
          .write(PlanTasksCompanion(
        status: const Value(TaskStatus.completed),
        completedAt: Value(now),
      ));
    }

    await (_db.update(_db.notifications)..where((x) => x.id.equals(id)))
        .write(NotificationsCompanion(
      status: const Value(AppNotificationStatus.actioned),
      updatedAt: Value(now),
    ));
    return AppNotificationStatus.actioned;
  }
}

/// A flashcard together with its review state — management list item.
class FlashcardWithBox {
  const FlashcardWithBox({
    required this.card,
    required this.box,
    required this.dueAt,
    this.lastReviewedAt,
  });

  final Flashcard card;
  final int box;
  final DateTime dueAt;
  final DateTime? lastReviewedAt;
}

/// Flashcards with SM-2-lite spaced repetition (HANDOFF §45, AGENTS §13):
/// every card owns exactly one review item; grading advances/resets the
/// box and schedules the next [ReviewItem.dueAt].
///
/// Box intervals: 1 → 1 day, 2 → 2, 3 → 4, 4 → 8, 5 → 16 days.
/// "Forgot" always restarts at box 1 with a 10-minute re-queue.
class FlashcardRepository {
  FlashcardRepository(this._db);

  final AppDatabase _db;

  /// Days between reviews, indexed by box-1 (box 1..5).
  static const _boxDays = [1, 2, 4, 8, 16];
  static const _minBox = 1;
  static const _maxBox = 5;

  /// Registers a card that is due immediately (box 1).
  Future<int> addCard({
    required String front,
    required String back,
    int? subjectId,
    int? topicId,
  }) {
    return _db.transaction(() async {
      final cardId = await _db.into(_db.flashcards).insert(
            FlashcardsCompanion.insert(
              front: front,
              back: back,
              subjectId: Value(subjectId),
              topicId: Value(topicId),
            ),
          );
      await _db.into(_db.reviewItems).insert(
            ReviewItemsCompanion.insert(
              cardId: cardId,
              dueAt: DateTime.now(),
            ),
          );
      return cardId;
    });
  }

  /// Cards whose review is due, oldest first — today's queue.
  Stream<List<Flashcard>> watchDue() {
    final query = _db.select(_db.flashcards).join([
      innerJoin(_db.reviewItems,
          _db.reviewItems.cardId.equalsExp(_db.flashcards.id)),
    ])
      ..orderBy([OrderingTerm.asc(_db.reviewItems.dueAt)]);
    // Filter in Dart with a *fresh* now on every emission: baking
    // DateTime.now() into the SQL freezes it at subscription time, so cards
    // inserted after the stream was created would never match its re-queries.
    return query
        .map((row) {
          final dueAt = row.readTable(_db.reviewItems).dueAt;
          return dueAt.isAfter(DateTime.now())
              ? null
              : row.readTable(_db.flashcards);
        })
        .watch()
        .map((rows) => rows.whereType<Flashcard>().toList());
  }

  /// Every card with box state, newest first — management list.
  Stream<List<FlashcardWithBox>> watchAll() {
    final query = _db.select(_db.flashcards).join([
      innerJoin(_db.reviewItems,
          _db.reviewItems.cardId.equalsExp(_db.flashcards.id)),
    ])
      ..orderBy([OrderingTerm.desc(_db.flashcards.id)]);
    return query.watch().map((rows) => rows
        .map((row) => FlashcardWithBox(
              card: row.readTable(_db.flashcards),
              box: row.readTable(_db.reviewItems).box,
              dueAt: row.readTable(_db.reviewItems).dueAt,
              lastReviewedAt: row.readTable(_db.reviewItems).lastReviewedAt,
            ))
        .toList());
  }

  /// Records one review answer:
  /// - `known` → box+1 (capped), due in the new box's interval;
  /// - `!known` → box 1, due in 10 minutes.
  Future<void> grade(int cardId, {required bool known}) async {
    final item = await (_db.select(_db.reviewItems)
          ..where((r) => r.cardId.equals(cardId)))
        .getSingleOrNull();
    if (item == null) return;

    final now = DateTime.now();
    final nextBox =
        known ? (item.box + 1).clamp(_minBox, _maxBox) : _minBox;
    final due = known
        ? now.add(Duration(days: _boxDays[nextBox - 1]))
        : now.add(const Duration(minutes: 10));

    await (_db.update(_db.reviewItems)..where((r) => r.id.equals(item.id)))
        .write(ReviewItemsCompanion(
      box: Value(nextBox),
      dueAt: Value(due),
      lastReviewedAt: Value(now),
    ));
  }

  /// Deletes a card and its review item (explicit: FK cascade may be off
  /// on some platforms).
  Future<void> deleteCard(int cardId) {
    return _db.transaction(() async {
      await (_db.delete(_db.reviewItems)..where((r) => r.cardId.equals(cardId)))
          .go();
      await (_db.delete(_db.flashcards)..where((c) => c.id.equals(cardId)))
          .go();
    });
  }
}

/// دفترچهٔ یادداشت — journal entries (phase 11).
class JournalRepository {
  JournalRepository(this._db);
  final AppDatabase _db;

  Stream<List<JournalEntry>> watchEntries() =>
      (_db.select(_db.journalEntries)
            ..orderBy([
              (j) => OrderingTerm.desc(j.date),
              (j) => OrderingTerm.desc(j.id),
            ]))
          .watch();

  Future<int> addEntry({required DateTime date, required String text}) {
    return _db.into(_db.journalEntries).insert(
          JournalEntriesCompanion.insert(date: date, body: text),
        );
  }

  Future<void> deleteEntry(int id) async {
    await (_db.delete(_db.journalEntries)..where((j) => j.id.equals(id))).go();
  }
}
