import 'package:degloor_one/auth/base_auth_user_provider.dart';
import 'package:degloor_one/auth/java_auth/java_session_store.dart';
import 'package:degloor_one/auth/java_auth_user.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/auth_api.dart';

/// Restores a persisted Java session on cold start.
Future<BaseAuthUser> restoreJavaAuthSession() async {
  if (!JavaApiConfig.enabled) {
    return currentUser ?? JavaAuthUser.signedOut();
  }

  final stored = await JavaSessionStore.load();
  if (stored == null) {
    final signedOut = JavaAuthUser.signedOut();
    updateAuthUser(signedOut);
    updateJwtToken(null);
    return signedOut;
  }

  final client = JavaApiClient.instance;
  client.accessToken = stored.accessToken;
  client.refreshToken = stored.refreshToken;

  try {
    return await _emitUser(JavaAuthUser.fromJson(await AuthApi.me()));
  } on JavaApiException {
    try {
      await AuthApi.refresh();
      return await _emitUser(JavaAuthUser.fromJson(await AuthApi.me()));
    } catch (_) {
      await _clearSession();
      return JavaAuthUser.signedOut();
    }
  } catch (_) {
    await _clearSession();
    return JavaAuthUser.signedOut();
  }
}

Future<BaseAuthUser> _emitUser(JavaAuthUser user) async {
  updateAuthUser(user);
  updateJwtToken(JavaApiClient.instance.accessToken);
  return user;
}

Future<void> _clearSession() async {
  JavaApiClient.instance.accessToken = null;
  JavaApiClient.instance.refreshToken = null;
  await JavaSessionStore.clear();
  final signedOut = JavaAuthUser.signedOut();
  updateAuthUser(signedOut);
  updateJwtToken(null);
}
