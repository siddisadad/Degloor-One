import 'package:degloor_one/shared/user_role.dart';

/// Where `/` (`_initialize`) should send the session.
///
/// Guest bypass used to dump everyone on customer home, including a shop
/// owner or provider who just promoted locally.
Future<String> resolveStartRoute({
  required bool passwordRecoveryPending,
  required bool loggedIn,
  required bool bypassAuth,
  required String? role,
  required String userId,
  required Future<bool> Function(String userId) hasOwnedShop,
  required Future<bool> Function(String userId) hasProviderProfile,
}) async {
  if (passwordRecoveryPending) return 'ResetPassword';
  if (!loggedIn) {
    return bypassAuth ? 'CustomerHome' : 'Authentication';
  }

  final account = UserRole.parse(role);
  if (account.isBusinessOwner) {
    return await hasOwnedShop(userId)
        ? 'BusinessDashboard'
        : 'BusinessRegistration';
  }
  if (account.isServiceProvider) {
    return await hasProviderProfile(userId)
        ? 'ManageServiceRequests'
        : 'ServiceProviderRegistration';
  }
  if (account.value == UserRole.admin.value) {
    return 'AdminControlPanel';
  }
  return 'CustomerHome';
}
