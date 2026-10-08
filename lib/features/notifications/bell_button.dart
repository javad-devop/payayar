import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/l10n/generated/app_localizations.dart';
import 'notification_history_panel.dart';

/// Top-bar bell with a badge counting pending local notifications
/// (HANDOFF §43.1). Opens the history panel.
class BellButton extends ConsumerWidget {
  const BellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final active =
        ref.watch(activeNotificationsProvider).valueOrNull ?? const [];
    final count = active.length;

    return IconButton(
      tooltip: l10n.notif_title,
      onPressed: () => showNotificationHistorySheet(context),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 9 ? '9+' : '$count'),
        child: Icon(
          Icons.notifications_outlined,
          size: 20,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
