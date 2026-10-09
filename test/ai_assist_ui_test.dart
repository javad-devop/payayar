import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/ai/ai_assist.dart';
import 'package:payayar/core/ai/ai_provider.dart';
import 'package:payayar/core/l10n/generated/app_localizations.dart';

// =====================================================================
// UI tests for AGENTS.md §7.A — contextual AI action:
//   * a reply is shown read-only in a bottom sheet
//   * an AiException surfaces as a friendly localized snackbar
//   * while the request is pending the action shows the thinking label
// =====================================================================

Future<void> pumpAction(
  WidgetTester tester, {
  required Future<String> Function(WidgetRef ref) ask,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: const Locale('fa'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(),
            body: Align(
              alignment: Alignment.topLeft,
              child: AiAssistAction(ask: ask),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the AI reply in a bottom sheet', (tester) async {
    await pumpAction(tester, ask: (_) async => 'توصیه آزمایشی');
    await tester.tap(find.text('کمک AI'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('توصیه آزمایشی'), findsOneWidget);
    expect(find.text('بستن'), findsOneWidget);
  });

  testWidgets('AiException shows a friendly snackbar', (tester) async {
    await pumpAction(
      tester,
      ask: (_) async => throw const AiException('no_key'),
    );
    await tester.tap(find.text('کمک AI'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('کلید API تنظیم نشده است.'), findsOneWidget);
  });

  testWidgets('shows the thinking label while pending', (tester) async {
    final completer = Completer<String>();
    await pumpAction(tester, ask: (_) => completer.future);

    await tester.tap(find.text('کمک AI'));
    await tester.pump();
    expect(find.text('در حال فکر کردن…'), findsOneWidget);

    completer.complete('تمام شد');
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('تمام شد'), findsOneWidget);
  });
}
