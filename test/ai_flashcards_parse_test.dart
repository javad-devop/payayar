import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/features/study/ai_flashcard_dialog.dart';

void main() {
  group('parseAiCards', () {
    test('parses a plain JSON array', () {
      final cards = parseAiCards(
        '[{"front": "2 + 2?", "back": "4"}, {"front": "Q2", "back": "A2"}]',
      );
      expect(cards, hasLength(2));
      expect(cards.first.front, '2 + 2?');
      expect(cards.first.back, '4');
    });

    test('tolerates markdown fences and surrounding prose', () {
      final cards = parseAiCards(
        'Here are your cards:\n```json\n'
        '[{"q": "Capital of France?", "a": "Paris"}]\n```\nEnjoy!',
      );
      expect(cards, hasLength(1));
      expect(cards.first.front, 'Capital of France?');
      expect(cards.first.back, 'Paris');
    });

    test('accepts question/answer keys and skips invalid rows', () {
      final cards = parseAiCards(
        '[{"question": "Q", "answer": "A"}, '
        '{"front": "", "back": "no front"}, '
        '{"front": "ok", "back": ""}, 42]',
      );
      expect(cards, hasLength(1));
      expect(cards.first.front, 'Q');
    });

    test('returns empty on garbage', () {
      expect(parseAiCards('sorry, I cannot do that'), isEmpty);
      expect(parseAiCards('[not json'), isEmpty);
      expect(parseAiCards('{"front": "x"}'), isEmpty);
    });
  });
}
