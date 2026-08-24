import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/java_auth_user.dart';
import 'package:degloor_one/core/api/api_client.dart';

void main() {
  test('Java token JSON maps to JavaAuthUser', () {
    final user = JavaAuthUser.fromTokenResponse({
      'accessToken': 'access',
      'refreshToken': 'refresh',
      'user': {
        'id': '11111111-1111-4111-8111-111111111111',
        'email': 'ravi@degloor.local',
        'fullName': 'Ravi',
        'phoneNumber': '9876543210',
        'role': 'customer',
      },
    });
    expect(user, isA<JavaAuthUser>());
    expect(user.loggedIn, isTrue);
    expect(user.uid, '11111111-1111-4111-8111-111111111111');
    expect(user.email, 'ravi@degloor.local');
    expect(user.displayName, 'Ravi');
    expect(user.phoneNumber, '9876543210');
    expect(user.role, 'customer');
    expect(user.emailVerified, isTrue);
  });

  test('Java me JSON refreshes the signed-in user', () {
    final user = JavaAuthUser.signedOut();
    user.apply(JavaAuthUser.fromJson({
      'id': '11111111-1111-4111-8111-111111111111',
      'email': 'ravi@degloor.local',
      'fullName': 'Ravi Patil',
      'role': 'shop_owner',
    }));
    expect(user.loggedIn, isTrue);
    expect(user.displayName, 'Ravi Patil');
    expect(user.role, 'shop_owner');
  });

  test('Java signed-out user is not logged in', () {
    final user = JavaAuthUser.signedOut();
    expect(user.loggedIn, isFalse);
    expect(user.uid, isNull);
    expect(user.role, isNull);
  });

  test('Java token JSON without a user is invalid', () {
    expect(
      () => JavaAuthUser.fromTokenResponse({'accessToken': 'access'}),
      throwsA(isA<JavaApiException>()),
    );
  });
}
