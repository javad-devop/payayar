
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payayar/core/ai/ai_provider.dart';
import 'package:payayar/core/ai/openai_compatible_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() => server.close(force: true));

  void okJson(HttpRequest request, String text) {
    request.response.statusCode = 200;
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({
        'choices': [
          {
            'message': {'role': 'assistant', 'content': text}
          }
        ],
      }),
    );
    request.response.close();
  }

  test('sends a correct chat/completions request and parses the reply',
      () async {
    HttpRequest? seen;
    String? rawBody;
    server.listen((request) async {
      seen = request;
      rawBody = await utf8.decoder.bind(request).join();
      okJson(request, 'pong');
    });

    final provider = OpenAiCompatibleProvider(
      baseUrl: 'http://127.0.0.1:${server.port}/v1/',
      model: 'test-model',
    );
    final response = await provider.send(
      const AiRequest(prompt: 'ping', history: [('user', 'hi')]),
      apiKey: apiKey: 'k'),
    );

    expect(response.text, 'pong');
    expect(seen, isNotNull);
    expect(seen!.requestedUri.path, '/v1/chat/completions');
    expect(seen!.headers.value(HttpHeaders.authorizationHeader),
        'Bearer ' + 'k');

    final body = jsonDecode(rawBody!) as Map<String, dynamic>;
    expect(body['model'], 'test-model');
    expect(body['messages'], [
      {'role': 'user', 'content': 'hi'},
      {'role': 'user', 'content': 'ping'},
    ]);
  });

  test('maps 401 to invalid_key', () async {
    server.listen((request) async {
      await request.drain<void>();
      request.response.statusCode = 401;
      await request.response.close();
    });

    final provider =
        OpenAiCompatibleProvider(baseUrl: 'http://127.0.0.1:${server.port}');

    await expectLater(
      provider.send(const AiRequest(prompt: 'x'), apiKey: apiKey: 'k')),
      throwsA(isA<AiException>()
          .having((e) => e.message, 'message', 'invalid_key')),
    );
  });

  test('normalizes pasted base URLs (double /v1, pasted /chat/completions)',
      () async {
    String? seenPath;
    server.listen((request) async {
      seenPath = request.requestedUri.path;
      await request.drain<void>();
      okJson(request, 'ok');
    });

    // A pasted full endpoint URL with a duplicated version prefix must
    // still land on exactly one /v1/chat/completions.
    final provider = OpenAiCompatibleProvider(
      baseUrl: 'http://127.0.0.1:${server.port}/v1/v1/chat/completions/',
      model: 'test-model',
    );
    final response =
        await provider.send(const AiRequest(prompt: 'x'), apiKey: apiKey: 'k'));

    expect(response.text, 'ok');
    expect(seenPath, '/v1/chat/completions');
  });

  test('normalizeOpenAiBase covers the common paste mistakes', () {
    expect(normalizeOpenAiBase('  https://x.dev/v1/  '), 'https://x.dev/v1');
    expect(normalizeOpenAiBase('https://x.dev/v1/chat/completions'),
        'https://x.dev/v1');
    expect(normalizeOpenAiBase('https://x.dev/v1/v1'), 'https://x.dev/v1');
    expect(normalizeOpenAiBase(''), AiSettings.defaultBaseUrl);
  });

  test('retries with max_tokens when the model answers empty', () async {
    var hits = 0;
    server.listen((request) async {
      await request.drain<void>();
      hits++;
      // First call: reasoning model returned nothing usable.
      okJson(request, hits == 1 ? '' : 'recovered');
    });

    final provider = OpenAiCompatibleProvider(
      baseUrl: 'http://127.0.0.1:${server.port}/v1',
      model: 'test-model',
    );
    final response =
        await provider.send(const AiRequest(prompt: 'x'), apiKey: apiKey: 'k'));

    expect(response.text, 'recovered');
    expect(hits, 2);
  });

  test('maps 500 to server_error carrying an HTTP detail', () async {
    server.listen((request) async {
      await request.drain<void>();
      request.response.statusCode = 500;
      request.response.write('upstream exploded');
      await request.response.close();
    });

    final provider =
        OpenAiCompatibleProvider(baseUrl: 'http://127.0.0.1:${server.port}');
    await expectLater(
      provider.send(const AiRequest(prompt: 'x'), apiKey: apiKey: 'k')),
      throwsA(isA<AiException>()
          .having((e) => e.message, 'message', 'server_error')
          .having((e) => e.detail, 'detail', contains('HTTP 500'))),
    );
  });

  test('rejects a base URL without a scheme before any network call',
      () async {
    const provider = OpenAiCompatibleProvider(baseUrl: 'not a url');

    await expectLater(
      provider.send(const AiRequest(prompt: 'x'), apiKey: apiKey: 'k')),
      throwsA(isA<AiException>()
          .having((e) => e.message, 'message', 'bad_url')),
    );
  });

  group('settings wiring', () {
    test('base url and model persist and reach the provider registry',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(aiSettingsProvider.notifier)
          .setBaseUrl('https://openrouter.ai/api/v1');
      await container.read(aiSettingsProvider.notifier).setModel('llama-3.3-70b');

      final settings = container.read(aiSettingsProvider);
      expect(settings.baseUrl, 'https://openrouter.ai/api/v1');
      expect(settings.model, 'llama-3.3-70b');

      final openAi = container
          .read(aiProvidersProvider)
          .whereType<OpenAiCompatibleProvider>()
          .single;
      expect(openAi.baseUrl, 'https://openrouter.ai/api/v1');
      expect(openAi.model, 'llama-3.3-70b');
    });

    test('blank base url falls back to the OpenAI default', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(aiSettingsProvider.notifier).setBaseUrl('   ');

      expect(container.read(aiSettingsProvider).baseUrl,
          AiSettings.defaultBaseUrl);
    });

    test('registry always exposes both providers', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ids =
          container.read(aiProvidersProvider).map((p) => p.id).toSet();
      expect(ids, containsAll(<String>{'gemini', 'openai'}));
    });
  });
}
