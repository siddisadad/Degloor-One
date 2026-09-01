import 'package:degloor_one/auth/base_auth_user_provider.dart';
import 'package:degloor_one/auth/java_auth/java_session_lifecycle.dart';
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
    return clearJavaSession(clearPersisted: false);
  }

  final client = JavaApiClient.instance;
  client.accessToken = stored.accessToken;
  client.refreshToken = stored.refreshToken;

  try {
    return await emitJavaUser(JavaAuthUser.fromJson(await AuthApi.me()));
  } on JavaApiException catch (error) {
    if (!isJavaAuthFailure(error)) {
      return markJavaSessionUnavailable();
    }
    try {
      await AuthApi.refresh();
      return await emitJavaUser(JavaAuthUser.fromJson(await AuthApi.me()));
    } catch (_) {
      return clearJavaSession();
    }
  } catch (_) {
    return markJavaSessionUnavailable();
  }
}
