import 'dart:io';

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

  test('token refresh catch path marks the session unavailable', () {
    final source = File('lib/core/api/api_client.dart').readAsStringSync();
    final refresh = source.split('Future<bool> _refreshTokens()').last;
    final catchBody = refresh.split('catch (_) {').last.split('}\n  }').first;
    expect(catchBody, contains('markJavaSessionUnavailable()'));
    expect(catchBody, isNot(contains('clearJavaSession()')));
    expect(source, contains('await clearJavaSession();'));
  });

  test('token refresh coalesces concurrent waiters', () {
    final source = File('lib/core/api/api_client.dart').readAsStringSync();
    expect(source, contains('coalesceInFlight<bool>('));
    expect(source, contains('Completer<bool>? _refreshCompleter'));
    expect(source, isNot(contains('bool _refreshing')));
    expect(source, isNot(contains('if (_refreshing ||')));
  });
}
