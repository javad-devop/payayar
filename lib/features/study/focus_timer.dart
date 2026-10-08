import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/app_settings.dart';
import '../../core/data/providers.dart';
import '../../core/data/repositories.dart' show SessionType;

/// AGENTS.md §44 — Pomodoro & Focus.
///
/// The timer lives in a non-auto-disposed [Notifier] so navigating between
/// screens never destroys a running session (§44.4). The database write
/// happens through the study repository (§44.2): a completed session is
/// recorded in the existing `study_sessions` domain — never a second source
/// of truth.
///
/// The recorded `notes` distinguish the two outcomes required by §44.3:
///   * `pomodoro completed`  — reached the planned duration (auto-saved)
///   * `pomodoro partial`    — ended early, saved only after user confirm
enum FocusPhase {
  /// Nothing running; the card offers "start".
  idle,

  /// Ticking.
  running,

  /// Paused by the user; elapsed time is kept, no ticking.
  paused,

  /// Planned duration reached and the session has been recorded.
  finished,
}

@immutable
class FocusTimerState {
  const FocusTimerState({
    this.phase = FocusPhase.idle,
    this.subjectId,
    this.topicId,
    this.plannedMinutes = 25,
    this.elapsedSeconds = 0,
    this.completed = false,
    this.lastSessionId,
  });

  final FocusPhase phase;
  final int? subjectId;
  final int? topicId;

  /// Planned length of the current/last session, in minutes (§44.1 default 25).
  final int plannedMinutes;

  /// Seconds counted so far. Frozen while paused.
  final int elapsedSeconds;

  /// True when the session reached [plannedMinutes] by itself.
  final bool completed;

  /// Row id in `study_sessions` when a session was recorded.
  final int? lastSessionId;

  bool get isActive => phase == FocusPhase.running || phase == FocusPhase.paused;

  int get plannedSeconds => plannedMinutes * 60;

  /// 0.0 – 1.0, never > 1 (a partial session stays below it).
  double get progress =>
      plannedSeconds == 0 ? 0 : (elapsedSeconds / plannedSeconds).clamp(0.0, 1.0);

  int get remainingSeconds =>
      (plannedSeconds - elapsedSeconds).clamp(0, plannedSeconds);

  Duration get remaining => Duration(seconds: remainingSeconds);

  FocusTimerState copyWith({
    FocusPhase? phase,
    int? subjectId,
    int? topicId,
    int? plannedMinutes,
    int? elapsedSeconds,
    bool? completed,
    int? lastSessionId,
    bool clearSessionId = false,
  }) {
    return FocusTimerState(
      phase: phase ?? this.phase,
      subjectId: subjectId ?? this.subjectId,
      topicId: topicId ?? this.topicId,
      plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      completed: completed ?? this.completed,
      lastSessionId: clearSessionId ? null : (lastSessionId ?? this.lastSessionId),
    );
  }
}

class FocusTimerNotifier extends Notifier<FocusTimerState> {
  Timer? _ticker;

  /// Notes stored on the row so a partial session stays distinguishable
  /// from a completed one (AGENTS.md §44.3).
  static const completedNotes = 'pomodoro completed';
  static const partialNotes = 'pomodoro partial';

  /// Allowed session lengths offered by the UI (§44.1: user-configurable).
  static const allowedMinutes = [15, 25, 45, 60];

  @override
  FocusTimerState build() {
    ref.onDispose(_stopTicker);
    // Start from the persisted default so the setup dialog opens on it.
    return FocusTimerState(plannedMinutes: ref.read(appSettingsProvider).focusMinutes);
  }

  // ---------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------

  /// Begin a new session. Any previous (already resolved) session is cleared.
  void start({required int subjectId, int? topicId, required int minutes}) {
    _stopTicker();
    final safe = _clampMinutes(minutes);
    state = FocusTimerState(
      phase: FocusPhase.running,
      subjectId: subjectId,
      topicId: topicId,
      plannedMinutes: safe,
      elapsedSeconds: 0,
    );
    _startTicker();
  }

  void pause() {
    if (state.phase != FocusPhase.running) return;
    _stopTicker();
    state = state.copyWith(phase: FocusPhase.paused);
  }

  void resume() {
    if (state.phase != FocusPhase.paused) return;
    state = state.copyWith(phase: FocusPhase.running);
    _startTicker();
  }

  /// End an unfinished session.
  ///
  /// * `record: true`  → saves the elapsed time as a **partial** session.
  /// * `record: false` → writes nothing at all.
  ///
  /// Either way the timer stops; nothing is ever recorded silently (§44.3).
  Future<int?> endEarly({required bool record}) async {
    if (!state.isActive) return null;
    _stopTicker();
    final elapsed = state.elapsedSeconds;
    final subjectId = state.subjectId;

    if (!record || subjectId == null || elapsed <= 0) {
      state = const FocusTimerState();
      return null;
    }

    final id = await _record(
      subjectId: subjectId,
      topicId: state.topicId,
      seconds: elapsed,
      notes: partialNotes,
    );
    state = FocusTimerState(
      phase: FocusPhase.finished,
      subjectId: subjectId,
      topicId: state.topicId,
      plannedMinutes: state.plannedMinutes,
      elapsedSeconds: elapsed,
      completed: false,
      lastSessionId: id,
    );
    return id;
  }

  /// Return the card to its idle "start" state after a finished session.
  void reset() {
    if (state.isActive) return;
    _stopTicker();
    final minutes = ref.read(appSettingsProvider).focusMinutes;
    state = FocusTimerState(plannedMinutes: _clampMinutes(minutes));
  }

  // ---------------------------------------------------------------------
  // Ticking
  // ---------------------------------------------------------------------

  /// Advance by one second.
  ///
  /// Public and async so tests can drive the clock deterministically instead
  /// of depending on wall time; the real ticker calls it once per second.
  Future<void> tick() async {
    if (state.phase != FocusPhase.running) return;
    final next = state.elapsedSeconds + 1;

    if (next >= state.plannedSeconds) {
      await _complete();
      return;
    }
    state = state.copyWith(elapsedSeconds: next);
  }

  /// The planned duration was reached: record immediately (§44.1) and alert.
  Future<void> _complete() async {
    final s = state;
    if (s.phase != FocusPhase.running) return;
    _stopTicker();

    final id = s.subjectId == null
        ? null
        : await _record(
            subjectId: s.subjectId!,
            topicId: s.topicId,
            seconds: s.plannedSeconds,
            notes: completedNotes,
          );

    state = FocusTimerState(
      phase: FocusPhase.finished,
      subjectId: s.subjectId,
      topicId: s.topicId,
      plannedMinutes: s.plannedMinutes,
      elapsedSeconds: s.plannedSeconds,
      completed: true,
      lastSessionId: id,
    );
    await _alert();
  }

  Future<int?> _record({
    required int subjectId,
    int? topicId,
    required int seconds,
    required String notes,
  }) async {
    if (seconds <= 0) return null;
    final now = DateTime.now();
    final repo = ref.read(studyRepositoryProvider);
    // Anchor the row on "now" so the duration is right even if the session
    // was paused: duration = end - start = seconds.
    try {
      return await repo.addSession(
        subjectId: subjectId,
        topicId: topicId,
        start: now.subtract(Duration(seconds: seconds)),
        end: now,
        type: SessionType.learning,
        notes: notes,
      );
    } catch (e) {
      // A storage failure must never take the UI down with it (§36/§7.2);
      // the timer already reached its terminal state.
      debugPrint('focus: failed to record session: $e');
      return null;
    }
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => unawaited(tick()));
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Completion feedback (§44.1 "play a local alert sound").
  /// Best-effort: a platform that cannot alert must not break the session.
  Future<void> _alert() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  static int _clampMinutes(int minutes) {
    if (minutes < 5) return 5;
    if (minutes > 180) return 180;
    return minutes;
  }
}

/// Kept alive for the whole app session so a running timer survives
/// navigation (AGENTS.md §44.4).
final focusTimerProvider =
    NotifierProvider<FocusTimerNotifier, FocusTimerState>(FocusTimerNotifier.new);
