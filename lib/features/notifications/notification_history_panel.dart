import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/data/repositories.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';

/// Opens the local-notification history sheet (HANDOFF §43.1).
Future<void> showNotificationHistorySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const NotificationHistoryPanel(),
  );
}

/// History panel: every notification, newest first. Opening it marks
/// pending rows as read (badge clears) while task actions stay
/// available on read rows.
class NotificationHistoryPanel extends ConsumerStatefulWidget {
  const NotificationHistoryPanel({super.key});

  @override
  ConsumerState<NotificationHistoryPanel> createState() =>
      _NotificationHistoryPanelState();
}

class _NotificationHistoryPanelState
    extends ConsumerState<NotificationHistoryPanel> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(notificationRepositoryProvider).markAllRead(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(notificationHistoryProvider);

    return SafeArea(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: history.when(
          data: (items) => items.isEmpty
              ? _EmptyState(l10n: l10n)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(
                    height: AppSpacing.md,
                  ),
                  itemBuilder: (context, i) => _NotificationTile(
                    notification: items[i],
                    l10n: l10n,
                  ),
                ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _EmptyState(l10n: l10n),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification, required this.l10n});

  final Notification notification;
  final AppLocalizations l10n;

  String _statusLabel() => switch (notification.status) {
        AppNotificationStatus.read => l10n.notif_status_read,
        AppNotificationStatus.actioned => l10n.notif_status_actioned,
        AppNotificationStatus.dismissed => l10n.notif_status_dismissed,
        _ => '',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isSettled = notification.status == AppNotificationStatus.actioned ||
        notification.status == AppNotificationStatus.dismissed;
    final canAct = !isSettled && notification.taskId != null;
    final canDismiss = !isSettled;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSettled
                ? notification.status == AppNotificationStatus.actioned
                    ? Icons.check_circle_outline
                    : Icons.notifications_off_outlined
                : Icons.notifications_active_outlined,
            size: 20,
            color: isSettled ? scheme.outline : scheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: text.bodyLarge),
                if (notification.body != null &&
                    notification.body!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notification.body!,
                    style: text.bodySmall!.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (isSettled) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _statusLabel(),
                    style: text.labelSmall!.copyWith(color: scheme.outline),
                  ),
                ],
              ],
            ),
          ),
          if (canAct)
            TextButton(
              onPressed: () => ref
                  .read(notificationRepositoryProvider)
                  .actionTask(notification.id),
              child: Text(l10n.notif_doTask),
            ),
          if (canDismiss)
            IconButton(
              tooltip: l10n.notif_dismiss,
              visualDensity: VisualDensity.compact,
              onPressed: () => ref
                  .read(notificationRepositoryProvider)
                  .dismiss(notification.id),
              icon: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 40, color: scheme.outline),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.notif_emptyTitle, style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.notif_emptyDesc,
            textAlign: TextAlign.center,
            style: text.bodySmall!.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
