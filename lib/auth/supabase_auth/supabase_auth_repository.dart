import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'package:degloor_one/auth/java_auth_user.dart';
import 'package:degloor_one/auth/auth_repository.dart';
import 'package:degloor_one/auth/supabase_auth/supabase_user_provider.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/shared/user_profile_draft.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'email_auth.dart';
import 'phone_auth.dart';

class SupabaseAuthRepository implements AuthRepository {
  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    if (!SupabaseConnection.guard(context)) return null;
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
  ) async {
    if (!SupabaseConnection.guard(context)) return null;
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
        clientId: kIsWeb ? null : null,
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

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
    } catch (e) {
      SupabaseConnection.log(e, context: 'Google sign-in');
      if (context.mounted) {
        SupabaseConnection.showSnackBar(context, e);
      }
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) async {
    if (!SupabaseConnection.guard(context)) return null;
    try {
      final rawNonce = SupaFlow.client.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException(
          'Could not find ID Token from Apple Credential.',
        );
      }

      if (!context.mounted) return null;
      return await _signInOrCreateAccount(
        context,
        () => SupaFlow.client.auth
            // ignore: experimental_member_use
            .signInWithIdToken(
              provider: OAuthProvider.apple,
              idToken: idToken,
              nonce: rawNonce,
            )
            .then((res) => res.user),
      );
    } catch (e) {
      if (e is SignInWithAppleAuthorizationException &&
          e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      SupabaseConnection.log(e, context: 'Apple sign-in');
      if (context.mounted) {
        SupabaseConnection.showSnackBar(context, e);
      }
      return null;
    }
  }

  @override
  Future<void> beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    if (!SupabaseConnection.guard(context)) return;
    try {
      await phoneSignInFunc(phoneNumber);
      if (context.mounted) {
        onCodeSent(context);
      }
    } catch (e) {
      SupabaseConnection.log(e, context: 'Phone OTP send');
      if (context.mounted) {
        SupabaseConnection.showSnackBar(context, e);
      }
    }
  }

  @override
  Future<BaseAuthUser?> verifySmsCode({
    required BuildContext context,
    required String smsCode,
    String? phoneNumber,
  }) async {
    if (!SupabaseConnection.guard(context)) return null;
    if (phoneNumber == null) {
      throw ArgumentError('phoneNumber is required for Supabase verification.');
    }
    return _signInOrCreateAccount(
      context,
      () => phoneVerifyCodeFunc(
        phoneNumber: phoneNumber,
        smsCode: smsCode,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    final signedOut = JavaAuthUser.signedOut();
    updateAuthUser(signedOut);
    updateJwtToken(null);
    if (AppStateNotifier.instance.user?.loggedIn ?? true) {
      AppStateNotifier.instance.update(signedOut);
    }
    try {
      await SupaFlow.client.auth.signOut();
    } catch (_) {
      // Supabase not initialized (tests) or already signed out.
    }
  }

  @override
  Future<void> signOutToLogin(BuildContext context) async {
    final router = GoRouter.of(context);
    router.prepareAuthEvent();
    await signOut();
    router.goNamed('Authentication');
  }

  @override
  Future<void> deleteUser(BuildContext context) async {
    try {
      await currentUser?.delete();
    } catch (e) {
      if (context.mounted) {
        SupabaseConnection.showSnackBar(context, e);
      }
    }
  }

  @override
  Future<void> updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await SupaFlow.client.auth.updateUser(UserAttributes(email: email));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email change confirmation email sent')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SupabaseConnection.showSnackBar(context, e);
      }
    }
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
      return true;
    } catch (e) {
      if (context.mounted) {
        SupabaseConnection.showSnackBar(context, e);
      }
      return false;
    }
  }

  @override
  Future<void> updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      await SupaFlow.client.auth
          .updateUser(UserAttributes(password: newPassword));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SupabaseConnection.showSnackBar(context, e);
      }
    }
  }

  @override
  Future<void> refreshUser() async {
    await currentUser?.refreshUser();
  }

  Future<BaseAuthUser?> _handleAuthUser(User? user) async {
    if (user == null) return null;

    final profile = await UserService.instance
        .ensureOnSignIn(
          userId: user.id,
          draft: UserProfileDraft.fromSignIn(
            email: user.email,
            phone: user.phone,
            fullName: user.userMetadata?['full_name'] as String?,
            avatarUrl: user.userMetadata?['avatar_url'] as String?,
          ),
        )
        .timeout(const Duration(seconds: 10));

    final authUser = DegloorOneSupabaseUser(user, profile.role);
    updateAuthUser(authUser);
    AppStateNotifier.instance.update(authUser);
    return authUser;
  }

  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<User?> Function() signInFunc,
  ) async {
    try {
      final user = await signInFunc();
      if (!context.mounted) return null;
      return await _handleAuthUser(user);
    } catch (e) {
      if (context.mounted) {
        SupabaseConnection.showSnackBar(
          context,
          e,
          authMessage: e is AuthException ? e.message : null,
        );
      }
      return null;
    }
  }
}
