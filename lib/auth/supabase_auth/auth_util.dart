import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:degloor_one/auth/auth_repository.dart';
import 'package:degloor_one/auth/java_auth/java_auth_repository.dart';
import 'package:degloor_one/auth/supabase_auth/supabase_auth_repository.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/auth/java_auth_user.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/core/api/api_client.dart';

export 'package:degloor_one/auth/auth_repository.dart';
export 'package:degloor_one/auth/base_auth_user_provider.dart';

AuthRepository get authManager => JavaApiConfig.enabled
    ? JavaAuthRepository()
    : SupabaseAuthRepository();

extension AuthRepositoryExtensions on AuthRepository {
  /// Helper to refresh the user from the current instance.
  Future<void> refresh() => refreshUser();
}

String get currentUserEmail => currentUser?.email ?? '';

String get currentUserUid => currentUser?.uid ?? '';

String get currentUserDisplayName => currentUser?.displayName ?? '';

String get currentUserPhoto => currentUser?.photoUrl ?? '';

String get currentPhoneNumber => currentUser?.phoneNumber ?? '';

String get currentJwtToken {
  if (JavaApiConfig.enabled) {
    return JavaApiClient.instance.accessToken ?? '';
  }
  return SupaFlow.client.auth.currentSession?.accessToken ?? '';
}

bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;

Future<String?> getCurrentUserRole() async {
  if (currentUser is GuestAuthUser) return currentUser?.role;
  if (currentUser is JavaAuthUser) return currentUser?.role;
  if (!loggedIn || currentUserUid.length < 10) return null;
  return UserService.instance.roleFor(currentUserUid);
}

final jwtTokenStream = JavaApiConfig.enabled
    ? jwtTokenUpdateStream
        .startWith(JavaApiClient.instance.accessToken)
        .asBroadcastStream()
    : SupaFlow.client.auth.onAuthStateChange
        .map(
          (authState) => authState.session?.accessToken,
        )
        .asBroadcastStream();
