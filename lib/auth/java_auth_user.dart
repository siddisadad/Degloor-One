import 'package:degloor_one/auth/base_auth_user_provider.dart';
import 'package:degloor_one/core/api/api_client.dart';

/// Signed-in customer from the Java auth API. Screens use [BaseAuthUser].
class JavaAuthUser extends BaseAuthUser {
  JavaAuthUser({
    required this.id,
    required this.emailAddress,
    required this.userRole,
    this.fullName,
    this.phone,
  });

  final String id;
  final String emailAddress;
  final String userRole;
  final String? fullName;
  final String? phone;

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

  @override
  Future? delete() async {}

  @override
  Future? updateEmail(String email) async {}

  @override
  Future? updatePassword(String newPassword) async {}

  @override
  Future? sendEmailVerification() async {}
}
