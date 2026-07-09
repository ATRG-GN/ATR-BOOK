import 'dart:convert';

import 'package:atr_book/network/backend_proxy_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('BackendProxyClient', () {
    test('normalizes trailing slash and posts prompt with bearer token', () async {
      late Uri requestedUri;
      late Map<String, String> requestedHeaders;
      late Map<String, dynamic> requestedBody;

      final client = BackendProxyClient(
        baseUrl: 'https://backend.example.com/',
        httpClient: MockClient((request) async {
          requestedUri = request.url;
          requestedHeaders = request.headers;
          requestedBody = jsonDecode(request.body) as Map<String, dynamic>;

          return http.Response(
            jsonEncode(<String, dynamic>{'text': 'ok'}),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }),
      );

      final result = await client.requestAiCompletion(
        jwt: 'jwt-token',
        prompt: 'hello',
      );

      expect(
        requestedUri,
        Uri.parse('https://backend.example.com/v1/proxy/ai/completions'),
      );
      expect(requestedHeaders['Authorization'], 'Bearer jwt-token');
      expect(requestedHeaders['Content-Type'], 'application/json');
      expect(requestedBody, <String, dynamic>{'prompt': 'hello'});
      expect(result, <String, dynamic>{'text': 'ok'});
    });

    test('throws FormatException when proxy returns non-object JSON', () async {
      final client = BackendProxyClient(
        baseUrl: 'https://backend.example.com',
        httpClient: MockClient((request) async {
          return http.Response(jsonEncode(<String>['not', 'an', 'object']), 200);
        }),
      );

      expect(
        () => client.requestAiCompletion(jwt: 'jwt-token', prompt: 'hello'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
