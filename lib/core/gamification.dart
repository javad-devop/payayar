/// Pure XP / medal rules (phase 11) — derived from local data only,
/// no persistence of its own: recomputing from the same data always
/// yields the same score.
class GamificationStats {
  const GamificationStats({
    this.studyMinutes = 0,
    this.sessions = 0,
    this.streakDays = 0,
    this.tasksDone = 0,
    this.exams = 0,
  });

  final int studyMinutes;
  final int sessions;
  final int streakDays;
  final int tasksDone;
  final int exams;
}

/// XP ladder: 1 XP per 10 studied minutes, 10 per session, 15 per
/// completed task, 25 per exam — then one level per 100 XP.
int totalXp(GamificationStats stats) =>
    (stats.studyMinutes ~/ 10) +
    (stats.sessions * 10) +
    (stats.tasksDone * 15) +
    (stats.exams * 25);

int levelFor(int xp) => (xp ~/ 100) + 1;

/// Progress inside the current level, 0..100.
double levelProgress(int xp) => (xp % 100) / 100;

/// Stable medal ids — the UI maps each id to a localized title.
const medalIds = [
  'first_session',
  'streak_7',
  'sessions_10',
  'hours_10',
  'tasks_20',
  'exams_5',
];

/// Returns the earned subset of [medalIds] for the given stats.
Set<String> earnedMedals(GamificationStats stats) {
  final earned = <String>{};
  if (stats.sessions >= 1) earned.add('first_session');
  if (stats.streakDays >= 7) earned.add('streak_7');
  if (stats.sessions >= 10) earned.add('sessions_10');
  if (stats.studyMinutes >= 600) earned.add('hours_10');
  if (stats.tasksDone >= 20) earned.add('tasks_20');
  if (stats.exams >= 5) earned.add('exams_5');
  return earned;
}
