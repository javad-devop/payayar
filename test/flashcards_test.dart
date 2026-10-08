import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/data/repositories.dart';

// =====================================================================
// Flashcards — SM-2-lite spaced repetition (HANDOFF §45, AGENTS §13):
//   * a new card lands in box 1 and is due immediately
//   * "knew it" advances the box and pushes dueAt out 1/2/4/8/16 days
//   * "forgot" resets to box 1 with a 10-minute re-queue
//   * box never leaves 1..5
// =====================================================================

void main() {
  late AppDatabase db;
  late FlashcardRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = FlashcardRepository(db);
  });

  tearDown(() => db.close());

  Future<int> addCard({String front = '۲ × ۳؟', String back = '۶'}) {
    return repo.addCard(front: front, back: back);
  }

  test('new card starts in box 1 and is due now', () async {
    final id = await addCard();

    final due = await repo.watchDue().first;
    expect(due.single.id, id);
    expect(due.single.front, '۲ × ۳؟');

    final all = await repo.watchAll().first;
    expect(all.single.box, 1);
  });

  test('«knew it» advances the box and schedules the next review', () async {
    final id = await addCard();
    final before = DateTime.now();

    await repo.grade(id, known: true);

    final all = await repo.watchAll().first;
    expect(all.single.box, 2);
    expect(all.single.dueAt.difference(before).inHours, greaterThanOrEqualTo(47));
    expect(all.single.lastReviewedAt, isNotNull);
    expect(await repo.watchDue().first, isEmpty,
        reason: 'graded cards leave today\'s queue');
  });

  test('«forgot» resets to box 1 and re-queues within the hour', () async {
    final id = await addCard();
    await repo.grade(id, known: true);
    await repo.grade(id, known: true);

    await repo.grade(id, known: false);

    final all = await repo.watchAll().first;
    expect(all.single.box, 1);
    final inOneHour = DateTime.now().add(const Duration(hours: 1));
    expect(all.single.dueAt.isBefore(inOneHour), isTrue);
  });

  test('box is capped at 5', () async {
    final id = await addCard();
    for (var i = 0; i < 8; i++) {
      await repo.grade(id, known: true);
    }

    final all = await repo.watchAll().first;
    expect(all.single.box, 5);
  });

  test('watchAll is newest first and includes box + due', () async {
    await addCard(front: 'قدیمی');
    await addCard(front: 'تازه');

    final all = await repo.watchAll().first;
    expect(all.map((c) => c.card.front), ['تازه', 'قدیمی']);
    expect(all.every((c) => c.box == 1), isTrue);
  });

  test('deleteCard removes the card and its review item', () async {
    final id = await addCard();

    await repo.deleteCard(id);

    expect(await repo.watchAll().first, isEmpty);
    expect(await repo.watchDue().first, isEmpty);
  });

  test('grading a missing card is a no-op', () async {
    await repo.grade(9999, known: true);
    expect(await repo.watchAll().first, isEmpty);
  });
}
