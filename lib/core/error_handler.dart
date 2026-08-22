import 'package:flutter/foundation.dart';

class AppLogger {
  static const _fallback = 'Something went wrong. Please try again.';

  static const _codes = <String, String>{
    'CART_UNAUTHORIZED': 'Please sign in to update your cart.',
    'CART_INVALID_QTY': 'Please choose a valid quantity.',
    'CART_UNAVAILABLE': 'This product is no longer available.',
    'CART_STOCK': 'Not enough stock for this item.',
    'CART_PRODUCT': 'This product could not be added to the cart.',
    'CART_NOT_FOUND': 'Your cart could not be found.',
    'ORDER_CREATE_FAILED': 'Unable to place the order. Please try again.',
  };

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

  /// Structured developer log. Never show this string in the UI.
  static void event(
    String code, {
    Map<String, Object?>? fields,
    Object? error,
  }) {
    final parts = <String>[
      code,
      ...?fields?.entries.map((entry) => '${entry.key}=${entry.value}'),
      if (error != null) 'error=$error',
      'timestamp=${DateTime.now().toUtc().toIso8601String()}',
    ];
    log(parts.join(' '));
  }

  /// Map RPC / PostgREST failures to a short customer sentence.
  static String userFacingMessage(
    Object? error, {
    String fallback = _fallback,
  }) {
    if (error == null) return fallback;
    final raw = error.toString();
    for (final entry in _codes.entries) {
      if (raw.contains(entry.key)) return entry.value;
    }
    if (raw.contains('Insufficient stock')) {
      return 'Not enough stock for this item.';
    }
    if (raw.contains('is unavailable')) {
      return 'This product is no longer available.';
    }
    if (raw.contains('not sold by this business')) {
      return 'This product is not sold by this shop.';
    }
    if (raw.contains('Please sign in')) {
      return 'Please sign in to continue.';
    }
    if (raw.contains('Cart is empty')) {
      return 'Your cart is empty.';
    }
    if (raw.contains('Invalid delivery OTP') || raw.contains('OTP')) {
      if (raw.toLowerCase().contains('invalid') ||
          raw.toLowerCase().contains('expired') ||
          raw.toLowerCase().contains('consumed')) {
        return 'The delivery code is invalid or has expired.';
      }
    }
    if (_looksInternal(raw)) return fallback;

    final match = RegExp(r'(?:Exception:|ERROR:)\s*(.+)').firstMatch(raw);
    final cleaned = (match?.group(1) ?? raw).trim();
    if (cleaned.length <= 80 &&
        !_looksInternal(cleaned) &&
        !cleaned.contains('{')) {
      return cleaned;
    }
    return fallback;
  }

  static bool _looksInternal(String raw) {
    final text = raw.toLowerCase();
    return text.contains('postgrestexception') ||
        text.contains('pgrst') ||
        text.contains('permission denied') ||
        text.contains('row-level security') ||
        text.contains('jwt') ||
        text.contains('apikey') ||
        text.contains('service_role') ||
        text.contains('supabase') ||
        text.contains('stack trace') ||
        text.contains('sqlstate');
  }
}
