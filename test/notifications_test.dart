import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/data/repositories.dart';

// =====================================================================
// Local notifications tests — HANDOFF §43.1:
//   lifecycle: created → unread → read → actioned/dismissed
//   + the «انجام وظیفه» action's MANDATORY live re-check of the task's
//     current status before completing anything.
// =====================================================================

void main() {
  late AppDatabase db;
  late NotificationRepository repo;
  late PlanningRepository planning;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = NotificationRepository(db);
    planning = PlanningRepository(db);
  });

  tearDown(() => db.close());

  Future<int> addTask({TaskStatus status = TaskStatus.notStarted}) {
    return planning.addTask(PlanTasksCompanion.insert(
      title: 'مرور ریاضی',
      date: DateTime(2026, 10, 8),
      status: status,
      priority: Priority.high,
    ));
  }

  Future<Notification> getNotification(int id) {
    return (db.select(db.notifications)..where((n) => n.id.equals(id)))
        .getSingle();
  }

  group('lifecycle', () {
    test('new notification starts as created and feeds the active stream',
        () async {
      final id = await repo.addNotification(title: 'وقت مطالعه', body: '۲۵ دقیقه');

      final active = await repo.watchActive().first;
      expect(active, hasLength(1));
      expect(active.first.id, id);
      expect(active.first.status, AppNotificationStatus.created);
      expect(active.first.title, 'وقت مطالعه');
      expect(active.first.body, '۲۵ دقیقه');
    });

    test('markAllRead moves every pending row to read', () async {
      await repo.addNotification(title: 'a');
      await repo.addNotification(title: 'b');

      await repo.markAllRead();

      expect(await repo.watchActive().first, isEmpty);
      final history = await repo.watchHistory().first;
      expect(history.map((n) => n.status),
          everyElement(AppNotificationStatus.read));
    });

    test('dismissed rows leave the badge but stay in history', () async {
      final id = await repo.addNotification(title: 'x');

      await repo.dismiss(id);

      expect(await repo.watchActive().first, isEmpty);
      final history = await repo.watchHistory().first;
      expect(history.single.status, AppNotificationStatus.dismissed);
    });

    test('history is newest first', () async {
      await repo.addNotification(title: 'first');
      await repo.addNotification(title: 'second');

      final history = await repo.watchHistory().first;
      expect(history.map((n) => n.title), ['second', 'first']);
    });
  });

  group('actionTask — live re-check (HANDOFF §43.1)', () {
    test('pending task → completed + notification actioned', () async {
      final taskId = await addTask();
      final nid = await repo.addNotification(title: 'وقت مطالعه', taskId: taskId);

      final status = await repo.actionTask(nid);

      expect(status, AppNotificationStatus.actioned);
      final task = await (db.select(db.planTasks)
            ..where((t) => t.id.equals(taskId)))
          .getSingle();
      expect(task.status, TaskStatus.completed);
      expect(task.completedAt, isNotNull);
      expect((await getNotification(nid)).status, AppNotificationStatus.actioned);
    });

    test('already-completed task → actioned WITHOUT re-completing it',
        () async {
      final taskId = await addTask();
      await planning.setStatus(taskId, TaskStatus.completed);
      final before =
          await (db.select(db.planTasks)..where((t) => t.id.equals(taskId)))
              .getSingle();
      final nid = await repo.addNotification(title: 'وقت مطالعه', taskId: taskId);
      await Future<void>.delayed(const Duration(milliseconds: 5));

      final status = await repo.actionTask(nid);

      expect(status, AppNotificationStatus.actioned);
      final after =
          await (db.select(db.planTasks)..where((t) => t.id.equals(taskId)))
              .getSingle();
      expect(after.completedAt, before.completedAt,
          reason: 'task must not be re-completed — status was re-checked');
    });

    test('deleted task → notification dismissed, nothing else touched',
        () async {
      final taskId = await addTask();
      final nid = await repo.addNotification(title: 'وقت مطالعه', taskId: taskId);
      await planning.deleteTask(taskId);

      final status = await repo.actionTask(nid);

      expect(status, AppNotificationStatus.dismissed);
      expect((await getNotification(nid)).status, AppNotificationStatus.dismissed);
      expect(
          await (db.select(db.planTasks)..where((t) => t.id.equals(taskId)))
              .get(),
          isEmpty);
    });

    test('notification without a linked task → read', () async {
      final nid = await repo.addNotification(title: 'عمومی');

      final status = await repo.actionTask(nid);

      expect(status, AppNotificationStatus.read);
      expect((await getNotification(nid)).status, AppNotificationStatus.read);
    });

    test('missing notification → null', () async {
      expect(await repo.actionTask(9999), isNull);
    });
  });
}
