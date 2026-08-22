import 'base_auth_user_provider.dart';

export 'base_auth_user_provider.dart';

/// Local customer used while the FlutterFlow Supabase host is down.
class GuestAuthUser extends BaseAuthUser {
  static const guestUid = '00000000-0000-4000-8000-000000000001';

  @override
  bool get loggedIn => true;

  @override
  bool get emailVerified => true;

  @override
  String? get role => 'customer';

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
