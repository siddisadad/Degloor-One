import 'package:flutter/material.dart';
import 'package:degloor_one/core/error_handler.dart';

/// Maps low-level HTTP / DNS failures from the Supabase client into a
/// user-facing message. Chrome reports these as `net::ERR_NAME_NOT_RESOLVED`
/// with no app frames. `AuthRetryableFetchException` is an `AuthException`,
/// so callers must run the exception *and* `e.message` through this helper
/// instead of showing `Error: ${e.message}` raw.
class SupabaseConnection {
  static const unreachableMessage =
      'Cannot reach the Degloor One server. Restore the Supabase project '
      'or set SUPABASE_URL / SUPABASE_ANON_KEY to a live project.';

  static bool looksUnreachable(Object error) => AppLogger.isUnreachable(error);

  static String messageFor(Object error, {String? authMessage}) {
    if (looksUnreachable(error) ||
        (authMessage != null && looksUnreachable(authMessage))) {
      return unreachableMessage;
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
      AppLogger.log(
        '$context: Supabase host is unreachable (check SUPABASE_URL)',
      );
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
