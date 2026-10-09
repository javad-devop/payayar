import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/app/app.dart';
import 'package:payayar/app/state/app_settings.dart';
import 'package:payayar/app/state/navigation.dart';
import 'package:payayar/core/database/app_database.dart';
import 'package:payayar/core/data/providers.dart';
import 'package:drift/native.dart';
import 'package:payayar/core/theme/app_theme.dart';
import 'package:payayar/core/theme/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// Pumps the app against an in-memory database so widget tests never
  /// touch platform channels (path_provider) or leave pending timers.
  Future<AppLocalizationsTester> pumpApp(
    WidgetTester tester, [
    ProviderContainer? externalContainer,
  ]) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = externalContainer ??
        ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PayayarApp(),
      ),
    );
    // Let preferences load and Drift streams emit their first snapshot.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 100));
    return AppLocalizationsTester();
  }

  /// Detaches the widget tree and closes the container so all Drift
  /// stream subscriptions are cancelled before the next test starts —
  /// otherwise their pending timers block the test zone.
  Future<void> tearDownApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
  }

  group('app smoke test', () {
    testWidgets('boots into the Home section with Persian copy', (tester) async {
      tester.view.physicalSize = const Size(1440, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);

      expect(find.text('پایا‌یار'), findsWidgets);
      expect(find.text('برنامهٔ امروز'), findsWidgets);
      // With a tall viewport the whole Home list is built.
      expect(find.text('دسترسی سریع'), findsOneWidget);

      await tearDownApp(tester);
    });

    testWidgets('no layout overflow on a desktop viewport', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);

      expect(tester.takeException(), isNull);
      // Desktop shows the sidebar with the eight product areas; the AI
      // advisor card on Home shares the label.
      expect(find.text('برنامه‌ریزی'), findsOneWidget);
      expect(find.text('مشاور AI'), findsWidgets);

      await tearDownApp(tester);
    });

    testWidgets('no layout overflow on a phone viewport', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);

      expect(tester.takeException(), isNull);
      // Mobile shows the bottom bar plus the "More" entry.
      expect(find.text('بیشتر'), findsOneWidget);

      await tearDownApp(tester);
    });
  });

  group('navigation', () {
    testWidgets('tapping a sidebar section switches pages', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PayayarApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('برنامه‌ریزی'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(container.read(sectionProvider), AppSection.planning);
      // The planning page header is now visible with its tabs.
      expect(find.text('برنامه‌ریزی'), findsWidgets);
      expect(find.text('هفتگی'), findsOneWidget);

      await tearDownApp(tester);
    });
  });

  group('localization and direction', () {
    testWidgets('switching to English flips layout to LTR', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PayayarApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        Directionality.of(tester.element(find.byType(Scaffold))),
        TextDirection.rtl,
      );

      await container.read(appSettingsProvider.notifier).setLocale(const Locale('en'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Settings'), findsWidgets);
      expect(
        Directionality.of(tester.element(find.byType(Scaffold))),
        TextDirection.ltr,
      );

      await tearDownApp(tester);
    });

    testWidgets('every section exposes an intentional empty state', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PayayarApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));

      const expectations = {
        AppSection.planning: 'هنوز برنامه‌ای ساخته نشده',
        AppSection.study: 'مبحثی اضافه نشده',
        AppSection.exams: 'آزمونی ثبت نشده',
        AppSection.aiAdvisor: 'مشاور AI آماده است',
      };

      for (final entry in expectations.entries) {
        container.read(sectionProvider.notifier).goTo(entry.key);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text(entry.value), findsWidgets, reason: '${entry.key}');
      }

      await tearDownApp(tester);
    });
  });

  group('theme tokens', () {
    test('dark theme uses the approved reference palette', () {
      final scheme = AppTheme.dark.colorScheme;

      expect(scheme.primary, AppColors.primary);
      expect(scheme.surface, AppPalette.dark.surface);
      expect(scheme.brightness, Brightness.dark);
      expect(AppTheme.dark.textTheme.bodyMedium!.fontFamily, appFontFamily);
    });

    test('light theme adapts the same hierarchy with a light palette', () {
      final scheme = AppTheme.light.colorScheme;

      expect(scheme.primary, AppColors.primary, reason: 'semantic colors stay shared');
      expect(scheme.surface, AppPalette.light.surface);
      expect(scheme.brightness, Brightness.light);
      expect(AppTheme.light.scaffoldBackgroundColor, AppPalette.light.background);
    });

    test('both themes use the app font with the documented weights', () {
      for (final theme in [AppTheme.dark, AppTheme.light]) {
        final body = theme.textTheme.bodyMedium!;
        final title = theme.textTheme.headlineSmall!;

        expect(body.fontFamily, appFontFamily);
        expect(body.fontWeight, AppFontWeight.regular);
        expect(title.fontWeight, AppFontWeight.bold);
      }
    });
  });
}

/// Placeholder returned by the pump helper to keep call sites simple.
class AppLocalizationsTester {
  const AppLocalizationsTester();
}

