import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Tracks a password-recovery session so routing can send the user to the
/// new-password form instead of their normal home screen.
///
/// Supabase sets [pending] via `AuthChangeEvent.passwordRecovery`. Java mode
/// sets [pending] + [resetToken] from the forgot-password response (dev/test)
/// or from a `/resetPassword?token=` deep link.
class PasswordRecovery {
  static final ValueNotifier<bool> pending = ValueNotifier<bool>(false);

  /// One-time token from the Java API. Cleared after a successful update.
  static String? resetToken;

  static const routePath = '/resetPassword';
  static const deepLink = 'degloorone://degloorone.com$routePath';

  static String redirectTo() {
    if (kIsWeb) {
      return '${Uri.base.origin}$routePath';
    }
    return deepLink;
  }

  static void beginWithToken(String token) {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return;
    resetToken = trimmed;
    pending.value = true;
  }

  static void clear() {
    resetToken = null;
    pending.value = false;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  static String? validateNewPassword(String password, String confirm) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (password != confirm) {
      return 'Passwords do not match';
    }
    return null;
  }
}
