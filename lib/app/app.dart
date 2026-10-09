import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/background.dart';
import 'shell.dart';
import 'state/app_settings.dart';

/// Root widget: theme, locale and the atmospheric shell.
///
/// Persian (RTL) is the default presentation; English (LTR) is a
/// first-class alternative and both Dark and Light modes are driven
/// from the same token-based theme (design.md §39, §40).
class PayayarApp extends ConsumerStatefulWidget {
  const PayayarApp({super.key});

  @override
  ConsumerState<PayayarApp> createState() => _PayayarAppState();
}

class _PayayarAppState extends ConsumerState<PayayarApp> {
  @override
  void initState() {
    super.initState();
    // Restore persisted preferences (theme, language, user name).
    Future.microtask(() => ref.read(appSettingsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      title: 'Payayaar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightFor(settings.colorTheme),
      darkTheme: AppTheme.darkFor(settings.colorTheme),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AtmosphericBackground(
        child: AppShell(),
      ),
    );
  }
}
