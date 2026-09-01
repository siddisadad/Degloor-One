import 'package:shared_preferences/shared_preferences.dart';

class JavaSessionTokens {
  const JavaSessionTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

/// Persists Java JWTs across app restarts.
class JavaSessionStore {
  JavaSessionStore._();

  static const _accessKey = 'java_auth_access_token';
  static const _refreshKey = 'java_auth_refresh_token';

  static Future<JavaSessionTokens?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(_accessKey);
    final refresh = prefs.getString(_refreshKey);
    if (access == null ||
        access.isEmpty ||
        refresh == null ||
        refresh.isEmpty) {
      return null;
    }
    return JavaSessionTokens(accessToken: access, refreshToken: refresh);
  }

  static Future<void> save({
    required String? accessToken,
    required String? refreshToken,
  }) async {
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      await clear();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, accessToken);
    await prefs.setString(_refreshKey, refreshToken);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }
}
