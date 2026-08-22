import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';

void main() {
  test('guest bypass is on for the default FlutterFlow host', () {
    expect(kUsesDeadFlutterFlowHost, isTrue);
    expect(kBypassAuth, isTrue);

    final guest = GuestAuthUser();
    expect(guest.loggedIn, isTrue);
    expect(guest.role, 'customer');
    expect(guest.uid, GuestAuthUser.guestUid);
    expect(guest.uid!.length, greaterThan(10));

    installGuestSession();
    expect(currentUser, isA<GuestAuthUser>());
    expect(loggedIn, isTrue);
  });
}
