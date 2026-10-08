import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/page_header.dart';

/// design.md §12.1 — Quick Note.
///
/// Low-friction capture: auto-saves to **local** persistence only
/// (no backend, per AGENTS.md §1), `Ctrl+S` saves on desktop, and clearing
/// a non-empty note always asks first (design.md §42 — never destroy user
/// data silently).
class QuickNoteNotifier extends Notifier<String> {
  static const storageKey = 'home.quick_note';

  /// How long typing must settle before the automatic save runs.
  static const autoSaveDelay = Duration(milliseconds: 600);

  bool _loaded = false;

  @override
  String build() {
    _loaded = false;
    return '';
  }

  /// Idempotent; called from the card so no app-startup wiring is needed.
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(storageKey) ?? '';
  }

  /// In-memory edit. Persistence happens through [save] (debounced or
  /// explicit), so a keystroke never blocks on I/O.
  void edit(String value) => state = value;

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, state);
  }

  Future<void> clear() async {
    state = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}

final quickNoteProvider =
    NotifierProvider<QuickNoteNotifier, String>(QuickNoteNotifier.new);

class QuickNoteCard extends ConsumerStatefulWidget {
  const QuickNoteCard({super.key});

  @override
  ConsumerState<QuickNoteCard> createState() => _QuickNoteCardState();
}

class _QuickNoteCardState extends ConsumerState<QuickNoteCard> {
  late final TextEditingController _controller;
  Timer? _autoSave;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // Load the stored note; the provider is written by this card only, so a
    // provider→field listener is unnecessary (and `ref.listen` is illegal
    // outside `build` anyway).
    unawaited(_loadIntoField());
  }

  Future<void> _loadIntoField() async {
    await ref.read(quickNoteProvider.notifier).load();
    if (!mounted) return;
    final stored = ref.read(quickNoteProvider);
    if (_controller.text.isEmpty && stored.isNotEmpty) {
      _controller.text = stored;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _autoSave?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // setState matters: `hasText` drives the Save/Clear enablement, and a
    // keystroke without a rebuild leaves both buttons disabled forever.
    setState(() {});
    ref.read(quickNoteProvider.notifier).edit(value);
    _autoSave?.cancel();
    _autoSave = Timer(QuickNoteNotifier.autoSaveDelay, () {
      unawaited(ref.read(quickNoteProvider.notifier).save());
    });
  }

  Future<void> _saveNow() async {
    _autoSave?.cancel();
    await ref.read(quickNoteProvider.notifier).save();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.home_quickNote_saved)),
    );
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.home_quickNote_clearTitle,
      message: l10n.home_quickNote_clearDesc,
      confirmLabel: l10n.home_quickNote_clear,
      cancelLabel: l10n.common_cancel,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    _autoSave?.cancel();
    _controller.clear();
    await ref.read(quickNoteProvider.notifier).clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).home_quickNote_cleared)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hasText = _controller.text.trim().isNotEmpty;

    // design.md §12.1: Ctrl+S saves the current note on desktop.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _saveNow,
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {}, // keeps focus handling inside the card
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: l10n.home_quickNote_title),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 100),
                child: TextField(
                  controller: _controller,
                  onChanged: _onChanged,
                  minLines: 4,
                  maxLines: 10,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: l10n.home_quickNote_hint,
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      borderSide: BorderSide(color: scheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      borderSide: BorderSide(color: scheme.outlineVariant),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Wrap instead of Row so narrow viewports (phones, and the
              // 800px test surface) never overflow horizontally (design.md §36).
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  PrimaryButton(
                    label: l10n.home_quickNote_save,
                    icon: Icons.save_outlined,
                    // Saving an empty note is meaningless; keep it reachable
                    // only when there is something to persist.
                    onPressed: hasText ? _saveNow : null,
                  ),
                  AppButton(
                    label: l10n.home_quickNote_clear,
                    variant: AppButtonVariant.danger,
                    icon: Icons.delete_outline_rounded,
                    onPressed: hasText ? _clear : null,
                  ),
                  Text(
                    'Ctrl+S',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
