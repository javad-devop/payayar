import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
class AiException implements Exception {
  const AiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Local AI configuration persisted on-device. The API key lives in
/// flutter_secure_storage — never in plain text, never in source code.
class AiSettings {
  const AiSettings({
    this.providerId,
    this.model = 'gemini-2.0-flash',
    this.hasKey = false,
    this.includePlanSummary = false,
  });

  final String? providerId;
  final String model;
  final bool hasKey;
  final bool includePlanSummary;

  bool get isConfigured => providerId != null && hasKey;

  AiSettings copyWith({
    String? providerId,
    String? model,
    bool? hasKey,
    bool? includePlanSummary,
  }) {
    return AiSettings(
      providerId: providerId ?? this.providerId,
      model: model ?? this.model,
      hasKey: hasKey ?? this.hasKey,
      includePlanSummary: includePlanSummary ?? this.includePlanSummary,
    );
  }
}

class AiSettingsNotifier extends Notifier<AiSettings> {
  static const _kProvider = 'ai.provider';
  static const _kModel = 'ai.model';
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
    state = state.copyWith(model: model);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kModel, model);
  }

  Future<void> setPlanSummaryConsent(bool consent) async {
    state = state.copyWith(includePlanSummary: consent);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kConsent, consent);
  }
}

final aiSettingsProvider =
    NotifierProvider<AiSettingsNotifier, AiSettings>(AiSettingsNotifier.new);

/// Registry of available providers. Add a new implementation here and
/// the whole app can switch to it.
final aiProvidersProvider = Provider<List<AIProvider>>((ref) => const []);

/// Resolved active provider (null when not configured).
final activeAiProvider = Provider<AIProvider?>((ref) {
  final settings = ref.watch(aiSettingsProvider);
  if (!settings.isConfigured) return null;
  final providers = ref.watch(aiProvidersProvider);
  return providers
      .where((p) => p.id == settings.providerId)
      .firstOrNull;
});
