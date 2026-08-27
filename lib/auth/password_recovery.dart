import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Tracks a Supabase `passwordRecovery` session so routing can send the user
/// to the new-password form instead of their normal home screen.
class PasswordRecovery {
  static final ValueNotifier<bool> pending = ValueNotifier<bool>(false);

  static const routePath = '/resetPassword';
  static const deepLink = 'degloorone://degloorone.com$routePath';

  static String redirectTo() {
    if (kIsWeb) {
      return '${Uri.base.origin}$routePath';
    }
    return deepLink;
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
