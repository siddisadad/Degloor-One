import 'package:degloor_one/auth/auth_send_rate_limit.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dumped =
      'AuthApiException (message: For security purposes, you can only request this after 47 seconds., '
      'statusCode: 429, code: over_email_send_rate_limit)';

  test('maps the GoTrue email send 429 to a wait sentence', () {
    expect(AuthSendRateLimit.matches(Exception(dumped)), isTrue);
    expect(AuthSendRateLimit.remainingSeconds(Exception(dumped)), 47);
    expect(
      AuthSendRateLimit.tryUserMessage(Exception(dumped)),
      'Please wait 47 seconds before trying again.',
    );
    expect(
      AuthSendRateLimit.tryUserMessage(
        JavaApiException(
          'over_email_send_rate_limit',
          'For security purposes, you can only request this after 47 seconds.',
        ),
      ),
      'Please wait 47 seconds before trying again.',
    );
  });

  test('maps a rate-limit message that has no remaining seconds', () {
    expect(
      AuthSendRateLimit.tryUserMessage(
        Exception(
          'AuthApiException(message: email rate limit exceeded, statusCode: 429, code: over_email_send_rate_limit)',
        ),
      ),
      'Please wait a moment before trying again.',
    );
  });

  test('ignores ordinary auth failures', () {
    expect(
      AuthSendRateLimit.matches(
        Exception(
          'AuthApiException(message: Invalid login credentials, statusCode: 400, code: invalid_credentials)',
        ),
      ),
      isFalse,
    );
    expect(
      AuthSendRateLimit.tryUserMessage(
        Exception('Invalid login credentials'),
      ),
      isNull,
    );
  });

  test('AuthResendCooldown counts down without shortening a longer wait', () {
    fakeAsync((async) {
      var ticks = 0;
      final cooldown = AuthResendCooldown(onTick: () => ticks++);
      cooldown.start(seconds: 3);
      expect(cooldown.remainingSeconds, 3);
      expect(cooldown.isActive, isTrue);
      cooldown.extendTo(2);
      expect(cooldown.remainingSeconds, 3);
      async.elapse(const Duration(seconds: 1));
      expect(cooldown.remainingSeconds, 2);
      cooldown.extendTo(4);
      expect(cooldown.remainingSeconds, 4);
      async.elapse(const Duration(seconds: 4));
      expect(cooldown.remainingSeconds, 0);
      expect(cooldown.isActive, isFalse);
      expect(ticks, greaterThan(1));
      cooldown.dispose();
    });
  });
}
