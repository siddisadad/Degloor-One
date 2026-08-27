import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:degloor_one/core/api/api_client.dart';

class AppLogger {
  static const _fallback = 'Something went wrong. Please try again.';

  static const _codes = <String, String>{
    'CART_UNAUTHORIZED': 'Please sign in to update your cart.',
    'CART_INVALID_QTY': 'Please choose a valid quantity.',
    'CART_UNAVAILABLE': 'This product is no longer available.',
    'CART_STOCK': 'Not enough stock for this item.',
    'CART_OUT_OF_STOCK': 'Not enough stock for this item.',
    'CART_NEEDS_REPLACEMENT':
        'Your cart has items from another shop. Clear it to add this item.',
    'CART_EMPTY': 'Your cart is empty.',
    'CART_PRODUCT': 'This product could not be added to the cart.',
    'CART_NOT_FOUND': 'Your cart could not be found.',
    'ORDER_CREATE_FAILED': 'Unable to place the order. Please try again.',
    'UNAUTHORIZED': 'Please sign in to continue.',
    'INVALID_CREDENTIALS': 'Email or password is incorrect.',
    'INVALID_REFRESH': 'Please sign in again.',
    'FORBIDDEN': 'You do not have permission for this action.',
    'BUSINESS_NOT_VERIFIED': 'This shop is not accepting orders yet.',
    'PRODUCT_UNAVAILABLE': 'This product is no longer available.',
    'BUSINESS_EXISTS': 'You already have a shop with that name.',
    'INVALID_LOCATION': 'Please pick a valid location on the map.',
    'INVALID_RADIUS': 'Please choose a valid discovery radius.',
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
        text.contains('network is unreachable') ||
        text.contains('timeout');
  }

  static void log(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    int level = 0,
    String name = 'App',
  }) {
    final fullMessage = isUnreachable(error)
        ? '$message (Supabase host unreachable)'
        : message;

    dev.log(
      fullMessage,
      name: name,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      final logPrefix = error != null ? 'ERROR' : 'LOG';
      debugPrint('$logPrefix [$name]: $fullMessage');
      if (error != null) debugPrint('Details: $error');
      if (stackTrace != null) debugPrint('Stack trace:\n$stackTrace');
    }
  }

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    log(message, error: error, stackTrace: stackTrace, level: 500, name: 'DEBUG');
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    log(message, error: error, stackTrace: stackTrace, level: 800, name: 'INFO');
  }

  static void warn(String message, [Object? error, StackTrace? stackTrace]) {
    log(message, error: error, stackTrace: stackTrace, level: 900, name: 'WARN');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    log(message, error: error, stackTrace: stackTrace, level: 1000, name: 'ERROR');
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
      if (error != null && kDebugMode) 'error=$error',
      'timestamp=${DateTime.now().toUtc().toIso8601String()}',
    ];
    log(parts.join(' '), name: 'EVENT');
  }

  /// Map RPC / PostgREST failures to a short customer sentence.
  static String userFacingMessage(
    Object? error, {
    String fallback = _fallback,
  }) {
    if (error == null) return fallback;
    if (error is JavaApiException) {
      final mapped = _codes[error.code];
      if (mapped != null) return mapped;
      if (error.message.length <= 250 &&
          !_looksInternal(error.message) &&
          !error.message.contains('{')) {
        return error.message;
      }
      return fallback;
    }
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
    if (_looksInternal(raw)) return fallback;

    final match =
        RegExp(r'(?:Exception:|ERROR:|JavaApiException:)\s*(.+)').firstMatch(raw);
    final cleaned = (match?.group(1) ?? raw).trim();
    if (cleaned.length <= 250 &&
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
