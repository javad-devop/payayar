import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/app_buttons.dart';
import 'ai_provider.dart';

/// Section-scoped AI action (AGENTS.md §7.A): the caller builds the
/// minimum relevant context, so unrelated data never leaves the device.
/// Throws [AiException] — with message 'no_key' when the key is missing.
Future<String> askSectionAi(
  WidgetRef ref, {
  required String prompt,
  String? summary,
}) async {
  final apiKey = await ref.read(aiSettingsProvider.notifier).readKey();
  if (apiKey == null || apiKey.isEmpty) {
    throw const AiException('no_key');
  }
  final provider = ref.read(activeAiProvider);
  if (provider == null) {
    throw const AiException('no_key');
  }
  final response = await provider.send(
    AiRequest(
      prompt: prompt,
      context: AiContext(
        includePlanSummary: summary != null,
        summary: summary,
      ),
    ),
    apiKey: apiKey,
  );
  return response.text;
}

/// Maps raw [AiException] codes to localized, friendly messages.
String friendlyAiError(AppLocalizations l10n, String code) => switch (code) {
      'no_key' => l10n.ai_errorNoKey,
      'invalid_key' => l10n.settings_ai_keyMissing,
      'network' || 'timeout' => l10n.ai_errorNetwork,
      'bad_url' => l10n.ai_errorBadUrl,
      _ => l10n.ai_error,
    };

/// Contextual AI action for a page header (AGENTS.md §7.A). The reply is
/// shown read-only: AI output is untrusted proposal data and never
/// mutates local state on its own (AGENTS.md §9).
class AiAssistAction extends ConsumerStatefulWidget {
  const AiAssistAction({super.key, required this.ask});

  final Future<String> Function(WidgetRef ref) ask;

  @override
  ConsumerState<AiAssistAction> createState() => _AiAssistActionState();
}

class _AiAssistActionState extends ConsumerState<AiAssistAction> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final reply = await widget.ask(ref);
      if (!mounted) return;
      await _showReply(reply);
    } on AiException catch (e) {
      _snack(friendlyAiError(l10n, e.message));
    } catch (_) {
      _snack(l10n.ai_errorNetwork);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showReply(String reply) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_outlined, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.ai_suggestion,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetContext).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: SelectableText(reply),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: SecondaryButton(
                  label: l10n.common_close,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AIButton(
      label: _busy ? l10n.ai_thinking : l10n.ai_assist,
      compact: true,
      onPressed: _busy ? null : _run,
    );
  }
}
