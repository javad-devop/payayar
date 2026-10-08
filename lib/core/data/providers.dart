import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'repositories.dart';

/// Single app-wide database instance. Overridden in tests with an
/// in-memory database.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final studyRepositoryProvider =
    Provider<StudyRepository>((ref) => StudyRepository(ref.watch(databaseProvider)));

final planningRepositoryProvider =
    Provider<PlanningRepository>((ref) => PlanningRepository(ref.watch(databaseProvider)));

final examRepositoryProvider =
    Provider<ExamRepository>((ref) => ExamRepository(ref.watch(databaseProvider)));

final lifestyleRepositoryProvider =
    Provider<LifestyleRepository>((ref) => LifestyleRepository(ref.watch(databaseProvider)));

final aiRepositoryProvider =
    Provider<AIRepository>((ref) => AIRepository(ref.watch(databaseProvider)));

/// Messages of one conversation.
final aiMessagesProvider = StreamProvider.family<List<AIMessage>, int>(
    (ref, conversationId) =>
        ref.watch(aiRepositoryProvider).watchMessages(conversationId));

// ---- Reactive stream providers (UI watches these) ----

final subjectsProvider = StreamProvider(
    (ref) => ref.watch(studyRepositoryProvider).watchSubjects());

final allTopicsProvider = StreamProvider(
    (ref) => ref.watch(studyRepositoryProvider).watchAllTopics());

final planTasksProvider = StreamProvider(
    (ref) => ref.watch(planningRepositoryProvider).watchTasks());

final examsProvider = StreamProvider(
    (ref) => ref.watch(examRepositoryProvider).watchExams());

final lifestyleEntriesProvider = StreamProvider(
    (ref) => ref.watch(lifestyleRepositoryProvider).watchEntries());

/// All study sessions (Home recent activity, topic history, reports).
final studySessionsProvider = StreamProvider(
    (ref) => ref.watch(studyRepositoryProvider).watchSessions());

/// Today's tasks (date-only comparison done in SQL).
final todayTasksProvider = StreamProvider<List<PlanTask>>((ref) {
  final today = DateTime.now();
  return ref.watch(planningRepositoryProvider).watchTasksOn(today);
});

/// All results (reports and exam analysis).
final allExamResultsProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.examResults)).watch();
});

// ---- Local notifications (HANDOFF §43.1) ----

final notificationRepositoryProvider = Provider<NotificationRepository>(
    (ref) => NotificationRepository(ref.watch(databaseProvider)));

/// Pending rows for the bell badge (created/unread only).
final activeNotificationsProvider = StreamProvider(
    (ref) => ref.watch(notificationRepositoryProvider).watchActive());

/// Full history for the panel.
final notificationHistoryProvider = StreamProvider(
    (ref) => ref.watch(notificationRepositoryProvider).watchHistory());

// ---- Flashcards (HANDOFF §45 — spaced repetition) ----

final flashcardRepositoryProvider = Provider(
    (ref) => FlashcardRepository(ref.watch(databaseProvider)));

/// Cards currently due for review.
final dueFlashcardsProvider = StreamProvider(
    (ref) => ref.watch(flashcardRepositoryProvider).watchDue());

/// Every card with its box state — management list.
final allFlashcardsProvider = StreamProvider(
    (ref) => ref.watch(flashcardRepositoryProvider).watchAll());
