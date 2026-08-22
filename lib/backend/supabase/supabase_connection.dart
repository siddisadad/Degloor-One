/// Maps low-level HTTP / DNS failures from the Supabase client into a
/// user-facing message. Chrome reports these as `net::ERR_NAME_NOT_RESOLVED`
/// with no app frames.
class SupabaseConnection {
  static const unreachableMessage =
      'Cannot reach the Degloor One server. Restore the Supabase project '
      'or set SUPABASE_URL / SUPABASE_ANON_KEY to a live project.';

  static bool looksUnreachable(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('failed host lookup') ||
        text.contains('name not resolved') ||
        text.contains('failed to fetch') ||
        text.contains('xmlhttprequest') ||
        text.contains('clientexception') ||
        text.contains('socketexception') ||
        text.contains('connection refused') ||
        text.contains('network is unreachable');
  }

  static String messageFor(Object error, {String? authMessage}) {
    if (looksUnreachable(error)) {
      return unreachableMessage;
    }
    if (authMessage != null && authMessage.trim().isNotEmpty) {
      return 'Error: $authMessage';
    }
    return 'Error: $error';
  }
}
