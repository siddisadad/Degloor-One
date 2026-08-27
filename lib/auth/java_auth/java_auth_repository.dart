import 'dart:async';
import 'package:flutter/material.dart';
import 'package:degloor_one/auth/auth_repository.dart';
import 'package:degloor_one/auth/base_auth_user_provider.dart';
import 'package:degloor_one/auth/java_auth_user.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/auth_api.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';

class JavaAuthRepository implements AuthRepository {
  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await AuthApi.login(email: email, password: password);
      return _handleTokenResponse(response);
    } catch (e) {
      if (context.mounted) {
        _showError(context, e);
      }
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await AuthApi.register(email: email, password: password);
      return _handleTokenResponse(response);
    } catch (e) {
      if (context.mounted) {
        _showError(context, e);
      }
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) async {
    if (context.mounted) {
      _showError(context, Exception('Google sign-in is not available yet.'));
    }
    return null;
  }

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) async {
    if (context.mounted) {
      _showError(context, Exception('Apple sign-in is not available yet.'));
    }
    return null;
  }

  @override
  Future<void> beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    if (context.mounted) {
      _showError(context, Exception('Phone sign-in is not available yet.'));
    }
  }

  @override
  Future<BaseAuthUser?> verifySmsCode({
    required BuildContext context,
    required String smsCode,
    String? phoneNumber,
  }) async {
    if (context.mounted) {
      _showError(context, Exception('Phone sign-in is not available yet.'));
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await AuthApi.logout();
    final signedOut = JavaAuthUser.signedOut();
    updateAuthUser(signedOut);
    updateJwtToken(null);
    AppStateNotifier.instance.update(signedOut);
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
    // Implement Java user deletion if available
  }

  @override
  Future<void> updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    // Implement Java email update if available
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required BuildContext context,
    String? redirectTo,
  }) async {
    // Implement Java password reset if available
    return false;
  }

  @override
  Future<void> updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    // Implement Java password update if available
  }

  @override
  Future<void> refreshUser() async {
    await currentUser?.refreshUser();
  }

  BaseAuthUser _handleTokenResponse(Map<String, dynamic> response) {
    final user = JavaAuthUser.fromTokenResponse(response);
    updateAuthUser(user);
    updateJwtToken(JavaApiClient.instance.accessToken);
    AppStateNotifier.instance.update(user);
    return user;
  }

  void _showError(BuildContext context, Object error) {
    String message = 'An unexpected error occurred';
    if (error is JavaApiException) {
      message = error.message;
    } else {
      final raw = error.toString();
      message = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message')),
    );
  }
}
