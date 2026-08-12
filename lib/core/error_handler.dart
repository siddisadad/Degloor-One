import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('DEBUG: $message');
      if (error != null) debugPrint('ERROR: $error');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    } else {
      // In production, you might send this to Sentry, Firebase Crashlytics, etc.
      // For now, we'll just use debugPrint which is safer than print
      debugPrint('LOG: $message');
      if (error != null) debugPrint('ERR: $error');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    log(message, error: error, stackTrace: stackTrace);
  }
}
