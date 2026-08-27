import 'package:flutter/material.dart';
import 'base_auth_user_provider.dart';

/// Unified interface for authentication operations across different backends.
abstract class AuthRepository {
  /// Sign in with email and password.
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  );

  /// Create a new account with email and password.
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  );

  /// Sign in using Google OAuth.
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context);

  /// Sign in using Apple OAuth.
  Future<BaseAuthUser?> signInWithApple(BuildContext context);

  /// Start phone authentication by sending an OTP.
  Future<void> beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  });

  /// Verify the SMS code for phone authentication.
  Future<BaseAuthUser?> verifySmsCode({
    required BuildContext context,
    required String smsCode,
    String? phoneNumber,
  });

  /// Sign out the current user.
  Future<void> signOut();

  /// Sign out and redirect to login screen.
  Future<void> signOutToLogin(BuildContext context);

  /// Delete the current user's account.
  Future<void> deleteUser(BuildContext context);

  /// Update the current user's email.
  Future<void> updateEmail({
    required String email,
    required BuildContext context,
  });

  /// Send a password reset email.
  Future<bool> resetPassword({
    required String email,
    required BuildContext context,
    String? redirectTo,
  });

  /// Update the current user's password.
  Future<void> updatePassword({
    required String newPassword,
    required BuildContext context,
  });

  /// Refresh the current user's session/data.
  Future<void> refreshUser();
}
