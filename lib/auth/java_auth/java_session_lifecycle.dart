import 'package:degloor_one/auth/base_auth_user_provider.dart';
import 'package:degloor_one/auth/java_auth/java_session_store.dart';
import 'package:degloor_one/auth/java_auth_user.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';

bool isJavaAuthFailure(JavaApiException error) {
  return error.code == 'INVALID_REFRESH' ||
      error.code == 'UNAUTHORIZED' ||
      error.code == 'HTTP_401' ||
      error.code.contains('401');
}

Future<BaseAuthUser> emitJavaUser(JavaAuthUser user) {
  updateAuthUser(user);
  updateJwtToken(JavaApiClient.instance.accessToken);
  AppStateNotifier.instance.update(user);
  return Future.value(user);
}

/// Clears in-memory tokens, persisted JWTs, and auth notifiers.
Future<BaseAuthUser> clearJavaSession({bool clearPersisted = true}) async {
  JavaApiClient.instance.accessToken = null;
  JavaApiClient.instance.refreshToken = null;
  if (clearPersisted) {
    await JavaSessionStore.clear();
  }
  final signedOut = JavaAuthUser.signedOut();
  updateAuthUser(signedOut);
  updateJwtToken(null);
  AppStateNotifier.instance.update(signedOut);
  return signedOut;
}

/// Signed-out UI state without wiping a persisted session (transient errors).
Future<BaseAuthUser> markJavaSessionUnavailable() {
  final signedOut = JavaAuthUser.signedOut();
  updateAuthUser(signedOut);
  AppStateNotifier.instance.update(signedOut);
  return Future.value(signedOut);
}
