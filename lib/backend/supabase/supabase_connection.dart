import 'package:flutter/material.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/error_handler.dart';

/// Maps low-level HTTP / DNS failures from the Supabase client into a
/// user-facing message. Chrome reports these as `net::ERR_NAME_NOT_RESOLVED`
/// with no app frames. `AuthRetryableFetchException` is an `AuthException`,
/// so callers must run the exception *and* `e.message` through this helper
/// instead of showing `Error: ${e.message}` raw.
class SupabaseConnection {
  /// Customer copy when a live host cannot be reached.
  static const unreachableMessage =
      'Cannot reach the Degloor One server. Please try again.';

  /// Customer copy when the retired FlutterFlow host is compiled in.
  /// Guest mode is the path; dart-defines stay off the screen and console.
  static const guestUnreachableMessage =
      'Sign in needs a live server. Continue as Guest to browse Degloor.';

  /// FlutterFlow project that currently NXDOMAINs. A live `--dart-define`
  /// URL will not match, so real Auth calls still run.
  static const deadFlutterFlowHost = kDeadFlutterFlowHost;

  static bool get shouldSkipAuthRequest => kUsesDeadFlutterFlowHost;

  /// Returns false when the request must not be sent (avoids Chrome
  /// `net::ERR_NAME_NOT_RESOLVED` on `/auth/v1/token`).
  static bool guard(BuildContext context) {
    if (!shouldSkipAuthRequest) return true;
    showSnackBar(context, Exception('failed to fetch'));
    return false;
  }

  static bool looksUnreachable(Object error) => AppLogger.isUnreachable(error);

  static String messageFor(Object error, {String? authMessage}) {
    if (looksUnreachable(error) ||
        (authMessage != null && looksUnreachable(authMessage))) {
      return kBypassAuth ? guestUnreachableMessage : unreachableMessage;
    }
    if (authMessage != null &&
        authMessage.contains('User already registered')) {
      return 'Error: The email is already in use by a different account';
    }
    if (authMessage != null && authMessage.trim().isNotEmpty) {
      return 'Error: $authMessage';
    }
    return 'Error: $error';
  }

  static void log(Object error, {String context = 'Auth error'}) {
    if (looksUnreachable(error)) {
      return;
    }
    AppLogger.error(context, error);
  }

  static void showSnackBar(
    BuildContext context,
    Object error, {
    String? authMessage,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageFor(error, authMessage: authMessage))),
    );
  }
}
