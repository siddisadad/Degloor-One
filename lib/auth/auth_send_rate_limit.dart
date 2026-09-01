import 'dart:async';

import 'package:degloor_one/core/api/api_client.dart';
import 'package:flutter/foundation.dart';

/// GoTrue throttles confirmation, recovery, and OTP emails. The client dumps
/// `AuthApiException(..., code: over_email_send_rate_limit)` when the user
/// retries too soon — this maps that 429 into customer copy and a cooldown.
class AuthSendRateLimit {
  static const defaultCooldown = Duration(seconds: 60);

  static final _waitSeconds =
      RegExp(r'after (\d+) seconds?', caseSensitive: false);

  static bool matches(Object error, {String? authMessage}) {
    final text = _haystack(error, authMessage).toLowerCase();
    return text.contains('over_email_send_rate_limit') ||
        text.contains('over_sms_send_rate_limit') ||
        text.contains('over_request_rate_limit') ||
        text.contains('you can only request this after') ||
        text.contains('email rate limit') ||
        text.contains('sms rate limit') ||
        (text.contains('rate limit') &&
            (text.contains('429') || text.contains('send')));
  }

  /// Seconds GoTrue asked the user to wait, if the message includes them.
  static int? remainingSeconds(Object error, {String? authMessage}) {
    final match = _waitSeconds.firstMatch(_haystack(error, authMessage));
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static String userMessage(Object error, {String? authMessage}) {
    final seconds = remainingSeconds(error, authMessage: authMessage);
    if (seconds != null && seconds > 0) {
      return 'Please wait $seconds seconds before trying again.';
    }
    return 'Please wait a moment before trying again.';
  }

  static String? tryUserMessage(Object error, {String? authMessage}) {
    if (!matches(error, authMessage: authMessage)) return null;
    return userMessage(error, authMessage: authMessage);
  }

  static String _haystack(Object error, String? authMessage) {
    return [
      authMessage,
      if (error is JavaApiException) error.code,
      if (error is JavaApiException) error.message,
      error.toString(),
    ].whereType<String>().join('\n');
  }
}

/// One-second ticker used by signup email / password-reset / SMS resend.
class AuthResendCooldown {
  AuthResendCooldown({
    this.duration = AuthSendRateLimit.defaultCooldown,
    required this.onTick,
  });

  final Duration duration;
  final VoidCallback onTick;

  Timer? _timer;
  int remainingSeconds = 0;

  bool get isActive => remainingSeconds > 0;

  void start({int? seconds, bool notify = true}) {
    _timer?.cancel();
    remainingSeconds = seconds ?? duration.inSeconds;
    if (remainingSeconds < 0) remainingSeconds = 0;
    if (notify) onTick();
    if (remainingSeconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 1) {
        timer.cancel();
        remainingSeconds = 0;
      } else {
        remainingSeconds -= 1;
      }
      onTick();
    });
  }

  /// Keep the button disabled for at least [seconds], without shortening an
  /// already-running wait.
  void extendTo(int seconds) {
    if (seconds <= remainingSeconds) return;
    start(seconds: seconds);
  }

  void dispose() {
    _timer?.cancel();
  }
}
