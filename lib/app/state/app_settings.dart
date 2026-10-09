import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/tokens.dart';

/// Locally persisted user preferences (local-first: no account, no sync).
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.locale = const Locale('fa'),
    this.userName = '',
    this.focusMinutes = 25,
    this.colorTheme = AccentTheme.defaultId,
  });

  /// Dark is the approved reference direction (design.md §40).
  final ThemeMode themeMode;
  final Locale locale;
  final String userName;

  /// Default focus-session length in minutes (AGENTS.md §44.1).
  /// Kept in settings so the user's last choice survives a restart.
  final int focusMinutes;

  /// Selected accent theme id (one of `AccentTheme.all`).
  final String colorTheme;

  bool get isPersian => locale.languageCode == 'fa';

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    String? userName,
    int? focusMinutes,
    String? colorTheme,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      userName: userName ?? this.userName,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      colorTheme: colorTheme ?? this.colorTheme,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _kTheme = 'settings.theme_mode';
  static const _kLocale = 'settings.locale';
  static const _kUserName = 'settings.user_name';
  static const _kFocusMinutes = 'settings.focus_minutes';
  static const _kColorTheme = 'settings.color_theme';

  @override
  AppSettings build() => const AppSettings();

  /// Restores persisted preferences. Called once when the app starts.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeName = prefs.getString(_kTheme);
    final languageCode = prefs.getString(_kLocale);
    final userName = prefs.getString(_kUserName);
    final focusMinutes = prefs.getInt(_kFocusMinutes);

    state = AppSettings(
      themeMode: switch (themeName) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.dark,
      },
      locale: Locale(languageCode ?? 'fa'),
      userName: userName ?? '',
      focusMinutes: _validFocusMinutes(focusMinutes),
      colorTheme: AccentTheme.byId(prefs.getString(_kColorTheme)).id,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, mode.name);
  }

  Future<void> setColorTheme(String id) async {
    state = state.copyWith(colorTheme: AccentTheme.byId(id).id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kColorTheme, id);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, locale.languageCode);
  }

  Future<void> setUserName(String name) async {
    state = state.copyWith(userName: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, name);
  }

  /// Persisted durations can be stale or hand-edited, so clamp them to a
  /// sane range instead of trusting the stored value (AGENTS.md §25).
  static int _validFocusMinutes(int? value) {
    if (value == null) return 25;
    if (value < 5) return 5;
    if (value > 180) return 180;
    return value;
  }

  Future<void> setFocusMinutes(int minutes) async {
    final safe = _validFocusMinutes(minutes);
    state = state.copyWith(focusMinutes: safe);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFocusMinutes, safe);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
