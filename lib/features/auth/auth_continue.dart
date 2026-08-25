import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/discovery_service.dart';

/// Where to send the session after email sign-in or sign-up.
Future<String> routeAfterAuth({
  required bool isBusinessOwner,
  required bool bypassAuth,
}) async {
  if (!isBusinessOwner) return '_initialize';
  if (bypassAuth) return 'BusinessRegistration';
  final userId = currentUserUid;
  if (userId.isEmpty) return 'BusinessRegistration';
  try {
    final shops = await DiscoveryService.instance
        .ownedBy(userId)
        .timeout(const Duration(seconds: 10));
    return shops.isEmpty ? 'BusinessRegistration' : 'BusinessDashboard';
  } catch (_) {
    return 'BusinessRegistration';
  }
}
