import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/l10n/generated/app_localizations.dart';
import 'package:payayar/features/reports/grade_calculator.dart';

void main() {
  testWidgets('weighted average updates as scores are typed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fa'),
        home: Scaffold(
          body: ListView(children: [const GradeCalculatorCard()]),
        ),
      ),
    );

    // Two starter rows → four fields: score, weight, score, weight.
    expect(find.byType(TextField), findsNWidgets(4));

    await tester.enterText(find.byType(TextField).at(0), '10');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(2), '20');
    await tester.pump();

    // Equal weights → 15.00 shown in Persian digits.
    expect(find.text('۱۵.۰۰'), findsOneWidget);

    // Doubling the second row's weight → (10*1 + 20*2) / 3 = 16.67.
    await tester.enterText(find.byType(TextField).at(3), '2');
    await tester.pump();
    expect(find.text('۱۶.۶۷'), findsOneWidget);
  });
}
