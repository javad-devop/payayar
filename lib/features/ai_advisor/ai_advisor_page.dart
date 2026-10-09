import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_provider.dart';
import '../../core/data/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/states.dart';
import '../planning/planning_dashboard.dart';

/// Standalone AI advisor (AGENTS.md §7.B). Chat stays local; nothing
/// mutates the plan without an explicit user-approved apply step
/// (AGENTS.md §8). Without a key the page shows a real setup state.
class AiAdvisorPage extends ConsumerStatefulWidget {
  const AiAdvisorPage({super.key});

  @override
  ConsumerState<AiAdvisorPage> createState() => _AiAdvisorPageState();
}

class _AiAdvisorPageState extends ConsumerState<AiAdvisorPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  int? _conversationId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(aiSettingsProvider.notifier).load());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final l10n = AppLocalizations.of(context);
    final settings = ref.read(aiSettingsProvider);
    final notifier = ref.read(aiSettingsProvider.notifier);

    // Resolved provider: Gemini or any OpenAI-compatible service
    // chosen in settings (AGENTS.md §23, PLAN.md phase 2).
    final provider = ref.read(activeAiProvider);
    final apiKey = await notifier.readKey();

    if (apiKey == null || apiKey.isEmpty || provider == null) {
      _showError(l10n.ai_errorNoKey);
      return;
    }

    // Real prior turns: the advisor must remember the whole thread
    // (PLAN.md phase 2 — AI as the core consultant, read §24).
    final prior = _conversationId == null
        ? const <AIMessage>[]
        : (ref.read(aiMessagesProvider(_conversationId!)).value ??
            const <AIMessage>[]);

    final aiRepo = ref.read(aiRepositoryProvider);
    _conversationId ??= await aiRepo.createConversation();
    await aiRepo.addMessage(
      conversationId: _conversationId!,
      role: 'user',
      content: text,
    );

    setState(() {
      _sending = true;
      _controller.clear();
    });

    try {
      final tail =
          prior.length > 12 ? prior.sublist(prior.length - 12) : prior;
      final history = <(String, String)>[
        ('assistant', l10n.ai_welcome),
        for (final m in tail)
          (m.role == 'assistant' ? 'assistant' : 'user', m.content),
      ];

      final response = await provider.send(
        AiRequest(
          prompt: text,
          history: history,
          context: AiContext(
            includePlanSummary: settings.includePlanSummary,
            summary: settings.includePlanSummary ? _buildSummary() : null,
          ),
        ),
        apiKey: apiKey,
      );

      await aiRepo.addMessage(
        conversationId: _conversationId!,
        role: 'assistant',
        content: response.text,
      );
      _maybeShowSuggestion(response.text);
    } on AiException catch (e) {
      _showError(_friendlyError(l10n, e.message));
    } catch (_) {
      _showError(l10n.ai_errorNetwork);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _askPreset(String prompt) {
    _controller.text = prompt;
    return _send();
  }

  String _buildSummary() {
    final l10n = AppLocalizations.of(context);
    final dash = ref.read(planningDashboardProvider);
    final study = ref.read(studySummaryProvider);
    final subjects = ref.read(subjectsProvider).value ?? const <Subject>[];

    final now = DateTime.now();
    final upcoming = (ref.read(examsProvider).value ?? const [])
        .where((e) => !e.date.isBefore(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final lifestyle =
        (ref.read(lifestyleEntriesProvider).value ?? const []).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final dueCards = ref.read(dueFlashcardsProvider).value?.length ?? 0;
    final nextExam = ref.read(nextExamProvider);

    return jsonEncode({
      'todayPlannedTasks': dash.todayPlannedTasks,
      'todayCompletedTasks': dash.todayCompletedTasks,
      'weekPlannedMinutes': dash.weekPlannedMinutes,
      'weekCompletedMinutes': dash.weekCompletedMinutes,
      'overdueTasks': dash.overdueTasks,
      'todayStudyMinutes': study.todayMinutes,
      'streakDays': study.streakDays,
      'subjects': subjects.map((s) => s.name).take(15).toList(),
      'nextExam': nextExam == null
          ? null
          : {
              'title': nextExam.title,
              'date': nextExam.date.toIso8601String(),
              'daysLeft': nextExam.date.difference(now).inDays,
            },
      'upcomingExams': [
        for (final e in upcoming.take(3))
          {
            'title': e.title,
            'date': e.date.toIso8601String(),
            'daysLeft': e.date.difference(now).inDays,
          },
      ],
      'recentLifestyle': [
        for (final l in lifestyle.take(5))
          {
            'date': l.date.toIso8601String().substring(0, 10),
            'sleepHours': l.sleepMinutes == null
                ? null
                : (l.sleepMinutes! / 60).round(),
            'exerciseMinutes': l.exerciseMinutes,
            'mood': l.mood,
            'energy': l.energy,
          },
      ],
      'flashcardsDue': dueCards,
      'notes': l10n.reports_title,
    });
  }

  void _maybeShowSuggestion(String response) {
    // Structured task proposals arrive as a fenced JSON block; they are
    // only offered as a suggestion card, never auto-applied (§25).
    final match = RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true)
        .firstMatch(response);
    if (match == null) return;
    try {
      final data = jsonDecode(match.group(1)!) as Map<String, dynamic>;
      final title = data['task_title'];
      if (title is! String || title.isEmpty) return;
      setState(() => _pendingSuggestion = title);
    } catch (_) {
      // Malformed proposal: silently skipped — never applied blind.
    }
  }

  String? _pendingSuggestion;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _friendlyError(AppLocalizations l10n, String code) =>
      switch (code) {
        'invalid_key' => l10n.settings_ai_keyMissing,
        'network' || 'timeout' => l10n.ai_errorNetwork,
        'bad_url' => l10n.ai_errorBadUrl,
        _ => l10n.ai_error,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(aiSettingsProvider);
    final scheme = Theme.of(context).colorScheme;

    if (!settings.isConfigured) {
      return _SetupState(onConfigure: () async {
        await ref.read(aiSettingsProvider.notifier).load();
        if (mounted) setState(() {});
      });
    }

    // Keep section data streams alive so the advisor digest (§24) is
    // fresh when the user asks about their own sections.
    ref.watch(examsProvider);
    ref.watch(lifestyleEntriesProvider);
    ref.watch(dueFlashcardsProvider);
    ref.watch(nextExamProvider);

    final messages = _conversationId == null
        ? const <AIMessage>[]
        : (ref.watch(aiMessagesProvider(_conversationId!)).value ??
            const <AIMessage>[]);

    return Column(
      children: [
        PageHeader(
          title: l10n.ai_title,
          actions: [
            SecondaryButton(
              label: l10n.ai_newChat,
              icon: Icons.add_comment_outlined,
              onPressed: () => setState(() => _conversationId = null),
            ),
          ],
        ),
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      l10n.ai_welcome,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  itemCount: messages.length + (_sending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_sending && index == messages.length) {
                      return const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      );
                    }
                    final m = messages[index];
                    final isUser = m.role == 'user';
                    return Align(
                      alignment: isUser
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        constraints: const BoxConstraints(maxWidth: 560),
                        decoration: BoxDecoration(
                          color: isUser
                              ? scheme.primary.withValues(alpha: 0.16)
                              : Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(AppRadius.card),
                            topRight: const Radius.circular(AppRadius.card),
                            bottomLeft: Radius.circular(
                              isUser ? AppRadius.card : AppSpacing.xs,
                            ),
                            bottomRight: Radius.circular(
                              isUser ? AppSpacing.xs : AppRadius.card,
                            ),
                          ),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Text(
                          m.content,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_pendingSuggestion != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: GlassCard(
              level: GlassLevel.secondary,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_outlined,
                      size: 16, color: AppColors.ai),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${l10n.ai_suggestionTask}: $_pendingSuggestion',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: l10n.ai_suggestionApply,
                    compact: true,
                    onPressed: () async {
                      final title = _pendingSuggestion!;
                      setState(() => _pendingSuggestion = null);
                      await ref.read(planningRepositoryProvider).addTask(
                            PlanTasksCompanion.insert(
                              title: title,
                              date: DateTime.now(),
                              priority: Priority.medium,
                              status: TaskStatus.notStarted,
                            ),
                          );
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: l10n.ai_suggestionDismiss,
                    variant: AppButtonVariant.secondary,
                    compact: true,
                    onPressed: () =>
                        setState(() => _pendingSuggestion = null),
                  ),
                ],
              ),
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!settings.includePlanSummary)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      l10n.ai_contextHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    _AdvisorChip(
                      icon: Icons.insights_outlined,
                      label: l10n.ai_chipAnalyze,
                      onTap: () => _askPreset(l10n.ai_chipAnalyzeQ),
                    ),
                    _AdvisorChip(
                      icon: Icons.calendar_month_outlined,
                      label: l10n.ai_chipPlan,
                      onTap: () => _askPreset(l10n.ai_chipPlanQ),
                    ),
                    _AdvisorChip(
                      icon: Icons.summarize_outlined,
                      label: l10n.ai_chipReport,
                      onTap: () => _askPreset(l10n.ai_chipReportQ),
                    ),
                    _AdvisorChip(
                      icon: Icons.school_outlined,
                      label: l10n.ai_chipExams,
                      onTap: () => _askPreset(l10n.ai_chipExamsQ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: l10n.ai_inputHint,
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AppButton(
                      label: l10n.ai_send,
                      icon: Icons.send_outlined,
                      onPressed: _sending ? null : _send,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SetupState extends StatelessWidget {
  const _SetupState({required this.onConfigure});

  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.huge,
      ),
      children: [
        PageHeader(title: l10n.ai_title),
        GlassCard(
          child: EmptyState(
            icon: Icons.auto_awesome_outlined,
            title: l10n.empty_ai_title,
            description: l10n.ai_notConfigured,
            actionLabel: l10n.ai_configure,
            onAction: () {
              // Settings section hosts the AI configuration card.
              // Navigate there; the user comes back when done.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settings_ai)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdvisorChip extends StatelessWidget {
  const _AdvisorChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: scheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
