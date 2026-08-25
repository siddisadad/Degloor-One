import 'dart:async';

import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/core/app_flags.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/components/auth_page_header.dart';
import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/components/social_button/social_button_widget.dart';
import 'package:degloor_one/components/supabase_unreachable_banner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:degloor_one/app_state.dart';
import 'package:flutter/material.dart';
import 'authentication_model.dart';
export 'authentication_model.dart';

class AuthenticationWidget extends StatefulWidget {
  const AuthenticationWidget({super.key});

  static String routeName = 'Authentication';
  static String routePath = '/authentication';

  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  late AuthenticationModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String? _serverWarning;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthenticationModel());
    if (!SupabaseConnection.shouldSkipAuthRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _probeServer());
    }
  }

  Future<void> _probeServer() async {
    if (SupabaseConnection.shouldSkipAuthRequest) return;
    try {
      await UserService.instance.probeReachable();
    } catch (e) {
      if (!mounted) return;
      if (SupabaseConnection.looksUnreachable(e) || e is TimeoutException) {
        setState(() => _serverWarning = SupabaseConnection.unreachableMessage);
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FlutterFlowTheme.of(context).primary,
                FlutterFlowTheme.of(context).primaryBackground
              ],
              stops: const [0.0, 0.4],
              begin: const AlignmentDirectional(0.0, -1.0),
              end: const AlignmentDirectional(0, 1.0),
            ),
          ),
          child: AuthPageScaffold(
            child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                BrandMark(
                  size: 168,
                  showWordmark: true,
                  wordmarkColor: Colors.white,
                  taglineColor: Colors.white.withValues(alpha: 0.82),
                ),
                const SizedBox(height: 40),
                // Login Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 30,
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(0, 15),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _roleTabs(),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome back',
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _model.isBusinessOwner
                                ? 'Sign in to manage your Degloor shop.'
                                : 'Sign in to shop local in Degloor.',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                          ),
                          const SizedBox(height: 20),
                          SupabaseUnreachableBanner(message: _serverWarning),
                          // Inputs
                          wrapWithModel(
                            model: _model.textFieldModel1,
                            updateCallback: () => setState(() {}),
                            child: const TextFieldWidget(
                              label: 'Email or Phone',
                              labelPresent: true,
                              hint: 'Enter your credentials',
                              leadingIcon: Icon(Icons.person_outline_rounded),
                              leadingIconPresent: true,
                              variant: 'outlined',
                            ),
                          ),
                          const SizedBox(height: 20),
                          wrapWithModel(
                            model: _model.textFieldModel2,
                            updateCallback: () => setState(() {}),
                            child: const TextFieldWidget(
                              label: 'Password',
                              labelPresent: true,
                              hint: 'Enter your password',
                              leadingIcon: Icon(Icons.lock_outline_rounded),
                              leadingIconPresent: true,
                              trailingIconPresent: true,
                              variant: 'outlined',
                              obscureText: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                final email = _model.textFieldModel1
                                        .inputTextController?.text
                                        .trim() ??
                                    '';
                                context.pushNamed(
                                  'ForgotPassword',
                                  queryParameters: {
                                    if (email.contains('@')) 'email': email,
                                  },
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Sign In Button
                          FFButtonWidget(
                            text: 'Sign In',
                            onPressed: _isLoading ? null : _handleSignIn,
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 54,
                              color: FlutterFlowTheme.of(context).primary,
                              elevation: 2,
                              textStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (kBypassAuth || _serverWarning != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: FFButtonWidget(
                                text: 'Continue as Guest',
                                onPressed: () {
                                  installGuestSession();
                                  updateAuthUser(currentUser!);
                                  context.goNamed(_guestDestination);
                                },
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 50,
                                  color: Colors.transparent,
                                  textStyle: TextStyle(
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          wrapWithModel(
                            model: _model.socialButtonModel1,
                            updateCallback: () => setState(() {}),
                            child: SocialButtonWidget(
                              icon: const FaIcon(
                                FontAwesomeIcons.google,
                                size: 18,
                              ),
                              label: 'Continue with Google',
                              onTap: () async {
                                if (_isLoading) return;
                                setState(() => _isLoading = true);
                                try {
                                  final user = await authManager
                                      .signInWithGoogle(context);
                                  if (!context.mounted) return;
                                  if (user != null) {
                                    await _continueAfterAuth();
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom Section
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            _model.isBusinessOwner
                                ? 'Don\'t have a shop yet? '
                                : 'Don\'t have an account? ',
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          ),
                          InkWell(
                            onTap: _isLoading ? null : _handleCreateAccount,
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                color: _isLoading
                                    ? FlutterFlowTheme.of(context).secondaryText
                                    : FlutterFlowTheme.of(context).primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Language Selector
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildLang('English', 'en'),
                          _buildDot(),
                          _buildLang('मराठी', 'mr'),
                          _buildDot(),
                          _buildLang('हिंदी', 'hi'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Deshmukh Technologies • Pilot v1.0',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                          fontFamily: 'Inter',
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  String get _guestDestination =>
      _model.isBusinessOwner ? 'BusinessRegistration' : 'CustomerHome';

  Widget _roleTabs() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _roleTab(
            key: const ValueKey('login-tab-customer'),
            label: 'Customer',
            selected: !_model.isBusinessOwner,
            onTap: () => setState(() => _model.isBusinessOwner = false),
          ),
          _roleTab(
            key: const ValueKey('login-tab-business'),
            label: 'Business',
            selected: _model.isBusinessOwner,
            onTap: () => setState(() => _model.isBusinessOwner = true),
          ),
        ],
      ),
    );
  }

  Widget _roleTab({
    required Key key,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? theme.secondaryBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.06),
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? theme.primary : theme.secondaryText,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLang(String label, String code) {
    final theme = FlutterFlowTheme.of(context);
    final isSelected = FFAppState.instance.locale == code;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => FFAppState.instance.locale = code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? theme.primary : theme.alternate,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.primary : theme.secondaryText,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDot() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    width: 4, height: 4,
    decoration: BoxDecoration(color: FlutterFlowTheme.of(context).alternate, shape: BoxShape.circle)
  );

  Future<void> _handleSignIn() async {
    final email = _model.textFieldModel1.inputTextController!.text;
    final password = _model.textFieldModel2.inputTextController!.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter credentials')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await authManager.signInWithEmail(context, email, password);
      if (!mounted) return;
      if (user != null) {
        await _continueAfterAuth();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCreateAccount() async {
    final email = _model.textFieldModel1.inputTextController!.text;
    final password = _model.textFieldModel2.inputTextController!.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter email and password first')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await authManager.createAccountWithEmail(
          context, email, password);
      if (!mounted) return;
      if (user != null) {
        await _continueAfterAuth();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueAfterAuth() async {
    if (!_model.isBusinessOwner) {
      context.goNamed('_initialize');
      return;
    }
    if (kBypassAuth) {
      context.goNamed('BusinessRegistration');
      return;
    }
    final userId = currentUserUid;
    if (userId.isEmpty) {
      context.goNamed('BusinessRegistration');
      return;
    }
    try {
      final shops = await DiscoveryService.instance
          .ownedBy(userId)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      context.goNamed(
        shops.isEmpty ? 'BusinessRegistration' : 'BusinessDashboard',
      );
    } catch (_) {
      if (!mounted) return;
      context.goNamed('BusinessRegistration');
    }
  }
}
