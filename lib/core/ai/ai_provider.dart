import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gemini_provider.dart';
import 'openai_compatible_provider.dart';

/// Minimum context sent with a request (AGENTS.md §24). The summary is
/// built explicitly by the caller; never the full database.
class AiContext {
  const AiContext({this.summary, this.includePlanSummary = false});

  final String? summary;
  final bool includePlanSummary;
}

class AiRequest {
  const AiRequest({
    required this.prompt,
    this.history = const [],
    this.context,
  });

  final String prompt;
  final List<(String, String)> history; // (role, content)
  final AiContext? context;
}

class AiResponse {
  const AiResponse({required this.text});

  final String text;
}

/// Provider abstraction so Gemini / others can be swapped freely
/// (AGENTS.md §4: one provider for now, architecture stays open).
abstract class AIProvider {
  String get id;
  String get displayName;

  Future<AiResponse> send(AiRequest request, {required String apiKey});
}

/// Errors surfaced to the UI as friendly states, never raw stack traces.
/// `detail` is optional technical context (HTTP status, resolved URL) so
/// the settings screen can show *what* actually failed instead of one
/// vague message for every cause.
class AiException implements Exception {
  const AiException(this.message, {this.detail});
  final String message;
  final String? detail;

  @override
  String toString() => detail == null ? message : '$message ($detail)';
}

/// Local AI configuration persisted on-device. The API key lives in
/// flutter_secure_storage — never in plain text, never in source code.
class AiSettings {
  const AiSettings({
    this.providerId,
    this.model = 'gemini-2.0-flash',
    this.baseUrl = defaultBaseUrl,
    this.hasKey = false,
    this.includePlanSummary = false,
  });

  /// OpenAI-compatible default; any service speaking the
  /// `/chat/completions` dialect can replace it (PLAN.md phase 2).
  static const String defaultBaseUrl = 'https://api.openai.com/v1';

  final String? providerId;
  final String model;
  final String baseUrl;
  final bool hasKey;
  final bool includePlanSummary;

  bool get isConfigured => providerId != null && hasKey;

  AiSettings copyWith({
    String? providerId,
    String? model,
    String? baseUrl,
    bool? hasKey,
    bool? includePlanSummary,
  }) {
    return AiSettings(
      providerId: providerId ?? this.providerId,
      model: model ?? this.model,
      baseUrl: baseUrl ?? this.baseUrl,
      hasKey: hasKey ?? this.hasKey,
      includePlanSummary: includePlanSummary ?? this.includePlanSummary,
    );
  }
}

class AiSettingsNotifier extends Notifier<AiSettings> {
  static const _kProvider = 'ai.provider';
  static const _kModel = 'ai.model';
  static const _kBaseUrl = 'ai.base_url';
  static const _kConsent = 'ai.planSummaryConsent';
  static const _kKey = 'ai.api_key';

  final _secure = const FlutterSecureStorage();

  @override
  AiSettings build() => const AiSettings();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final hasKey = await _secure.containsKey(key: _kKey);
    state = AiSettings(
      providerId: prefs.getString(_kProvider),
      model: prefs.getString(_kModel) ?? 'gemini-2.0-flash',
      baseUrl: prefs.getString(_kBaseUrl) ?? AiSettings.defaultBaseUrl,
      hasKey: hasKey,
      includePlanSummary: prefs.getBool(_kConsent) ?? false,
    );
  }

  Future<String?> readKey() => _secure.read(key: _kKey);

  Future<void> saveKey(String key) async {
    await _secure.write(key: _kKey, value: key.trim());
    state = state.copyWith(hasKey: true);
  }

  Future<void> setProvider(String? id) async {
    state = state.copyWith(providerId: id);
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_kProvider);
    } else {
      await prefs.setString(_kProvider, id);
    }
  }

  Future<void> setModel(String model) async {
    final trimmed = model.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(model: trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kModel, trimmed);
  }

  Future<void> setBaseUrl(String url) async {
    final trimmed = url.trim();
    final safe = trimmed.isEmpty ? AiSettings.defaultBaseUrl : trimmed;
    state = state.copyWith(baseUrl: safe);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBaseUrl, safe);
  }

  Future<void> setPlanSummaryConsent(bool consent) async {
    state = state.copyWith(includePlanSummary: consent);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kConsent, consent);
  }
}

final aiSettingsProvider =
    NotifierProvider<AiSettingsNotifier, AiSettings>(AiSettingsNotifier.new);

/// Registry of available providers. Every provider receives the
/// user's current model/base-url from settings, so the whole app can
/// switch without touching call sites (PLAN.md phase 2).
final aiProvidersProvider = Provider<List<AIProvider>>((ref) {
  final settings = ref.watch(aiSettingsProvider);
  return [
    GeminiProvider(model: settings.model),
    OpenAiCompatibleProvider(baseUrl: settings.baseUrl, model: settings.model),
  ];
});

/// Resolved active provider (null when not configured).
final activeAiProvider = Provider<AIProvider?>((ref) {
  final settings = ref.watch(aiSettingsProvider);
  if (!settings.isConfigured) return null;
  final providers = ref.watch(aiProvidersProvider);
  return providers
      .where((p) => p.id == settings.providerId)
      .firstOrNull;
});
