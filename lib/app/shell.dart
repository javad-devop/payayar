import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/theme/tokens.dart';
import '../features/ai_advisor/ai_advisor_page.dart';
import '../features/exams/exams_page.dart';
import '../features/home/home_page.dart';
import '../features/lifestyle/lifestyle_page.dart';
import '../features/notifications/bell_button.dart';
import '../features/planning/planning_page.dart';
import '../features/reports/reports_page.dart';
import '../features/settings/settings_page.dart';
import '../features/study/focus_timer_hud.dart';
import '../features/study/study_page.dart';
import 'breakpoints.dart';
import 'state/app_settings.dart';
import 'state/navigation.dart';

/// Application shell (design.md §4): full-width top header, desktop
/// sidebar, mobile bottom navigation with a "More" area. Navigation
/// stays stable across screens and the active section is always clear.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    PlanningPage(),
    StudyPage(),
    ExamsPage(),
    ReportsPage(),
    LifestylePage(),
    AiAdvisorPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(sectionProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = Breakpoints.isDesktop(width);
    final palette = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const _AppHeader(),
            Container(height: 1, color: palette.outlineVariant),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isDesktop) const _Sidebar(),
                  if (isDesktop) Container(width: 1, color: palette.outlineVariant),
                  Expanded(
                    child: IndexedStack(
                      index: section.index,
                      children: _pages,
                    ),
                  ),
                ],
              ),
            ),
            // Compact focus timer on every screen (AGENTS.md §44.4);
            // hidden (zero-height) while no session is active.
            const FocusTimerHud(),
            if (!isDesktop) const _MobileNav(),
          ],
        ),
      ),
    );
  }
}

class _AppHeader extends ConsumerWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 68,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Breakpoints.isMobile(MediaQuery.sizeOf(context).width)
              ? AppSpacing.lg
              : AppSpacing.xxl,
        ),
        child: Row(
          children: [
            const _BrandMark(),
            const SizedBox(width: AppSpacing.md),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.appTitle, style: text.titleLarge),
                Text(
                  l10n.brandLatin,
                  style: text.labelSmall!.copyWith(letterSpacing: 2),
                ),
              ],
            ),
            const Spacer(),
            const BellButton(),
            IconButton(
              tooltip: isDark ? l10n.settings_theme_light : l10n.settings_theme_dark,
              onPressed: () => ref.read(appSettingsProvider.notifier).setThemeMode(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  ),
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ),
            IconButton(
              tooltip: l10n.nav_settings,
              onPressed: () =>
                  ref.read(sectionProvider.notifier).goTo(AppSection.settings),
              icon: Icon(
                Icons.settings_outlined,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.42)),
      ),
      child: Text(
        'پ',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: scheme.primary,
              fontWeight: AppFontWeight.bold,
            ),
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 248,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final section in const [
              AppSection.home,
              AppSection.planning,
              AppSection.study,
              AppSection.exams,
              AppSection.reports,
              AppSection.lifestyle,
            ])
              _SidebarItem(section: section),
            const Spacer(),
            Container(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.lg),
            _SidebarItem(section: AppSection.aiAdvisor),
            _SidebarItem(section: AppSection.settings),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends ConsumerWidget {
  const _SidebarItem({required this.section});

  final AppSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sectionProvider);
    final isActive = current == section;
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(sectionProvider.notifier).goTo(section),
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: isActive ? scheme.primary.withValues(alpha: 0.14) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Row(
              children: [
                Icon(
                  section.icon,
                  size: 20,
                  color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    section.label(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: isActive ? scheme.primary : scheme.onSurface,
                          fontWeight: isActive ? AppFontWeight.semiBold : AppFontWeight.medium,
                        ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileNav extends ConsumerWidget {
  const _MobileNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sectionProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final moreActive = AppSection.secondary.contains(current);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? scheme.surface.withValues(alpha: 0.94) : scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          for (final section in AppSection.bottomBar)
            Expanded(
              child: _MobileNavItem(
                section: section,
                isActive: current == section,
                onTap: () => ref.read(sectionProvider.notifier).goTo(section),
              ),
            ),
          Expanded(
            child: _MobileNavItem(
              icon: Icons.grid_view_outlined,
              label: AppLocalizations.of(context).nav_more,
              isActive: moreActive,
              onTap: () => _openMoreSheet(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMoreSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.panel),
          ),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final section in AppSection.secondary)
              ListTile(
                leading: Icon(section.icon, size: 20, color: scheme.onSurfaceVariant),
                title: Text(
                  section.label(l10n),
                  style: Theme.of(sheetContext).textTheme.labelLarge,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ref.read(sectionProvider.notifier).goTo(section);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  const _MobileNavItem({
    this.label,
    required this.isActive,
    required this.onTap,
    this.section,
    this.icon,
  });

  final AppSection? section;
  final IconData? icon;
  final String? label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final resolvedIcon = icon ?? section!.icon;
    final resolvedLabel = label ?? section!.label(l10n);
    final color = isActive ? scheme.primary : scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(resolvedIcon, size: 20, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              resolvedLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: color,
                    fontWeight: isActive ? AppFontWeight.semiBold : AppFontWeight.medium,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
