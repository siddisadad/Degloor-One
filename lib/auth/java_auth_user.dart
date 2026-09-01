import 'package:degloor_one/auth/base_auth_user_provider.dart';
import 'package:degloor_one/auth/java_auth/java_session_lifecycle.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/auth_api.dart';

/// Signed-in customer from the Java auth API. Screens use [BaseAuthUser].
class JavaAuthUser extends BaseAuthUser {
  JavaAuthUser({
    required this.id,
    required this.emailAddress,
    required this.userRole,
    this.fullName,
    this.phone,
  });

  String id;
  String emailAddress;
  String userRole;
  String? fullName;
  String? phone;

  factory JavaAuthUser.signedOut() => JavaAuthUser(
        id: '',
        emailAddress: '',
        userRole: '',
      );

  /// Java `AuthUser`.
  factory JavaAuthUser.fromJson(Map<String, dynamic> json) {
    return JavaAuthUser(
      id: '${json['id'] ?? ''}',
      emailAddress: '${json['email'] ?? ''}',
      userRole: '${json['role'] ?? 'customer'}',
      fullName: json['fullName'] as String?,
      phone: json['phoneNumber'] as String?,
    );
  }

  /// Java `TokenResponse`.
  factory JavaAuthUser.fromTokenResponse(Map<String, dynamic> data) {
    final user = data['user'];
    if (user is! Map) {
      throw JavaApiException('INVALID_RESPONSE', 'Unexpected server response');
    }
    return JavaAuthUser.fromJson(Map<String, dynamic>.from(user));
  }

  @override
  bool get loggedIn => id.isNotEmpty;

  @override
  bool get emailVerified => loggedIn;

  @override
  String? get role => userRole.isEmpty ? null : userRole;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: id.isEmpty ? null : id,
        email: emailAddress.isEmpty ? null : emailAddress,
        displayName: fullName,
        phoneNumber: phone,
      );

  void apply(JavaAuthUser other) {
    id = other.id;
    emailAddress = other.emailAddress;
    userRole = other.userRole;
    fullName = other.fullName;
    phone = other.phone;
  }

  @override
  Future refreshUser() async {
    if (id.isEmpty) return;
    try {
      await AuthApi.refresh();
      await emitJavaUser(JavaAuthUser.fromJson(await AuthApi.me()));
    } on JavaApiException catch (error) {
      if (isJavaAuthFailure(error)) {
        await clearJavaSession();
        return;
      }
      rethrow;
    }
  }

  @override
  Future? delete() async {}

  @override
  Future? updateEmail(String email) async {}

  @override
  Future? updatePassword(String newPassword) async {}

  @override
  Future? sendEmailVerification() async {}
}
