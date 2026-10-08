import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'ai_provider.dart';

/// Gemini provider — talks to the generativelanguage REST API with the
/// user's own key (AGENTS.md §23). Uses dart:io HttpClient directly so
/// no extra dependency is introduced.
class GeminiProvider implements AIProvider {
  const GeminiProvider();

  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';

  @override
  String get id => 'gemini';

  @override
  String get displayName => 'Google Gemini';

  @override
  Future<AiResponse> send(AiRequest request, {required String apiKey}) async {
    final model = _modelFor(request);
    final uri = Uri.parse('$_endpoint/$model:generateContent?key=$apiKey');

    final contents = <Map<String, dynamic>>[
      for (final (role, text) in request.history)
        {
          'role': role == 'assistant' ? 'model' : 'user',
          'parts': [{'text': text}],
        },
      {
        'role': 'user',
        'parts': [
          {'text': _buildPrompt(request)},
        ],
      },
    ];

    final body = jsonEncode({'contents': contents});

    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final response = await client
          .postUrl(uri)
          .then((req) {
        req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        req.headers.contentLength = utf8.encode(body).length;
        req.write(body);
        return req.close();
      })
          .timeout(const Duration(seconds: 60));

      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        final first = candidates?.firstOrNull as Map<String, dynamic>?;
        final content = first?['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        final text = parts?.firstOrNull?['text'] as String?;
        if (text == null || text.isEmpty) {
          throw const AiException('empty_response');
        }
        return AiResponse(text: text);
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        throw const AiException('invalid_key');
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

  String _modelFor(AiRequest request) => 'gemini-2.0-flash';

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
