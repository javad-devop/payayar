import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';

/// The eight conceptually distinct product areas (AGENTS.md §17).
/// The order here drives navigation, the shell and the IndexedStack.
enum AppSection {
  home,
  planning,
  study,
  exams,
  reports,
  lifestyle,
  aiAdvisor,
  settings;

  IconData get icon => switch (this) {
        AppSection.home => Icons.home_outlined,
        AppSection.planning => Icons.calendar_month_outlined,
        AppSection.study => Icons.menu_book_outlined,
        AppSection.exams => Icons.assignment_outlined,
        AppSection.reports => Icons.insights_outlined,
        AppSection.lifestyle => Icons.favorite_outline,
        AppSection.aiAdvisor => Icons.auto_awesome_outlined,
        AppSection.settings => Icons.settings_outlined,
      };

  String label(AppLocalizations l10n) => switch (this) {
        AppSection.home => l10n.nav_home,
        AppSection.planning => l10n.nav_planning,
        AppSection.study => l10n.nav_study,
        AppSection.exams => l10n.nav_exams,
        AppSection.reports => l10n.nav_reports,
        AppSection.lifestyle => l10n.nav_lifestyle,
        AppSection.aiAdvisor => l10n.nav_aiAdvisor,
        AppSection.settings => l10n.nav_settings,
      };

  /// Sections rendered directly on the mobile bottom bar; the rest
  /// live behind "More" (design.md §4.2).
  static const List<AppSection> bottomBar = [
    AppSection.home,
    AppSection.planning,
    AppSection.study,
    AppSection.exams,
  ];

  static const List<AppSection> secondary = [
    AppSection.reports,
    AppSection.lifestyle,
    AppSection.aiAdvisor,
    AppSection.settings,
  ];
}

class SectionNotifier extends Notifier<AppSection> {
  @override
  AppSection build() => AppSection.home;

  void goTo(AppSection section) => state = section;
}

/// The currently selected product section.
final sectionProvider =
    NotifierProvider<SectionNotifier, AppSection>(SectionNotifier.new);
