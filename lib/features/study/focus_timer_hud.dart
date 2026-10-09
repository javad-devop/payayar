import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/navigation.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import 'focus_timer.dart';

/// Compact focus-timer display (AGENTS.md §44.4): the session state is
/// app-scoped, and this strip keeps it visible on every screen — not just
/// the study page. Tapping the strip jumps to the study section; the
/// trailing button pauses/resumes without leaving the current screen.
class FocusTimerHud extends ConsumerWidget {
  const FocusTimerHud({super.key});

  /// `mm:ss` in western digits so tests and parsing stay stable (AGENTS §40).
  static String formatRemaining(int totalSeconds) {
    final seconds = totalSeconds.clamp(0, 99 * 60 + 59);
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(focusTimerProvider);
    if (!state.isActive) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final paused = state.phase == FocusPhase.paused;

    return Material(
      color: scheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () =>
            ref.read(sectionProvider.notifier).goTo(AppSection.study),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                paused ? Icons.pause_circle_outline : Icons.timer_outlined,
                size: 20,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      paused ? l10n.focus_paused : l10n.focus_running,
                      style: text.labelSmall!
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                    Text(
                      formatRemaining(state.remainingSeconds),
                      style: text.titleMedium!.copyWith(
                        color: scheme.onSurface,
                        fontFeatures: const [],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: paused ? l10n.focus_resume : l10n.focus_pause,
                visualDensity: VisualDensity.compact,
                iconSize: 22,
                onPressed: () {
                  final notifier = ref.read(focusTimerProvider.notifier);
                  if (paused) {
                    notifier.resume();
                  } else {
                    notifier.pause();
                  }
                },
                icon: Icon(
                  paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
