import 'package:degloor_one/auth/java_auth/java_session_lifecycle.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isJavaAuthFailure matches recoverable auth codes', () {
    expect(
      isJavaAuthFailure(JavaApiException('HTTP_401', 'Unauthorized')),
      isTrue,
    );
    expect(
      isJavaAuthFailure(JavaApiException('UNAUTHORIZED', 'Sign in required')),
      isTrue,
    );
    expect(
      isJavaAuthFailure(JavaApiException('INVALID_REFRESH', 'Expired')),
      isTrue,
    );
    expect(
      isJavaAuthFailure(JavaApiException('HTTP_500', 'Server error')),
      isFalse,
    );
    expect(
      isJavaAuthFailure(JavaApiException('UNREACHABLE', 'Offline')),
      isFalse,
    );
  });
}
