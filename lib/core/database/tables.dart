import 'package:drift/drift.dart';

/// Strategic / annual plan (AGENTS.md §10.2).
class StrategicPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get goal => text()();
  TextColumn get targetExam => text().nullable()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Milestones attached to a strategic plan.
class Milestones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(StrategicPlans, #id)();
  TextColumn get title => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Subjects — fully user-defined (no hard-coded subjects).
class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get category => text().nullable()();
  IntColumn get priority => intEnum<Priority>()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [{name}];
}

/// Topics (and sub-topics via parentTopicId) belonging to a subject.
class Topics extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  IntColumn get parentTopicId => integer()
      .nullable()
      .references(Topics, #id)();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  IntColumn get status => intEnum<TopicStatus>()();
  IntColumn get difficulty => integer().withDefault(const Constant(3))(); // 1..5
  IntColumn get mastery => integer().withDefault(const Constant(0))(); // 0..100
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Task statuses (AGENTS.md §11).
enum TaskStatus {
  notStarted,
  inProgress,
  completed,
  cancelled,
  moved,
  skipped,
}

/// Priority used by tasks, subjects and mock-exam drafts.
enum Priority { low, medium, high }

/// Topic progress status.
enum TopicStatus { notStarted, learning, reviewing, mastered }

/// A scheduled plan task — the atomic unit of the weekly/daily plan.
class PlanTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  IntColumn get subjectId => integer().nullable().references(Subjects, #id)();
  IntColumn get topicId => integer().nullable().references(Topics, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get startMinutes => integer().nullable()(); // minutes from midnight
  IntColumn get durationMinutes => integer().nullable()();
  IntColumn get status => intEnum<TaskStatus>()();
  IntColumn get priority => intEnum<Priority>()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Study session types (AGENTS.md §13).
enum SessionType { learning, review, test, problemSolving }

/// Recorded actual study sessions (planned vs actual stay separate).
class StudySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  IntColumn get topicId => integer().nullable().references(Topics, #id)();
  DateTimeColumn get start => dateTime()();
  DateTimeColumn get end => dateTime()();
  IntColumn get type => intEnum<SessionType>()();
  TextColumn get notes => text().nullable()();
}

/// Exam kinds.
enum ExamType { mock, school, personal, other }

/// Manually created exams.
class Exams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  IntColumn get type => intEnum<ExamType>()();
  DateTimeColumn get date => dateTime()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Exam results — one row per subject (subjectId null = overall).
class ExamResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examId => integer().references(Exams, #id)();
  IntColumn get subjectId => integer().nullable().references(Subjects, #id)();
  IntColumn get correct => integer().withDefault(const Constant(0))();
  IntColumn get wrong => integer().withDefault(const Constant(0))();
  IntColumn get unanswered => integer().withDefault(const Constant(0))();
  RealColumn get score => real().nullable()();
  IntColumn get timeSpentMinutes => integer().nullable()();
  TextColumn get notes => text().nullable()();
}

/// One lifestyle record per day (AGENTS.md §12 — lightweight).
class LifestyleEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get sleepMinutes => integer().nullable()();
  IntColumn get wakeMinutes => integer().nullable()(); // minutes from midnight
  IntColumn get exerciseMinutes => integer().nullable()();
  IntColumn get mood => integer().nullable()(); // 1..5
  IntColumn get energy => integer().nullable()(); // 1..5
  IntColumn get screenTimeMinutes => integer().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [{date}];
}

/// Standalone AI advisor conversations (AGENTS.md §7.B).
class AIConversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Messages inside an AI conversation.
class AIMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId => integer().references(AIConversations, #id)();
  TextColumn get role => text()(); // 'user' | 'assistant'
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Flashcard (front/back), optionally linked to a subject/topic so a
/// review record can point back at the curriculum (AGENTS.md §13).
class Flashcards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().nullable().references(Subjects, #id)();
  IntColumn get topicId => integer().nullable().references(Topics, #id)();
  TextColumn get front => text().withLength(min: 1, max: 500)();
  TextColumn get back => text().withLength(min: 1, max: 2000)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Spaced-repetition state per card — SM-2 lite (HANDOFF §45):
/// box 1..5; [dueAt] drives the "due today" queue.
class ReviewItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer().references(Flashcards, #id)();
  IntColumn get box => integer().withDefault(const Constant(1))();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
}

/// Local notification lifecycle (HANDOFF §43.1):
/// created → unread → read → actioned/dismissed.
enum AppNotificationStatus { created, unread, read, actioned, dismissed }

/// SQLite-backed local notifications — no push server (HANDOFF §43.1).
/// [taskId] links to a plan task so the bell action can re-check the
/// task's *current* status before completing it.
class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get body => text().nullable()();
  IntColumn get status =>
      intEnum<AppNotificationStatus>().withDefault(const Constant(0))();
  IntColumn get taskId => integer().nullable().references(PlanTasks, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
