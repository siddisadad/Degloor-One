import 'package:degloor_one/auth/java_auth/java_session_bootstrap.dart';
import 'package:degloor_one/auth/java_auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restoreJavaAuthSession returns signed-out when Java backend is disabled',
      () async {
    final user = await restoreJavaAuthSession();
    expect(user, isA<JavaAuthUser>());
    expect(user.loggedIn, isFalse);
  });
}
