import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:degloor_one/auth/auth_manager.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'email_auth.dart';
import 'phone_auth.dart';

import 'supabase_user_provider.dart';

export 'package:degloor_one/auth/base_auth_user_provider.dart';

class SupabaseAuthManager extends AuthManager
    with EmailSignInManager, GoogleSignInManager, PhoneSignInManager {
  @override
  Future signOut() {
    return SupaFlow.client.auth.signOut();
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      if (!loggedIn) {
        print('Error: delete user attempted with no logged in user!');
        return;
      }
      await currentUser?.delete();
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update email attempted with no logged in user!');
        return;
      }
      await currentUser?.updateEmail(email);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email change confirmation email sent')),
    );
  }

  Future updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update password attempted with no logged in user!');
        return;
      }
      await currentUser?.updatePassword(newPassword);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password updated successfully')),
    );
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
    String? redirectTo,
  }) async {
    try {
      await SupaFlow.client.auth
          .resetPasswordForEmail(email, redirectTo: redirectTo);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return null;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent')),
    );
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailSignInFunc(email, password),
      );

  Future<BaseAuthUser?> signInWithEmailWithRole(
    BuildContext context,
    String email,
    String password,
    String role,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailSignInFunc(email, password),
        role: role,
      );

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailCreateAccountFunc(email, password),
      );

  Future<BaseAuthUser?> createAccountWithEmailWithRole(
    BuildContext context,
    String email,
    String password,
    String role,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailCreateAccountFunc(email, password),
        role: role,
      );

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) async {
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
        throw AuthException('No ID Token found.');
      }

      return _signInOrCreateAccount(
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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return null;
    }
  }

  Future<BaseAuthUser?> signInWithGoogleWithRole(
    BuildContext context,
    String role,
  ) async {
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
        throw AuthException('No ID Token found.');
      }

      return _signInOrCreateAccount(
        context,
        () => SupaFlow.client.auth
            // ignore: experimental_member_use
            .signInWithIdToken(
              provider: OAuthProvider.google,
              idToken: idToken,
              accessToken: accessToken,
            )
            .then((res) => res.user),
        role: role,
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return null;
    }
  }

  @override
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    try {
      await phoneSignInFunc(phoneNumber);
      onCodeSent(context);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
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
    String? role,
  }) =>
      _signInOrCreateAccount(
        context,
        () => phoneVerifyCodeFunc(
          phoneNumber: phoneNumber,
          smsCode: smsCode,
        ),
        role: role,
      );

  /// Tries to sign in or create an account using Supabase Auth.
  /// Returns the User object if sign in was successful.
  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<User?> Function() signInFunc, {
    String? role,
  }) async {
    try {
      final user = await signInFunc();
      if (user == null) return null;

      // Ensure user record exists in the public.users table and get their role
      final rows = await UsersTable().queryRows(
        queryFn: (q) => q.eq('id', user.id),
      );

      String? actualRole = role;
      if (rows.isEmpty) {
        actualRole ??= 'customer';
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
        // If the user exists but has no role, and we provided one, update it.
        if (actualRole == null && role != null) {
          actualRole = role;
          await UsersTable().update(
            data: {'role': actualRole},
            matchingRows: (q) => q.eq('id', user.id),
          );
        }
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
      print('Auth error: ${e.message}');
      final errorMsg = e.message.contains('User already registered')
          ? 'Error: The email is already in use by a different account'
          : 'Error: ${e.message}';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      return null;
    } catch (e) {
      print('Unexpected error during auth: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: An unexpected error occurred. Please try again.')),
      );
      return null;
    }
  }
}
