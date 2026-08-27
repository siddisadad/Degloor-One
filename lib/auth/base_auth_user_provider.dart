import 'dart:async';

class AuthUserInfo {
  const AuthUserInfo({
    this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
  });

  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
}

abstract class BaseAuthUser {
  bool get loggedIn;
  bool get emailVerified;

  AuthUserInfo get authUserInfo;

  Future? delete();
  Future? updateEmail(String email);
  Future? updatePassword(String newPassword);
  Future? sendEmailVerification();
  Future refreshUser() async {}

  String? get uid => authUserInfo.uid;
  String? get email => authUserInfo.email;
  String? get displayName => authUserInfo.displayName;
  String? get photoUrl => authUserInfo.photoUrl;
  String? get phoneNumber => authUserInfo.phoneNumber;
  String? get role => null;
}

BaseAuthUser? currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;

final StreamController<BaseAuthUser> _authStreamController =
    StreamController<BaseAuthUser>.broadcast();

void updateAuthUser(BaseAuthUser user) {
  currentUser = user;
  _authStreamController.add(user);
}

Stream<BaseAuthUser> get authUserStream => _authStreamController.stream;

final StreamController<String?> _jwtStreamController =
    StreamController<String?>.broadcast();

void updateJwtToken(String? token) {
  _jwtStreamController.add(token);
}

Stream<String?> get jwtTokenUpdateStream => _jwtStreamController.stream;
