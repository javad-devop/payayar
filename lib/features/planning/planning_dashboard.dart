import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables.dart' show TaskStatus;

/// Aggregated planning numbers for the dashboard and Home
/// (planned vs actual stay separate — AGENTS.md §5).
class PlanningDashboard {
  const PlanningDashboard({
    this.todayPlannedTasks = 0,
    this.todayCompletedTasks = 0,
    this.todayPlannedMinutes = 0,
    this.overdueTasks = 0,
    this.upcomingTasks = 0,
    this.weekPlannedMinutes = 0,
    this.weekCompletedMinutes = 0,
  });

  final int todayPlannedTasks;
  final int todayCompletedTasks;
  final int todayPlannedMinutes;
  final int overdueTasks;
  final int upcomingTasks;
  final int weekPlannedMinutes;
  final int weekCompletedMinutes;

  double get completionRate =>
      todayPlannedTasks == 0 ? 0 : todayCompletedTasks / todayPlannedTasks;

  bool get isEmpty =>
      todayPlannedTasks == 0 &&
      overdueTasks == 0 &&
      upcomingTasks == 0 &&
      weekPlannedMinutes == 0;
}

DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _dayEnd(DateTime d) => _dayStart(d).add(const Duration(days: 1));

/// Aggregated study numbers for Home.
class StudySummary {
  const StudySummary({
    this.todayMinutes = 0,
    this.streakDays = 0,
  });

  final int todayMinutes;
  final int streakDays;

  bool get isEmpty => todayMinutes == 0 && streakDays == 0;
}

/// Computes the dashboard from reactive streams; recomputes
/// automatically whenever any underlying data changes.
final planningDashboardProvider = Provider<PlanningDashboard>((ref) {
  final tasks = ref.watch(planTasksProvider).value ?? const <PlanTask>[];
  final now = DateTime.now();
  final todayStart = _dayStart(now);
  final todayEnd = _dayEnd(now);

  var todayPlanned = 0;
  var todayCompleted = 0;
  var todayPlannedMinutes = 0;
  var overdue = 0;
  var upcoming = 0;
  var weekPlannedMinutes = 0;
  var weekCompletedMinutes = 0;

  final weekEnd = todayStart.add(const Duration(days: 7));

  for (final t in tasks) {
    final active = t.status != TaskStatus.cancelled &&
        t.status != TaskStatus.moved &&
        t.status != TaskStatus.skipped;
    if (!active) continue;

    final minutes = t.durationMinutes ?? 0;
    final isToday = !t.date.isBefore(todayStart) && t.date.isBefore(todayEnd);
    final isOverdue = t.date.isBefore(todayStart) &&
        (t.status == TaskStatus.notStarted || t.status == TaskStatus.inProgress);

    if (isToday) {
      todayPlanned++;
      todayPlannedMinutes += minutes;
      if (t.status == TaskStatus.completed) todayCompleted++;
    } else if (isOverdue) {
      overdue++;
    } else if (t.date.isAfter(todayEnd) && t.date.isBefore(weekEnd)) {
      upcoming++;
    }

    if (!t.date.isBefore(todayStart) && t.date.isBefore(weekEnd)) {
      weekPlannedMinutes += minutes;
      if (t.status == TaskStatus.completed) weekCompletedMinutes += minutes;
    }
  }

  return PlanningDashboard(
    todayPlannedTasks: todayPlanned,
    todayCompletedTasks: todayCompleted,
    todayPlannedMinutes: todayPlannedMinutes,
    overdueTasks: overdue,
    upcomingTasks: upcoming,
    weekPlannedMinutes: weekPlannedMinutes,
    weekCompletedMinutes: weekCompletedMinutes,
  );
});

final studySummaryProvider = Provider<StudySummary>((ref) {
  final sessions = ref.watch(studySessionsProvider).value ?? const <StudySession>[];
  final today = _dayStart(DateTime.now());

  var todayMinutes = 0;
  final activeDays = <String>{};

  for (final s in sessions) {
    final start = _dayStart(s.start);
    final minutes = s.end.difference(s.start).inMinutes.clamp(0, 24 * 60);
    if (start == today) todayMinutes += minutes;
    if (minutes >= 10) activeDays.add('${start.year}-${start.month}-${start.day}');
  }

  // Streak: consecutive days ending today (or yesterday, so the streak
  // does not visually reset before the day is studied).
  var streak = 0;
  var cursor = activeDays.contains('${today.year}-${today.month}-${today.day}')
      ? today
      : today.subtract(const Duration(days: 1));
  while (activeDays.contains('${cursor.year}-${cursor.month}-${cursor.day}')) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return StudySummary(todayMinutes: todayMinutes, streakDays: streak);
});

/// Next upcoming exam (soonest date >= now).
final nextExamProvider = Provider<Exam?>((ref) {
  final exams = ref.watch(examsProvider).value ?? const <Exam>[];
  final now = DateTime.now();
  final upcoming = exams.where((e) => !e.date.isBefore(now)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return upcoming.isEmpty ? null : upcoming.first;
});
