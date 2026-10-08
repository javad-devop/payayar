import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/data/providers.dart';
import 'package:payayar/core/data/repositories.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/l10n/generated/app_localizations.dart';
import 'package:payayar/features/study/flashcard_dialog.dart';
import 'package:payayar/features/study/flashcards_card.dart';

// =====================================================================
// UI tests for HANDOFF §45 — study-page flashcards card:
//   * empty state offers the add dialog
//   * a due card offers the review session (sheet opens, flip works)
//   * management list shows box + front and can delete a card
// =====================================================================

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late FlashcardRepository flashcards;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    flashcards = FlashcardRepository(db);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpCard(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('fa'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(
            body: ListView(children: [FlashcardsCard()]),
          ),
        ),
      ),
    );
    // Two pumps: first build, then the streams' first emit.
    await tester.pump();
    await tester.pump();
  }

  testWidgets('empty state invites creating the first card', (tester) async {
    await pumpCard(tester);

    expect(find.text('هنوز کارتی نداری'), findsOneWidget);

    await tester.tap(find.text('افزودن کارت'));
    await tester.pumpAndSettle();
    expect(find.byType(FlashcardDialog), findsOneWidget);
  });

  testWidgets('add dialog creates a card and the card count appears',
      (tester) async {
    await pumpCard(tester);

    await tester.tap(find.text('افزودن کارت'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'پایتخت فرانسه؟');
    await tester.enterText(find.byType(TextField).last, 'پاریس');
    await tester.tap(find.text('ذخیره'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(FlashcardDialog), findsNothing);
    expect(find.text('۱ کارت برای امروز'), findsOneWidget);
    expect(find.text('شروع مرور'), findsOneWidget);
  });

  testWidgets('review sheet flips the card and finishes the session',
      (tester) async {
    await flashcards.addCard(front: 'قطر خورشید؟', back: '۱.۴ میلیون کیلومتر');
    await pumpCard(tester);

    await tester.tap(find.text('شروع مرور'));
    await tester.pumpAndSettle();

    expect(find.text('قطر خورشید؟'), findsOneWidget);
    expect(find.text('۱.۴ میلیون کیلومتر'), findsNothing);

    await tester.tap(find.text('نمایش پاسخ'));
    await tester.pump();
    expect(find.text('۱.۴ میلیون کیلومتر'), findsOneWidget);

    await tester.tap(find.text('بلد بودم'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('مرور امروز تمام شد!'), findsOneWidget);
  });

  testWidgets('management list shows box and deletes a card', (tester) async {
    final id = await flashcards.addCard(front: 'تعریف انرژی جنبشی', back: 'نصف × جرم × سرعت²');
    await pumpCard(tester);

    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();

    expect(find.text('تعریف انرژی جنبشی'), findsOneWidget);
    expect(find.textContaining('جعبه ۱'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    // Confirm dialog: delete is the affirmative action.
    await tester.tap(find.text('حذف').last);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(await flashcards.watchAll().first, isEmpty);
    expect(find.text('هنوز کارتی نداری'), findsOneWidget);
  });
}
