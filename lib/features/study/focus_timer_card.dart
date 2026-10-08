import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/app_settings.dart';
import '../../core/data/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/progress_ring.dart';
import 'focus_timer.dart';

/// AGENTS.md §44 — the focus/Pomodoro surface.
///
/// Lives on the Study page and drives [focusTimerProvider], which is
/// app-scoped: leaving this page never resets a running session (§44.4).
class FocusTimerCard extends ConsumerWidget {
  const FocusTimerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final timer = ref.watch(focusTimerProvider);

    // A finished focus session becomes a local notification (§43.1).
    ref.listen<FocusTimerState>(focusTimerProvider, (previous, next) {
      if (previous?.phase != FocusPhase.finished &&
          next.phase == FocusPhase.finished) {
        ref.read(notificationRepositoryProvider).addNotification(
              title: l10n.notif_focusDone(next.plannedMinutes),
            );
      }
    });

    switch (timer.phase) {
      case FocusPhase.idle:
        return _IdleCard(l10n: l10n);
      case FocusPhase.finished:
        return _FinishedCard(l10n: l10n, state: timer);
      case FocusPhase.running:
      case FocusPhase.paused:
        return _RunningCard(l10n: l10n, state: timer);
    }
  }
}

String _clock(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------
// Idle — offer to start
// ---------------------------------------------------------------------

class _IdleCard extends ConsumerWidget {
  const _IdleCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];
    final scheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.icon),
            ),
            child: Icon(Icons.timer_outlined, color: scheme.primary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.focus_title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: AppFontWeight.semiBold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subjects.isEmpty ? l10n.focus_needSubject : l10n.focus_desc,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          PrimaryButton(
            label: l10n.focus_start,
            icon: Icons.play_arrow_rounded,
            onPressed: subjects.isEmpty
                ? null
                : () => _FocusSetupDialog.show(context, subjects),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Running / paused
// ---------------------------------------------------------------------

class _RunningCard extends ConsumerWidget {
  const _RunningCard({required this.l10n, required this.state});

  final AppLocalizations l10n;
  final FocusTimerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final paused = state.phase == FocusPhase.paused;

    final subjects = ref.watch(subjectsProvider).value ?? const <Subject>[];
    final topics = ref.watch(allTopicsProvider).value ?? const <Topic>[];
    final subjectName = subjects
        .where((s) => s.id == state.subjectId)
        .firstOrNull
        ?.name;
    final topicName =
        topics.where((t) => t.id == state.topicId).firstOrNull?.name;

    final caption = [?subjectName, ?topicName].join(' · ');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                paused ? Icons.pause_circle_outline : Icons.timer,
                size: 20,
                color: paused ? AppColors.warning : scheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                paused ? l10n.focus_paused : l10n.focus_running,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: AppFontWeight.semiBold),
              ),
              const Spacer(),
              if (caption.isNotEmpty)
                Text(
                  caption,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: ProgressRing(
              value: state.progress,
              size: 160,
              strokeWidth: 12,
              color: paused ? AppColors.warning : scheme.primary,
              center: Text(
                _clock(state.remaining),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: AppFontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: paused ? AppColors.warning : scheme.primary,
                    ),
              ),
              label: '${l10n.focus_remaining} · ${state.plannedMinutes} ${l10n.focus_minutes}',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: paused ? l10n.focus_resume : l10n.focus_pause,
                  variant: AppButtonVariant.secondary,
                  icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  onPressed: paused
                      ? ref.read(focusTimerProvider.notifier).resume
                      : ref.read(focusTimerProvider.notifier).pause,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: l10n.focus_end,
                  variant: AppButtonVariant.danger,
                  icon: Icons.stop_rounded,
                  onPressed: () => _confirmEnd(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Ending early is the user's call: save the elapsed time or discard it
  /// (AGENTS.md §44.3 — never record a partial session automatically).
  Future<void> _confirmEnd(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final notifier = ref.read(focusTimerProvider.notifier);

    // Reaching the planned time on its own would already have finished the
    // session, so anything handled here is partial by definition (§44.3).
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.panel),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          title: Text(l.focus_endTitle,
              style: Theme.of(dialogContext).textTheme.titleLarge),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(
              l.focus_endDesc,
              style: Theme.of(dialogContext)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          actions: [
            AppButton(
              label: l.common_cancel,
              variant: AppButtonVariant.secondary,
              compact: true,
              onPressed: () => Navigator.of(dialogContext).pop('cancel'),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: l.focus_endDiscard,
              variant: AppButtonVariant.danger,
              compact: true,
              onPressed: () => Navigator.of(dialogContext).pop('discard'),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: l.focus_endRecord,
              compact: true,
              onPressed: () => Navigator.of(dialogContext).pop('record'),
            ),
          ],
        );
      },
    );

    if (choice == null || choice == 'cancel') return;

    final id = await notifier.endEarly(record: choice == 'record');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          id == null ? l.focus_discarded : l.focus_partialSaved,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Finished
// ---------------------------------------------------------------------

class _FinishedCard extends ConsumerWidget {
  const _FinishedCard({required this.l10n, required this.state});

  final AppLocalizations l10n;
  final FocusTimerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.icon),
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.success),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.focus_title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: AppFontWeight.semiBold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  state.completed
                      ? l10n.focus_completed
                      : '${_clock(Duration(seconds: state.elapsedSeconds))} · ${l10n.focus_partialSaved}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          PrimaryButton(
            label: l10n.focus_newSession,
            icon: Icons.refresh_rounded,
            onPressed: () {
              final notifier = ref.read(focusTimerProvider.notifier);
              notifier.reset();
              final subjects =
                  ref.read(subjectsProvider).value ?? const <Subject>[];
              if (subjects.isNotEmpty) {
                _FocusSetupDialog.show(context, subjects);
              }
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Setup dialog
// ---------------------------------------------------------------------

class _FocusSetupDialog extends ConsumerStatefulWidget {
  const _FocusSetupDialog({required this.subjects});

  final List<Subject> subjects;

  static Future<void> show(BuildContext context, List<Subject> subjects) =>
      showDialog(
        context: context,
        builder: (_) => _FocusSetupDialog(subjects: subjects),
      );

  @override
  ConsumerState<_FocusSetupDialog> createState() => _FocusSetupDialogState();
}

class _FocusSetupDialogState extends ConsumerState<_FocusSetupDialog> {
  int? _subjectId;
  int? _topicId;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    final first = widget.subjects.isNotEmpty ? widget.subjects.first.id : null;
    _subjectId = first;
    _minutes = ref.read(appSettingsProvider).focusMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final topics = (ref.watch(allTopicsProvider).value ?? const <Topic>[])
        .where((t) => t.subjectId == _subjectId)
        .toList();

    final canStart = _subjectId != null;

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.panel),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      title: Text(l10n.focus_setup_title,
          style: Theme.of(context).textTheme.titleLarge),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _subjectId,
              decoration: InputDecoration(labelText: l10n.focus_subject),
              items: [
                for (final s in widget.subjects)
                  DropdownMenuItem(value: s.id, child: Text(s.name)),
              ],
              onChanged: (value) => setState(() {
                _subjectId = value;
                _topicId = null; // topics belong to a subject
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<int?>(
              initialValue: _topicId,
              decoration: InputDecoration(labelText: l10n.focus_topic),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text('—')),
                for (final t in topics)
                  DropdownMenuItem<int?>(value: t.id, child: Text(t.name)),
              ],
              onChanged: topics.isEmpty ? null : (value) => setState(() => _topicId = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.focus_duration,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final m in FocusTimerNotifier.allowedMinutes)
                  ChoiceChip(
                    label: Text('$m ${l10n.focus_minutes}'),
                    selected: _minutes == m,
                    onSelected: (_) => setState(() => _minutes = m),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          label: l10n.common_cancel,
          variant: AppButtonVariant.secondary,
          compact: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppButton(
          label: l10n.focus_start,
          icon: Icons.play_arrow_rounded,
          compact: true,
          onPressed: canStart
              ? () {
                  ref.read(appSettingsProvider.notifier).setFocusMinutes(_minutes);
                  ref.read(focusTimerProvider.notifier).start(
                        subjectId: _subjectId!,
                        topicId: _topicId,
                        minutes: _minutes,
                      );
                  Navigator.of(context).pop();
                }
              : null,
        ),
      ],
    );
  }
}
