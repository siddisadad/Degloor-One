import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// FlutterFlow project hostname. Live `--dart-define` URLs do not match,
  /// so those Auth calls still run. A successful health probe unblocks this
  /// host without flipping guest mode.
  static const deadFlutterFlowHost = kDeadFlutterFlowHost;

  static bool get shouldSkipAuthRequest => kShouldBlockSupabaseTraffic;

  /// GoTrue `/auth/v1/health` on the compiled project. Used at startup so a
  /// restored FlutterFlow host is not treated as NXDOMAIN.
  static Future<bool> probeLive({
    http.Client? client,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient
          .get(
            Uri.parse('$kSupabaseUrl/auth/v1/health'),
            headers: {
              'apikey': kSupabaseAnonKey,
              'Authorization': 'Bearer $kSupabaseAnonKey',
            },
          )
          .timeout(timeout);
      if (response.statusCode != 200) return false;
      final body = response.body;
      return body.contains('GoTrue') || body.contains('version');
    } catch (_) {
      return false;
    } finally {
      if (client == null) httpClient.close();
    }
  }

  static Future<void> discoverLiveHost({http.Client? client}) async {
    if (!kUsesDeadFlutterFlowHost || AppEnvironment.flutterFlowHostIsLive) {
      return;
    }
    if (await probeLive(client: client)) {
      AppEnvironment.markFlutterFlowHostLive();
    }
  }

  /// Returns false when the request must not be sent (avoids Chrome
  /// `net::ERR_NAME_NOT_RESOLVED` on `/auth/v1/token`).
  static bool guard(BuildContext context) {
    if (!shouldSkipAuthRequest) return true;
    showSnackBar(context, Exception('failed to fetch'));
    return false;
  }

  static bool looksUnreachable(Object error) => AppLogger.isUnreachable(error);

  static String messageFor(Object error, {String? authMessage}) {
    final extracted = _authCopy(error, authMessage);
    if (looksUnreachable(error) ||
        (extracted != null && looksUnreachable(extracted))) {
      return kBypassAuth ? guestUnreachableMessage : unreachableMessage;
    }
    if (extracted == null || extracted.isEmpty) {
      return 'Error: $error';
    }
    if (extracted.contains('User already registered')) {
      return 'Error: The email is already in use by a different account';
    }
    if (extracted.toLowerCase().contains('rate limit')) {
      return 'Please wait a moment before trying again.';
    }
    return 'Error: $extracted';
  }

  /// AuthException.message, or the `message:` field dumped in
  /// `AuthApiException(message: ..., statusCode: ...)`.
  static String? _authCopy(Object error, String? authMessage) {
    if (authMessage != null && authMessage.trim().isNotEmpty) {
      return authMessage.trim();
    }
    if (error is AuthException && error.message.trim().isNotEmpty) {
      return error.message.trim();
    }
    final dumped = error.toString();
    if (!dumped.contains('AuthApiException') &&
        !dumped.contains('AuthException(')) {
      return null;
    }
    return RegExp(r'message:\s*([^,)]+)').firstMatch(dumped)?.group(1)?.trim();
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
    final copy = authMessage ??
        (error is AuthException ? error.message : null);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageFor(error, authMessage: copy))),
    );
  }
}
