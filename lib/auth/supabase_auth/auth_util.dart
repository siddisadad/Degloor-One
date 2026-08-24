import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/auth/java_auth_user.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'supabase_auth_manager.dart';

export 'supabase_auth_manager.dart';

final _authManager = SupabaseAuthManager();
SupabaseAuthManager get authManager => _authManager;

String get currentUserEmail => currentUser?.email ?? '';

String get currentUserUid => currentUser?.uid ?? '';

String get currentUserDisplayName => currentUser?.displayName ?? '';

String get currentUserPhoto => currentUser?.photoUrl ?? '';

String get currentPhoneNumber => currentUser?.phoneNumber ?? '';

String get currentJwtToken => _currentJwtToken ?? '';

bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;

Future<String?> getCurrentUserRole() async {
  if (currentUser is GuestAuthUser) return 'customer';
  if (currentUser is JavaAuthUser) return currentUser?.role;
  if (!loggedIn || currentUserUid.length < 10) return null;
  return UserService.instance.roleFor(currentUserUid);
}

/// Create a Stream that listens to the current user's JWT Token.
String? _currentJwtToken;
final jwtTokenStream = SupaFlow.client.auth.onAuthStateChange
    .map(
      (authState) => _currentJwtToken = authState.session?.accessToken,
    )
    .asBroadcastStream();
