import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/password_recovery.dart';

void main() {
  test('isValidEmail accepts a normal address and rejects junk', () {
    expect(PasswordRecovery.isValidEmail('owner@degloor.one'), isTrue);
    expect(PasswordRecovery.isValidEmail('  owner@degloor.one  '), isTrue);
    expect(PasswordRecovery.isValidEmail('not-an-email'), isFalse);
    expect(PasswordRecovery.isValidEmail(''), isFalse);
  });

  test('validateNewPassword requires length and a matching confirm field', () {
    expect(
      PasswordRecovery.validateNewPassword('12345', '12345'),
      'Password must be at least 6 characters',
    );
    expect(
      PasswordRecovery.validateNewPassword('secret1', 'secret2'),
      'Passwords do not match',
    );
    expect(PasswordRecovery.validateNewPassword('secret1', 'secret1'), isNull);
  });

  test('beginWithToken arms recovery and clear resets it', () {
    PasswordRecovery.clear();
    PasswordRecovery.beginWithToken('  abc123  ');
    expect(PasswordRecovery.pending.value, isTrue);
    expect(PasswordRecovery.resetToken, 'abc123');
    PasswordRecovery.clear();
    expect(PasswordRecovery.pending.value, isFalse);
    expect(PasswordRecovery.resetToken, isNull);
  });
}
