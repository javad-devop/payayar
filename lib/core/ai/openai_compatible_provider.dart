import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'ai_provider.dart';

/// OpenAI-compatible provider — talks to any service that speaks the
/// `POST {base}/chat/completions` dialect (OpenAI, OpenRouter, Groq,
/// LM Studio, ...). Base URL and model come from user settings; the
/// key is sent as a Bearer token and never leaves secure storage
/// (AGENTS.md §23, PLAN.md phase 2).
/// Normalizes a user-typed base URL: trims, drops a pasted
/// `/chat/completions` suffix, collapses accidental `/v1/v1` and strips
/// trailing slashes. These are the paste mistakes that otherwise show up
/// as a mysterious 404 in the connection test.
String normalizeOpenAiBase(String url) {
  var u = url.trim().replaceAll(RegExp(r'/+$'), '');
  u = u.replaceFirst(RegExp(r'/chat/completions$'), '');
  while (u.endsWith('/v1/v1')) {
    u = u.substring(0, u.length - 3);
  }
  return u.isEmpty ? AiSettings.defaultBaseUrl : u;
}

class OpenAiCompatibleProvider implements AIProvider {
  const OpenAiCompatibleProvider({
    this.baseUrl = AiSettings.defaultBaseUrl,
    this.model = 'gpt-4o-mini',
  });

  final String baseUrl;
  final String model;

  @override
  String get id => 'openai';

  @override
  String get displayName => 'OpenAI (compatible)';

  @override
  Future<AiResponse> send(AiRequest request, {required String apiKey}) async {
    final Uri uri;
    try {
      final base = normalizeOpenAiBase(baseUrl);
      uri = Uri.parse('$base/chat/completions');
      if (!uri.hasScheme || uri.host.isEmpty) {
        throw const FormatException('base url needs scheme and host');
      }
    } on FormatException {
      throw const AiException('bad_url');
    }

    final messages = <Map<String, String>>[
      for (final (role, text) in request.history)
        {'role': role == 'assistant' ? 'assistant' : 'user', 'content': text},
      {'role': 'user', 'content': _buildPrompt(request)},
    ];

    // Reasoning models sometimes spend their whole token budget thinking
    // and return an empty answer. First attempt matches the common
    // OpenAI dialect exactly; if the answer comes back empty we retry
    // once with an explicit token budget so the model *must* answer.
    var text = await _post(uri, apiKey,
        body: jsonEncode({'model': model, 'messages': messages}));
    if (text == null) {
      text = await _post(
        uri,
        apiKey,
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'max_tokens': 4096,
        }),
      );
    }
    if (text == null) {
      throw AiException('empty_response', detail: uri.toString());
    }
    return AiResponse(text: text);
  }

  /// Posts one chat/completions request and returns the assistant text,
  /// or null when the server answered 200 with an empty message.
  Future<String?> _post(Uri uri, String apiKey, {required String body}) async {
    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final response = await client.postUrl(uri).then((req) {
        req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
        req.headers.contentLength = utf8.encode(body).length;
        req.write(body);
        return req.close();
        // Slow reasoning models are normal; give them room before
        // declaring a timeout.
      }).timeout(const Duration(seconds: 120));

      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        final first = choices?.firstOrNull as Map<String, dynamic>?;
        final message = first?['message'] as Map<String, dynamic>?;
        final text = message?['content'] as String?;
        if (text == null || text.trim().isEmpty) return null;
        return text;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw AiException('invalid_key', detail: 'HTTP ${response.statusCode}');
      } else if (response.statusCode == 404) {
        // Wrong base URL or unknown model — both are address problems.
        throw AiException('bad_url', detail: uri.toString());
      } else if (response.statusCode == 429) {
        throw const AiException('rate_limit');
      } else {
        throw AiException(
          'server_error',
          detail:
              'HTTP ${response.statusCode}: ${responseBody.substring(0, responseBody.length.clamp(0, 160))}',
        );
      }
    } on SocketException {
      throw AiException('network', detail: uri.host);
    } on TimeoutException {
      throw AiException('timeout', detail: uri.host);
    } finally {
      client.close();
    }
  }

  String _buildPrompt(AiRequest request) {
    final buffer = StringBuffer();
    final context = request.context;
    if (context != null && context.includePlanSummary && context.summary != null) {
      buffer
        ..writeln('--- context (user-approved summary) ---')
        ..writeln(context.summary)
        ..writeln('--- end context ---');
    }
    buffer.write(request.prompt);
    return buffer.toString();
  }
}
