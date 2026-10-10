import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:starter_app/api/api_client.dart';

void main() {
  group('ApiClient', () {
    test('getJson decodes a 2xx JSON object and builds the URL', () async {
      final mock = MockClient((request) async {
        expect(request.url.toString(), 'https://api.test/items?page=2');
        expect(request.headers['Accept'], 'application/json');
        return http.Response(jsonEncode({'ok': true}), 200);
      });
      final client = ApiClient(baseUrl: 'https://api.test', httpClient: mock);

      final body = await client.getJson('items', query: {'page': '2'});

      expect(body, {'ok': true});
    });

    test('postJson sends a JSON body and the bearer token', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer tok');
        expect(jsonDecode(request.body), {'a': 1});
        return http.Response('{}', 201);
      });
      final client = ApiClient(baseUrl: 'https://api.test', httpClient: mock)
        ..bearerToken = 'tok';

      await client.postJson('items', body: {'a': 1});
    });

    test('omits Authorization when no token is set', () async {
      final mock = MockClient((request) async {
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response('{}', 200);
      });
      final client = ApiClient(baseUrl: 'https://api.test', httpClient: mock);

      await client.getJson('items');
    });

    test('maps an error body to a typed ApiException', () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'CONFLICT', 'message': 'already exists'}),
          409,
        );
      });
      final client = ApiClient(baseUrl: 'https://api.test', httpClient: mock);

      await expectLater(
        client.getJson('items'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having((e) => e.errorCode, 'errorCode', 'CONFLICT')
              .having((e) => e.message, 'message', 'already exists'),
        ),
      );
    });

    test('tolerates an empty error body', () async {
      final mock = MockClient((request) async => http.Response('', 500));
      final client = ApiClient(baseUrl: 'https://api.test', httpClient: mock);

      await expectLater(
        client.getJson('items'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.errorCode, 'errorCode', isNull),
        ),
      );
    });
  });
}
