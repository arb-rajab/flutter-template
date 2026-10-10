import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown for any non-2xx response. Carries the machine-readable `error`
/// code and human-readable `message` from the response body (when present),
/// so screens can react to specific failures instead of a generic message.
class ApiException implements Exception {
  ApiException(this.statusCode, this.errorCode, [this.message]);

  final int statusCode;
  final String? errorCode;
  final String? message;

  @override
  String toString() => 'ApiException($statusCode, $errorCode, $message)';
}

/// Thin JSON client over `package:http`. Add one method per endpoint in a
/// subclass or alongside these helpers; keep decoding and error mapping here.
///
/// Expects error bodies shaped like `{"error": "CODE", "message": "..."}`.
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  /// Set after sign-in to send `Authorization: Bearer <token>` on every request.
  String? bearerToken;

  Uri uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl/$path').replace(queryParameters: query);

  Map<String, String> _headers({bool json = false}) => {
    'Accept': 'application/json',
    if (json) 'Content-Type': 'application/json',
    // ignore: use_null_aware_elements
    if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
  };

  Map<String, dynamic> _decodeOrThrow(http.Response response) {
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      response.statusCode,
      body['error'] as String?,
      body['message'] as String?,
    );
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _http.get(uri(path, query), headers: _headers());
    return _decodeOrThrow(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _http.post(
      uri(path),
      headers: _headers(json: true),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decodeOrThrow(response);
  }
}
