import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'page_header.dart';
import 'states.dart';

/// Shared scaffold for sections whose screens are introduced in later
/// phases: a proper page header plus an intentional empty state that
/// tells the user what the section will do (design.md §20, §41).
class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({
    super.key,
    required this.title,
    required this.emptyTitle,
    required this.emptyDescription,
    this.icon = Icons.inbox_outlined,
    this.actions = const [],
    this.footer,
  });

  final String title;
  final String emptyTitle;
  final String emptyDescription;
  final IconData icon;
  final List<Widget> actions;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.huge,
      ),
      children: [
        PageHeader(title: title, actions: actions),
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: EmptyState(
            title: emptyTitle,
            description: emptyDescription,
            icon: icon,
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.xxl),
          footer!,
        ],
      ],
    );
  }
}
