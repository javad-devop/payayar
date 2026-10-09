import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/gamification.dart';

void main() {
  test('totalXp sums all sources', () {
    const stats = GamificationStats(
      studyMinutes: 125,
      sessions: 3,
      streakDays: 4,
      tasksDone: 2,
      exams: 1,
    );
    // 125~/10=12 + 3*10 + 2*15 + 25 = 97
    expect(totalXp(stats), 97);
  });

  test('levels step every 100 XP', () {
    expect(levelFor(0), 1);
    expect(levelFor(99), 1);
    expect(levelFor(100), 2);
    expect(levelFor(450), 5);
    expect(levelProgress(145), closeTo(0.45, 0.001));
  });

  test('medals unlock at their thresholds', () {
    var earned = earnedMedals(const GamificationStats());
    expect(earned, isEmpty);

    earned = earnedMedals(const GamificationStats(
      studyMinutes: 600,
      sessions: 10,
      streakDays: 7,
      tasksDone: 20,
      exams: 5,
    ));
    expect(earned, unorderedEquals(medalIds));

    earned = earnedMedals(const GamificationStats(sessions: 1, tasksDone: 19));
    expect(earned, {'first_session'});
  });
}
