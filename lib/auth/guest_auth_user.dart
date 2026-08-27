import 'package:degloor_one/shared/user_role.dart';

import 'base_auth_user_provider.dart';

export 'base_auth_user_provider.dart';

/// Local session used while the FlutterFlow Supabase host has no auth.
class GuestAuthUser extends BaseAuthUser {
  static const guestUid = '00000000-0000-4000-8000-000000000001';

  GuestAuthUser({this.accountRole = 'customer'});

  String accountRole;

  @override
  bool get loggedIn => true;

  @override
  bool get emailVerified => true;

  @override
  String? get role => accountRole;

  @override
  AuthUserInfo get authUserInfo => const AuthUserInfo(
        uid: guestUid,
        email: 'guest@local',
        displayName: 'Guest',
      );

  @override
  Future? delete() async {}

  @override
  Future? updateEmail(String email) async {}

  @override
  Future? updatePassword(String newPassword) async {}

  @override
  Future? sendEmailVerification() async {}
}

void installGuestSession() {
  currentUser = GuestAuthUser();
}

/// Guest `users` row is local. Keep the session role in sync.
void promoteGuestRole(UserRole role) {
  final user = currentUser;
  if (user is! GuestAuthUser) return;
  user.accountRole = role.value;
  updateAuthUser(user);
}
