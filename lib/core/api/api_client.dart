import 'dart:convert';

import 'package:degloor_one/auth/java_auth/java_session_lifecycle.dart';
import 'package:degloor_one/auth/java_auth/java_session_store.dart';
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
  bool _refreshing = false;

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
    return _send(
      () => http.post(
        uri(path),
        headers: _headers,
        body: body == null ? null : jsonEncode(body),
      ),
      path: path,
    );
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

  /// Unauthenticated Spring Boot health probe for the login screen.
  Future<void> probeHealth({
    Duration timeout = const Duration(seconds: 4),
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient
          .get(
            uri('/actuator/health'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw JavaApiException(
          'UNREACHABLE',
          'Cannot reach the Degloor One server. Please try again.',
        );
      }
      if (response.body.isEmpty) return;
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['status'] == 'UP') return;
      if (decoded is Map && decoded['status'] != null) {
        throw JavaApiException(
          'UNREACHABLE',
          'Cannot reach the Degloor One server. Please try again.',
        );
      }
    } on JavaApiException {
      rethrow;
    } catch (_) {
      throw JavaApiException(
        'UNREACHABLE',
        'Cannot reach the Degloor One server. Please try again.',
      );
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  Future<dynamic> _send(
    Future<http.Response> Function() send, {
    String? path,
    bool allowRefresh = true,
  }) async {
    final response = await send();
    final decoded = _decode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decoded['success'] == true) {
      return decoded['data'];
    }
    final code = '${decoded['code'] ?? 'HTTP_${response.statusCode}'}';
    if (allowRefresh &&
        response.statusCode == 401 &&
        path != '/api/v1/auth/refresh' &&
        await _tryRefresh()) {
      return _send(send, path: path, allowRefresh: false);
    }
    throw JavaApiException(
      code,
      '${decoded['message'] ?? 'Request failed'}',
    );
  }

  Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw JavaApiException('INVALID_RESPONSE', 'Unexpected server response');
    }
    return decoded;
  }

  Future<bool> _tryRefresh() async {
    final token = refreshToken;
    if (_refreshing || token == null || token.isEmpty) return false;
    _refreshing = true;
    try {
      final response = await http.post(
        uri('/api/v1/auth/refresh'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': token}),
      );
      final decoded = _decode(response.body);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['success'] == true &&
          decoded['data'] is Map) {
        final data = Map<String, dynamic>.from(decoded['data'] as Map);
        accessToken = data['accessToken'] as String?;
        refreshToken = data['refreshToken'] as String?;
        final ok = accessToken != null && accessToken!.isNotEmpty;
        if (ok) {
          await JavaSessionStore.save(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
        return ok;
      }
      await clearJavaSession();
      return false;
    } catch (_) {
      // Network / parse failures are transient: keep persisted JWTs for the
      // next cold start, but drop the zombie logged-in UI so callers stop
      // retrying with a dead access token.
      await markJavaSessionUnavailable();
      return false;
    } finally {
      _refreshing = false;
    }
  }
}

class JavaApiConfig {
  static bool get enabled => JavaApiClient.enabled;
}
