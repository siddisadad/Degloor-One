import 'package:flutter/foundation.dart';

class AppLogger {
  /// DNS / browser-fetch failures against a missing Supabase host.
  /// Chrome still prints `net::ERR_NAME_NOT_RESOLVED`; we just avoid a
  /// second `ERROR: AuthRetryableFetchException(...)` dump.
  static bool isUnreachable(Object? error) {
    if (error == null) return false;
    final text = error.toString().toLowerCase();
    return text.contains('failed host lookup') ||
        text.contains('name not resolved') ||
        text.contains('name_not_resolved') ||
        text.contains('failed to fetch') ||
        text.contains('xmlhttprequest') ||
        text.contains('clientexception') ||
        text.contains('authretryablefetchexception') ||
        text.contains('socketexception') ||
        text.contains('connection refused') ||
        text.contains('network is unreachable');
  }

  static void log(String message, {Object? error, StackTrace? stackTrace}) {
    if (isUnreachable(error)) {
      debugPrint('DEBUG: $message (Supabase host unreachable)');
      return;
    }
    if (kDebugMode) {
      debugPrint('DEBUG: $message');
      if (error != null) debugPrint('ERROR: $error');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    } else {
      debugPrint('LOG: $message');
      if (error != null) debugPrint('ERR: $error');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    log(message, error: error, stackTrace: stackTrace);
  }
}
