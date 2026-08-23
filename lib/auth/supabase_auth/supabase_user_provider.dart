import 'package:rxdart/rxdart.dart';

import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/auth/password_recovery.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';

export '../base_auth_user_provider.dart';

class DegloorOneSupabaseUser extends BaseAuthUser {
  DegloorOneSupabaseUser(this.user, [this.role]);
  User? user;
  @override
  String? role;
  @override
  bool get loggedIn => user != null;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: user?.id,
        email: user?.email,
        displayName: user?.userMetadata?['full_name'],
        photoUrl: user?.userMetadata?['avatar_url'],
        phoneNumber: user?.phone,
      );

  @override
  Future? delete() =>
      throw UnsupportedError('The delete user operation is not yet supported.');

  @override
  Future? updateEmail(String email) async {
    if (kUsesDeadFlutterFlowHost) return;
    final response =
        await SupaFlow.client.auth.updateUser(UserAttributes(email: email));
    if (response.user != null) {
      user = response.user;
    }
  }

  @override
  Future? updatePassword(String newPassword) async {
    if (kUsesDeadFlutterFlowHost) return;
    final response = await SupaFlow.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    if (response.user != null) {
      user = response.user;
    }
  }

  @override
  Future? sendEmailVerification() => throw UnsupportedError(
      'The send email verification operation is not yet supported.');

  @override
  bool get emailVerified {
    // Reloads the user when checking in order to get the most up to date
    // email verified status.
    if (loggedIn && user!.emailConfirmedAt == null) {
      refreshUser();
    }
    return user?.emailConfirmedAt != null;
  }

  @override
  Future refreshUser() async {
    if (kUsesDeadFlutterFlowHost) return;
    await SupaFlow.client.auth.refreshSession().then((_) async {
      user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        final rows = await UsersTable().queryRows(
          queryFn: (q) => q.eq('id', user!.id),
        );
        if (rows.isNotEmpty) {
          role = rows.first.role;
        }
      }
    });
  }
}

/// Generates a stream of the authenticated user.
/// [SupaFlow.client.auth.onAuthStateChange] does not yield any values until the
/// user is already authenticated. So we add a default null user to the stream,
/// if we need to interact with the [currentUser] before logging in.
Stream<BaseAuthUser> degloorOneSupabaseUserStream() {
  if (kBypassAuth) {
    installGuestSession();
    return Stream<BaseAuthUser>.value(currentUser!);
  }
  final supabaseAuthStream = SupaFlow.client.auth.onAuthStateChange.debounce(
      (authState) => authState.event == AuthChangeEvent.tokenRefreshed
          ? TimerStream(authState, const Duration(seconds: 1))
          : Stream.value(authState));
  return (!loggedIn
          ? Stream<AuthState?>.value(null).concatWith([supabaseAuthStream])
          : supabaseAuthStream)
      .asyncMap<BaseAuthUser>(
    (authState) async {
      if (authState?.event == AuthChangeEvent.passwordRecovery) {
        PasswordRecovery.pending.value = true;
      }
      final user = authState?.session?.user;
      String? role;
      if (user != null && !kUsesDeadFlutterFlowHost) {
        final rows = await UsersTable().queryRows(
          queryFn: (q) => q.eq('id', user.id),
        );
        if (rows.isNotEmpty) {
          role = rows.first.role;
        }
      }
      currentUser = DegloorOneSupabaseUser(user, role);
      return currentUser!;
    },
  );
}
