import 'dart:convert';

import 'package:degloor_one/core/app_environment.dart';
import 'package:http/http.dart' as http;

class JavaApiException implements Exception {
  JavaApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Shared HTTP client for the Spring Boot API.
///
/// Screens stay on showcase/Supabase until [JavaApiConfig.enabled] is true
/// (`--dart-define=JAVA_API_BASE_URL=http://localhost:8080`).
class JavaApiClient {
  JavaApiClient._();

  static final instance = JavaApiClient._();

  String? accessToken;
  String? refreshToken;

  static bool get enabled => AppEnvironment.usesJavaBackend;

  Uri uri(String path, [Map<String, String>? query]) {
    final base = AppEnvironment.javaApiBaseUrl.replaceAll(RegExp(r'/$'), '');
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (accessToken != null && accessToken!.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      };

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _send(() => http.get(uri(path, query), headers: _headers));
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) {
    return _send(() => http.post(
          uri(path),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        ));
  }

  Future<dynamic> put(String path, [Map<String, dynamic>? body]) {
    return _send(() => http.put(
          uri(path),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        ));
  }

  Future<dynamic> delete(String path, [Map<String, dynamic>? body]) {
    return _send(() => http.delete(
          uri(path),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        ));
  }

  Future<dynamic> _send(Future<http.Response> Function() send) async {
    final response = await send();
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw JavaApiException('INVALID_RESPONSE', 'Unexpected server response');
    }
    if (response.statusCode >= 200 && response.statusCode < 300 && decoded['success'] == true) {
      return decoded['data'];
    }
    throw JavaApiException(
      '${decoded['code'] ?? 'HTTP_${response.statusCode}'}',
      '${decoded['message'] ?? 'Request failed'}',
    );
  }
}

class JavaApiConfig {
  static bool get enabled => JavaApiClient.enabled;
}
