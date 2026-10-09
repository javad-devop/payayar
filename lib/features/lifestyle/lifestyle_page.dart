import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/states.dart';

/// Lifestyle (AGENTS.md §12): lightweight daily logging — sleep,
/// exercise, mood, energy, screen time and a short reflection.
/// Not a medical app; observations are descriptive only.
class LifestylePage extends ConsumerStatefulWidget {
  const LifestylePage({super.key});

  @override
  ConsumerState<LifestylePage> createState() => _LifestylePageState();
}

class _LifestylePageState extends ConsumerState<LifestylePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(lifestyleEntriesProvider).value;

    if (entries == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.huge,
      ),
      children: [
        PageHeader(title: l10n.lifestyle_title),
        _TodayEditor(),
        const SizedBox(height: AppSpacing.xl),
        _HistorySection(entries: entries),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Today's editor
// ---------------------------------------------------------------------

class _TodayEditor extends ConsumerStatefulWidget {
  const _TodayEditor();

  @override
  ConsumerState<_TodayEditor> createState() => _TodayEditorState();
}

class _TodayEditorState extends ConsumerState<_TodayEditor> {
  TimeOfDay? _bed;
  TimeOfDay? _wake;
  final _exercise = TextEditingController();
  final _screen = TextEditingController();
  final _notes = TextEditingController();
  int _mood = 3;
  int _energy = 3;
  bool _loaded = false;

  @override
  void dispose() {
    _exercise.dispose();
    _screen.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (_loaded) return;
    _loaded = true;
    final repo = ref.read(lifestyleRepositoryProvider);
    final existing = await repo.getEntry(DateTime.now());
    if (existing == null || !mounted) return;
    setState(() {
      if (existing.wakeMinutes != null) {
        _wake = TimeOfDay(
          hour: existing.wakeMinutes! ~/ 60,
          minute: existing.wakeMinutes! % 60,
        );
      }
      // Bed time stored as sleep duration + wake → keep simple: store
      // duration; show as hours.
      if (existing.exerciseMinutes != null) {
        _exercise.text = '${existing.exerciseMinutes}';
      }
      if (existing.screenTimeMinutes != null) {
        _screen.text = '${existing.screenTimeMinutes}';
      }
      if (existing.mood != null) _mood = existing.mood!;
      if (existing.energy != null) _energy = existing.energy!;
      if (existing.notes != null) _notes.text = existing.notes!;
    });
  }

  Future<void> _save() async {
    final repo = ref.read(lifestyleRepositoryProvider);
    final bedMinutes = _bed == null ? null : _bed!.hour * 60 + _bed!.minute;
    final wakeMinutes = _wake == null ? null : _wake!.hour * 60 + _wake!.minute;

    // Sleep minutes derive from bed→wake when both exist.
    int? sleepMinutes;
    if (bedMinutes != null && wakeMinutes != null) {
      sleepMinutes = wakeMinutes - bedMinutes;
      if (sleepMinutes < 0) sleepMinutes += 24 * 60;
    }

    await repo.upsertEntry(LifestyleEntriesCompanion.insert(
      date: DateTime.now(),
      sleepMinutes: Value(sleepMinutes),
      wakeMinutes: Value(wakeMinutes),
      exerciseMinutes: Value(int.tryParse(_exercise.text.trim())),
      mood: Value(_mood),
      energy: Value(_energy),
      screenTimeMinutes: Value(int.tryParse(_screen.text.trim())),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
    ));

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lifestyle_saved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadExisting();
    final l10n = AppLocalizations.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lifestyle_today,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: AppFontWeight.semiBold,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _bed ?? const TimeOfDay(hour: 23, minute: 0),
                    );
                    if (picked != null) setState(() => _bed = picked);
                  },
                  child: Text(
                    '${l10n.lifestyle_bedTime}: ${_bed?.format(context) ?? '—'}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _wake ?? const TimeOfDay(hour: 7, minute: 0),
                    );
                    if (picked != null) setState(() => _wake = picked);
                  },
                  child: Text(
                    '${l10n.lifestyle_wakeTime}: ${_wake?.format(context) ?? '—'}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _exercise,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: l10n.lifestyle_exercise),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _screen,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: l10n.lifestyle_screenTime),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _LevelPicker(
            label: l10n.lifestyle_mood,
            value: _mood,
            onChanged: (v) => setState(() => _mood = v),
            labels: [
              l10n.lifestyle_level_1,
              l10n.lifestyle_level_2,
              l10n.lifestyle_level_3,
              l10n.lifestyle_level_4,
              l10n.lifestyle_level_5,
            ],
          ),
          _LevelPicker(
            label: l10n.lifestyle_energy,
            value: _energy,
            onChanged: (v) => setState(() => _energy = v),
            labels: [
              l10n.lifestyle_level_1,
              l10n.lifestyle_level_2,
              l10n.lifestyle_level_3,
              l10n.lifestyle_level_4,
              l10n.lifestyle_level_5,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.lifestyle_notes),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: l10n.lifestyle_save,
            onPressed: _save,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.labels,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (var i = 1; i <= 5; i++)
                  ChoiceChip(
                    label: Text(
                      labels[i - 1],
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    selected: value == i,
                    selectedColor: scheme.primary.withValues(alpha: 0.24),
                    showCheckmark: false,
                    onSelected: (_) => onChanged(i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// History + simple descriptive observations
// ---------------------------------------------------------------------

class _HistorySection extends ConsumerWidget {
  const _HistorySection({required this.entries});

  final List<LifestyleEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lifestyle_history,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: AppFontWeight.semiBold,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Observation(entries: entries),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            EmptyState(
              compact: true,
              icon: Icons.favorite_outline,
              title: l10n.empty_lifestyle_title,
              description: l10n.empty_lifestyle_desc,
            )
          else
            for (final e in entries.take(14))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    SizedBox(
                      width: 76,
                      child: Text(
                        '${e.date.year}/${e.date.month}/${e.date.day}',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    if (e.sleepMinutes != null) ...[
                      Icon(Icons.bedtime_outlined,
                          size: 14, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${(e.sleepMinutes! / 60).toStringAsFixed(1)}${l10n.planning_hoursUnit}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                    ],
                    if (e.exerciseMinutes != null) ...[
                      const Icon(Icons.directions_run_outlined,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        '${e.exerciseMinutes}′',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                    ],
                    if (e.energy != null)
                      Icon(
                        Icons.bolt_outlined,
                        size: 14,
                        color: e.energy! >= 4
                            ? AppColors.success
                            : e.energy! >= 3
                                ? AppColors.warning
                                : AppColors.error,
                      ),
                    const Spacer(),
                    if (e.notes != null && e.notes!.isNotEmpty)
                      Expanded(
                        child: Text(
                          e.notes!,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: scheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// Descriptive-only observations, shown after 7 logged days.
/// No medical claims — just plain comparisons of the user's own data.
class _Observation extends ConsumerWidget {
  const _Observation({required this.entries});

  final List<LifestyleEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (entries.length < 7) {
      return Text(
        l10n.lifestyle_observation_needMore,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      );
    }

    final sleepHigh = entries.where((e) => (e.sleepMinutes ?? 0) >= 7 * 60);
    final sleepLow = entries.where((e) => (e.sleepMinutes ?? 99 * 60) < 6 * 60);

    double avgEnergy(Iterable<LifestyleEntry> list) {
      final values = list
          .map((e) => e.energy)
          .whereType<int>()
          .toList();
      if (values.isEmpty) return -1;
      return values.reduce((a, b) => a + b) / values.length;
    }

    final eHigh = avgEnergy(sleepHigh);
    final eLow = avgEnergy(sleepLow);

    if (eHigh < 0 || eLow < 0 || sleepHigh.length < 3 || sleepLow.length < 3) {
      return const SizedBox.shrink();
    }

    final diff = (eHigh - eLow).round();
    if (diff <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border:
            Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline,
              size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              l10n.lifestyle_observation_energy(diff),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
