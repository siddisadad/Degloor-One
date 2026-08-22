import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:degloor_one/auth/auth_manager.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'email_auth.dart';
import 'phone_auth.dart';

import 'supabase_user_provider.dart';

export 'package:degloor_one/auth/base_auth_user_provider.dart';

class SupabaseAuthManager extends AuthManager
    with EmailSignInManager, GoogleSignInManager, PhoneSignInManager {
  @override
  Future signOut() {
    if (SupabaseConnection.shouldSkipAuthRequest) return Future.value();
    return SupaFlow.client.auth.signOut();
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      if (!loggedIn) {
        AppLogger.error('delete user attempted with no logged in user!');
        return;
      }
      await currentUser?.delete();
    } on AuthException catch (e) {
      SupabaseConnection.log(e, context: 'delete user');
      if (!context.mounted) return;
      SupabaseConnection.showSnackBar(context, e, authMessage: e.message);
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        AppLogger.error('update email attempted with no logged in user!');
        return;
      }
      await currentUser?.updateEmail(email);
    } on AuthException catch (e) {
      SupabaseConnection.log(e, context: 'update email');
      if (!context.mounted) return;
      SupabaseConnection.showSnackBar(context, e, authMessage: e.message);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email change confirmation email sent')),
    );
  }

  Future<bool> updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        AppLogger.error('update password attempted with no logged in user!');
        return false;
      }
      await currentUser?.updatePassword(newPassword);
    } on AuthException catch (e) {
      SupabaseConnection.log(e, context: 'update password');
      if (!context.mounted) return false;
      SupabaseConnection.showSnackBar(context, e, authMessage: e.message);
      return false;
    }
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully')),
    );
    return true;
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required BuildContext context,
    String? redirectTo,
  }) async {
    if (!SupabaseConnection.guard(context)) return false;
    try {
      await SupaFlow.client.auth
          .resetPasswordForEmail(email, redirectTo: redirectTo);
    } on AuthException catch (e) {
      SupabaseConnection.log(e, context: 'reset password');
      if (!context.mounted) return false;
      SupabaseConnection.showSnackBar(context, e, authMessage: e.message);
      return false;
    } catch (e) {
      SupabaseConnection.log(e, context: 'reset password');
      if (!context.mounted) return false;
      SupabaseConnection.showSnackBar(context, e);
      return false;
    }
    if (!context.mounted) return false;
    return true;
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) {
    if (!SupabaseConnection.guard(context)) {
      return Future<BaseAuthUser?>.value();
    }
    return _signInOrCreateAccount(
      context,
      () => emailSignInFunc(email, password),
    );
  }

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) {
    if (!SupabaseConnection.guard(context)) {
      return Future<BaseAuthUser?>.value();
    }
    return _signInOrCreateAccount(
      context,
      () => emailCreateAccountFunc(email, password),
    );
  }

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) async {
    if (!SupabaseConnection.guard(context)) return null;
    try {
      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? null : null, // Set your Web Client ID here if not using meta tag
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthException('No ID Token found.');
      }

      if (!context.mounted) return null;
      return await _signInOrCreateAccount(
        context,
        () => SupaFlow.client.auth
            // ignore: experimental_member_use
            .signInWithIdToken(
              provider: OAuthProvider.google,
              idToken: idToken,
              accessToken: accessToken,
            )
            .then((res) => res.user),
      );
    } on AuthException catch (e) {
      SupabaseConnection.log(e, context: 'Google sign-in');
      if (!context.mounted) return null;
      SupabaseConnection.showSnackBar(context, e, authMessage: e.message);
      return null;
    } catch (e) {
      SupabaseConnection.log(e, context: 'Google sign-in');
      if (!context.mounted) return null;
      SupabaseConnection.showSnackBar(context, e);
      return null;
    }
  }

  @override
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    if (!SupabaseConnection.guard(context)) return;
    try {
      await phoneSignInFunc(phoneNumber);
      if (!context.mounted) return;
      onCodeSent(context);
    } catch (e) {
      SupabaseConnection.log(e, context: 'beginPhoneAuth error');
      if (!context.mounted) return;
      SupabaseConnection.showSnackBar(context, e);
    }
  }

  @override
  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
  }) async {
    // Note: This requires the phone number. We assume the UI handles
    // the phone number and calls a specialized version or we store it.
    // For Supabase, we need the phone number to verify OTP.
    throw UnimplementedError(
        'Use verifySmsCodeWithPhoneNumber instead for Supabase.');
  }

  Future<BaseAuthUser?> verifySmsCodeWithPhoneNumber({
    required BuildContext context,
    required String phoneNumber,
    required String smsCode,
  }) {
    if (!SupabaseConnection.guard(context)) return Future.value();
    return _signInOrCreateAccount(
      context,
      () => phoneVerifyCodeFunc(
        phoneNumber: phoneNumber,
        smsCode: smsCode,
      ),
    );
  }

  /// Tries to sign in or create an account using Supabase Auth.
  /// Returns the User object if sign in was successful.
  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<User?> Function() signInFunc,
  ) async {
    try {
      final user = await signInFunc();
      if (user == null) return null;

      // Ensure user record exists in the public.users table and get their role
      // Added timeout to prevent infinite hang on slow networks
      final rows = await UsersTable().queryRows(
        queryFn: (q) => q.eq('id', user.id),
      ).timeout(const Duration(seconds: 10));

      String? actualRole;
      if (rows.isEmpty) {
        actualRole = 'customer';
        await UsersTable().insert({
          'id': user.id,
          'email': user.email,
          'phone_number': user.phone,
          'full_name': user.userMetadata?['full_name'],
          'avatar_url': user.userMetadata?['avatar_url'],
          'role': actualRole,
        });
      } else {
        actualRole = rows.first.role;
      }

      final authUser = DegloorOneSupabaseUser(user, actualRole);

      // Update currentUser here in case user info needs to be used immediately
      // after a user is signed in. This should be handled by the user stream,
      // but adding here too in case of a race condition where the user stream
      // doesn't assign the currentUser in time.
      if (authUser.uid != null && authUser.uid!.length > 10) {
        currentUser = authUser;
        AppStateNotifier.instance.update(authUser);
      }
      return authUser;
    } on AuthException catch (e) {
      SupabaseConnection.log(e, context: 'Auth error');
      if (!context.mounted) return null;
      SupabaseConnection.showSnackBar(context, e, authMessage: e.message);
      return null;
    } catch (e) {
      SupabaseConnection.log(e, context: 'Unexpected error during auth');
      if (SupabaseConnection.looksUnreachable(e)) {
        SupabaseConnection.showSnackBar(context, e);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: An unexpected error occurred. Please try again.',
            ),
          ),
        );
      }
      return null;
    }
  }
}
