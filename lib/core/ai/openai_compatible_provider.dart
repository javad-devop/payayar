import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'ai_provider.dart';

/// OpenAI-compatible provider — talks to any service that speaks the
/// `POST {base}/chat/completions` dialect (OpenAI, OpenRouter, Groq,
/// LM Studio, ...). Base URL and model come from user settings; the
/// key is sent as a Bearer token and never leaves secure storage
/// (AGENTS.md §23, PLAN.md phase 2).
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
      final base = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
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
    final body = jsonEncode({'model': model, 'messages': messages});

    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final response = await client.postUrl(uri).then((req) {
        req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
        req.headers.contentLength = utf8.encode(body).length;
        req.write(body);
        return req.close();
      }).timeout(const Duration(seconds: 60));

      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        final first = choices?.firstOrNull as Map<String, dynamic>?;
        final message = first?['message'] as Map<String, dynamic>?;
        final text = message?['content'] as String?;
        if (text == null || text.trim().isEmpty) {
          throw const AiException('empty_response');
        }
        return AiResponse(text: text);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AiException('invalid_key');
      } else if (response.statusCode == 404) {
        // Wrong base URL or unknown model — both are address problems.
        throw const AiException('bad_url');
      } else if (response.statusCode == 429) {
        throw const AiException('rate_limit');
      } else {
        throw const AiException('server_error');
      }
    } on SocketException {
      throw const AiException('network');
    } on TimeoutException {
      throw const AiException('timeout');
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
