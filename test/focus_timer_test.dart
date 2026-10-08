import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/data/providers.dart';
import 'package:payayar/core/data/repositories.dart' show SessionType;
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/features/study/focus_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =====================================================================
// AGENTS.md §44 — Pomodoro & Focus
//
// The contract under test:
//   * §44.1 default length and automatic recording on completion
//   * §44.2 a completed session lands in the existing `study_sessions`
//     domain — no second source of truth
//   * §44.3 an abandoned session is NOT recorded unless the user confirms,
//     and a partial record stays distinguishable from a completed one
//   * §44.4 state lives in the app-scoped provider, so it is not tied to a
//     widget lifetime
// =====================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  FocusTimerNotifier notifier() => container.read(focusTimerProvider.notifier);
  FocusTimerState state() => container.read(focusTimerProvider);

  Future<List<StudySession>> sessions() =>
      db.select(db.studySessions).get();

  /// Runs [n] one-second ticks.
  Future<void> tickTimes(int n) async {
    for (var i = 0; i < n; i++) {
      await notifier().tick();
    }
  }

  test('start() begins a running session with the chosen length', () async {
    final subjectId = await container.read(studyRepositoryProvider)
        .addSubject('ریاضی');

    notifier().start(subjectId: subjectId, minutes: 25);

    expect(state().phase, FocusPhase.running);
    expect(state().elapsedSeconds, 0);
    expect(state().plannedMinutes, 25);
    expect(state().subjectId, subjectId);
    expect(state().completed, isFalse);
    expect(state().progress, 0);

    await notifier().endEarly(record: false);
  });

  test('ticks accumulate and pause freezes the clock (§44.1)', () async {
    final subjectId = await container.read(studyRepositoryProvider)
        .addSubject('فیزیک');
    notifier().start(subjectId: subjectId, minutes: 25);

    await tickTimes(10);
    expect(state().elapsedSeconds, 10);
    expect(state().remainingSeconds, 25 * 60 - 10);

    notifier().pause();
    expect(state().phase, FocusPhase.paused);

    // Ticking while paused must be a no-op.
    await tickTimes(5);
    expect(state().elapsedSeconds, 10);

    notifier().resume();
    expect(state().phase, FocusPhase.running);
    await tickTimes(1);
    expect(state().elapsedSeconds, 11);

    await notifier().endEarly(record: false);
  });

  test('reaching the planned time records a session automatically (§44.1/§44.2)',
      () async {
    final repo = container.read(studyRepositoryProvider);
    final subjectId = await repo.addSubject('شیمی');

    // Use the shortest allowed length so the test stays fast.
    notifier().start(subjectId: subjectId, minutes: 5);
    expect(state().plannedSeconds, 300);

    await tickTimes(299);
    expect(state().phase, FocusPhase.running,
        reason: 'one second short of the goal must still be running');
    expect(await sessions(), isEmpty,
        reason: 'nothing is recorded before the session is over');

    await notifier().tick();

    expect(state().phase, FocusPhase.finished);
    expect(state().completed, isTrue);
    expect(state().elapsedSeconds, 300);

    final rows = await sessions();
    expect(rows, hasLength(1));
    expect(rows.single.subjectId, subjectId);
    expect(rows.single.type, SessionType.learning);
    expect(rows.single.notes, FocusTimerNotifier.completedNotes,
        reason: 'completed sessions carry the "pomodoro completed" marker');
    expect(rows.single.end.difference(rows.single.start).inSeconds, 300,
        reason: 'recorded duration must equal the planned duration (§44.2)');
    expect(state().lastSessionId, rows.single.id);
  });

  test('ending early without confirmation writes nothing (§44.3)', () async {
    final subjectId = await container.read(studyRepositoryProvider)
        .addSubject('ادبیات');
    notifier().start(subjectId: subjectId, minutes: 25);
    await tickTimes(45);

    final id = await notifier().endEarly(record: false);

    expect(id, isNull);
    expect(await sessions(), isEmpty,
        reason: 'an abandoned session must never be recorded silently');
    expect(state().phase, FocusPhase.idle);
    expect(state().elapsedSeconds, 0);
  });

  test('confirmed partial session is saved and distinguishable (§44.3)',
      () async {
    final subjectId = await container.read(studyRepositoryProvider)
        .addSubject('زبان');
    notifier().start(subjectId: subjectId, minutes: 25);
    await tickTimes(120);

    final id = await notifier().endEarly(record: true);

    expect(id, isNotNull);
    expect(state().phase, FocusPhase.finished);
    expect(state().completed, isFalse);

    final rows = await sessions();
    expect(rows, hasLength(1));
    expect(rows.single.notes, FocusTimerNotifier.partialNotes);
    expect(rows.single.notes, isNot(FocusTimerNotifier.completedNotes),
        reason: 'a partial session must not look like a completed one');
    expect(rows.single.end.difference(rows.single.start).inSeconds, 120,
        reason: 'only the elapsed time is recorded');
  });

  test('a partial session shorter than a second is not recorded (§44.3)',
      () async {
    final subjectId = await container.read(studyRepositoryProvider)
        .addSubject('تاریخ');
    notifier().start(subjectId: subjectId, minutes: 25);

    final id = await notifier().endEarly(record: true);

    expect(id, isNull);
    expect(await sessions(), isEmpty);
  });

  test('duration is clamped to a safe range instead of trusted (§25)', () async {
    final subjectId = await container.read(studyRepositoryProvider)
        .addSubject('جغرافیا');

    notifier().start(subjectId: subjectId, minutes: 2);
    expect(state().plannedMinutes, 5, reason: 'lower bound is 5 minutes');

    await notifier().endEarly(record: false);

    notifier().start(subjectId: subjectId, minutes: 9999);
    expect(state().plannedMinutes, 180, reason: 'upper bound is 180 minutes');

    await notifier().endEarly(record: false);
  });

  test('reset() returns a finished session to the idle start state', () async {
    final subjectId = await container.read(studyRepositoryProvider)
        .addSubject('زیست');
    notifier().start(subjectId: subjectId, minutes: 5);
    await tickTimes(300);
    expect(state().phase, FocusPhase.finished);

    notifier().reset();

    expect(state().phase, FocusPhase.idle);
    expect(state().elapsedSeconds, 0);
    expect(state().lastSessionId, isNull);
    expect(state().completed, isFalse);
    // Still exactly one recorded session — reset must not touch the DB.
    expect(await sessions(), hasLength(1));
  });

  test('the session survives reading the provider again (app-scoped §44.4)',
      () async {
    final subjectId = await container.read(studyRepositoryProvider)
        .addSubject('منطق');
    notifier().start(subjectId: subjectId, minutes: 25);
    await tickTimes(7);

    // Re-reading through the provider returns the same live state; nothing
    // is stored in a widget, so navigating away cannot reset it.
    expect(container.read(focusTimerProvider).elapsedSeconds, 7);
    expect(container.read(focusTimerProvider).phase, FocusPhase.running);

    await notifier().endEarly(record: false);
  });
}
