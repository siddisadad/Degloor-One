import 'package:degloor_one/auth/java_auth/java_session_lifecycle.dart';
import 'package:degloor_one/auth/java_auth/java_session_store.dart';
import 'package:degloor_one/core/api/api_client.dart';

class AuthApi {
  AuthApi._();

  static final _http = JavaApiClient.instance;

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
  }) {
    return _store(_http.post('/api/v1/auth/register', {
      'email': email,
      'password': password,
      if (fullName != null) 'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    }));
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _store(_http.post('/api/v1/auth/login', {
      'email': email,
      'password': password,
    }));
  }

  static Future<Map<String, dynamic>> refresh() async {
    final token = _http.refreshToken;
    if (token == null || token.isEmpty) {
      throw JavaApiException('INVALID_REFRESH', 'Please sign in again');
    }
    return _store(_http.post('/api/v1/auth/refresh', {'refreshToken': token}));
  }

  static Future<void> logout() async {
    try {
      await _http.post('/api/v1/auth/logout');
    } catch (_) {
      // Best effort. Local session is cleared regardless.
    } finally {
      await clearJavaSession();
    }
  }

  static Future<Map<String, dynamic>> me() async {
    final data = await _http.get('/api/v1/auth/me');
    return Map<String, dynamic>.from(data as Map);
  }

  static Future<Map<String, dynamic>> _store(Future<dynamic> future) async {
    final data = Map<String, dynamic>.from(await future as Map);
    _http.accessToken = data['accessToken'] as String?;
    _http.refreshToken = data['refreshToken'] as String?;
    await JavaSessionStore.save(
      accessToken: _http.accessToken,
      refreshToken: _http.refreshToken,
    );
    return data;
  }
}
