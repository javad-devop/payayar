import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/app/state/app_settings.dart';
import 'package:payayar/core/theme/app_theme.dart';
import 'package:payayar/core/theme/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('accent themes (six selectable color themes)', () {
    test('six unique ids, blue stays the out-of-the-box default', () {
      expect(AccentTheme.all, hasLength(6));
      expect(AccentTheme.all.map((a) => a.id).toSet(), hasLength(6));
      expect(AccentTheme.defaultId, 'blue');
      expect(AccentTheme.byId(AccentTheme.defaultId).seed, AppColors.primary);
    });

    test('unknown or stale ids fall back to the default theme', () {
      expect(AccentTheme.byId('does-not-exist').id, AccentTheme.defaultId);
      expect(AccentTheme.byId(null).id, AccentTheme.defaultId);
    });

    test('every theme yields a distinct primary in both modes', () {
      final darkPrimaries = AccentTheme.all
          .map((a) => AppTheme.darkFor(a.id).colorScheme.primary)
          .toSet();
      final lightPrimaries = AccentTheme.all
          .map((a) => AppTheme.lightFor(a.id).colorScheme.primary)
          .toSet();
      expect(darkPrimaries, hasLength(6));
      expect(lightPrimaries, hasLength(6));
    });

    test('default getters keep the original blue palette (regression)', () {
      expect(AppTheme.dark.colorScheme.primary, AppColors.primary);
      expect(AppTheme.light.colorScheme.primary, AppColors.primary);
      expect(AppTheme.darkFor('blue').colorScheme.primary, AppColors.primary);
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppTheme.light.brightness, Brightness.light);
    });
  });

  group('AppSettings.colorTheme', () {
    test('restores the persisted accent id', () async {
      SharedPreferences.setMockInitialValues({'settings.color_theme': 'green'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(appSettingsProvider.notifier).load();

      expect(container.read(appSettingsProvider).colorTheme, 'green');
    });

    test('stale persisted ids normalize to the default', () async {
      SharedPreferences.setMockInitialValues(
          {'settings.color_theme': 'stale-id'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(appSettingsProvider.notifier).load();

      expect(container.read(appSettingsProvider).colorTheme,
          AccentTheme.defaultId);
    });

    test('setColorTheme persists the choice', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(appSettingsProvider.notifier)
          .setColorTheme('purple');

      expect(container.read(appSettingsProvider).colorTheme, 'purple');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings.color_theme'), 'purple');
    });
  });
}
