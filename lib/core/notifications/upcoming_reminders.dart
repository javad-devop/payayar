import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../data/repositories.dart';
import '../database/app_database.dart';
import '../l10n/generated/app_localizations.dart';
import '../util/shamsi.dart';

/// Staged reminders (phase 9): one in-app notification per
/// (event, stage) once the event enters its reminder window —
/// exams: 7 days / 3 days / tomorrow / today; tasks: tomorrow/today.
/// Idempotent (deduped by exact title), so running on every boot is
/// safe. Local-first: rows land in the existing Notifications table
/// and show up in the bell badge — no push server (HANDOFF §43.1).
Future<void> generateUpcomingReminders(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context);
  final db = ref.read(databaseProvider);
  final notifications = ref.read(notificationRepositoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Exams: 0..7 days away, one row per matching stage.
  final exams = await db.select(db.exams).get();
  for (final exam in exams) {
    final days = _daysUntil(today, exam.date);
    if (days < 0 || days > 7) continue;
    final String title = days == 0
        ? l10n.remind_examToday(exam.title)
        : days == 1
            ? l10n.remind_examTomorrow(exam.title)
            : (days == 3 || days == 7)
                ? l10n.remind_examInDays(exam.title, days)
                : '';
    if (title.isEmpty) continue;
    await _addIfNew(db, notifications, title: title, body: shamsiLong(exam.date));
  }

  // Plan tasks: only still-planned items, tomorrow / today.
  final tasks = await db.select(db.planTasks).get();
  for (final task in tasks) {
    final active = task.status == TaskStatus.notStarted ||
        task.status == TaskStatus.inProgress;
    if (!active) continue;
    final days = _daysUntil(today, task.date);
    if (days < 0 || days > 1) continue;
    final String title = days == 0
        ? l10n.remind_taskToday(task.title)
        : l10n.remind_taskTomorrow(task.title);
    await _addIfNew(db, notifications,
        title: title, body: shamsiLong(task.date), taskId: task.id);
  }
}

int _daysUntil(DateTime today, DateTime target) {
  final date = DateTime(target.year, target.month, target.day);
  return date.difference(today).inDays;
}

Future<void> _addIfNew(
  AppDatabase db,
  NotificationRepository repo, {
  required String title,
  String? body,
  int? taskId,
}) async {
  final existing =
      await (db.select(db.notifications)..where((n) => n.title.equals(title)))
          .get();
  if (existing.isNotEmpty) return;
  await repo.addNotification(title: title, body: body, taskId: taskId);
}
