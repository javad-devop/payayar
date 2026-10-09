import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/features/exams/ai_quiz_dialog.dart';

void main() {
  group('parseAiQuiz', () {
    test('parses int correct index', () {
      final questions = parseAiQuiz(
        '[{"question": "2+2?", "options": ["3", "4", "5", "6"], "correct": 1}]',
      );
      expect(questions, hasLength(1));
      expect(questions.first.correct, 1);
      expect(questions.first.options, hasLength(4));
    });

    test('accepts letter and digit-string answers through fences', () {
      final questions = parseAiQuiz(
        'Sure!\n```json\n'
        '[{"q": "Capital?", "choices": ["Tehran", "Paris"], "correct": "B"},'
        ' {"question": "Sky color?", "options": ["blue", "green"], "correct": "1"}]'
        '\n```',
      );
      expect(questions, hasLength(2));
      expect(questions[0].correct, 1);
      expect(questions[1].correct, 1);
    });

    test('drops rows with missing options or out-of-range correct', () {
      final questions = parseAiQuiz(
        '[{"question": "no options", "correct": 0},'
        ' {"question": "bad", "options": ["a", "b"], "correct": 5},'
        ' {"question": "good", "options": ["a", "b"], "correct": 0}]',
      );
      expect(questions, hasLength(1));
      expect(questions.first.question, 'good');
    });

    test('returns empty on garbage', () {
      expect(parseAiQuiz('I cannot generate that'), isEmpty);
      expect(parseAiQuiz('[broken'), isEmpty);
    });
  });
}
