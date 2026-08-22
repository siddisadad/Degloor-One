import 'dart:async';

import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/components/social_button/social_button_widget.dart';
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
    if (SupabaseConnection.shouldSkipAuthRequest) {
      _serverWarning = SupabaseConnection.unreachableMessage;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _probeServer());
    }
  }

  Future<void> _probeServer() async {
    if (SupabaseConnection.shouldSkipAuthRequest) return;
    try {
      await SupaFlow.client
          .from('users')
          .select('id')
          .limit(1)
          .timeout(const Duration(seconds: 4));
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                // Logo Section
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: Colors.black.withValues(alpha: 0.1),
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'DEGLOOR ONE',
                      style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Everything Local. One App.',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Inter',
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
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
                          if (_serverWarning != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .error
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).error,
                                ),
                              ),
                              child: Text(
                                _serverWarning!,
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      color: FlutterFlowTheme.of(context).error,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
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
                              textStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FFButtonWidget(
                            text: 'Continue with Phone',
                            onPressed: _isLoading
                                ? null
                                : () => context.pushNamed('PhoneAuth'),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 54,
                              color: Colors.transparent,
                              textStyle: TextStyle(
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // OR Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: FlutterFlowTheme.of(context).alternate)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text('OR', style: FlutterFlowTheme.of(context).labelSmall),
                              ),
                              Expanded(child: Divider(color: FlutterFlowTheme.of(context).alternate)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Social Buttons
                          Row(
                            children: [
                              Expanded(
                                child: wrapWithModel(
                                  model: _model.socialButtonModel1,
                                  updateCallback: () => setState(() {}),
                                  child: SocialButtonWidget(
                                    icon: 'https://cdn.simpleicons.org/google/1a1a1a.svg',
                                    label: 'Google',
                                    onTap: () async {
                                      if (_isLoading) return;
                                      setState(() => _isLoading = true);
                                      try {
                                        final user = await authManager
                                            .signInWithGoogle(context);
                                        if (!context.mounted) return;
                                        if (user != null) {
                                          context.goNamed('_initialize');
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() => _isLoading = false);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: wrapWithModel(
                                  model: _model.socialButtonModel2,
                                  updateCallback: () => setState(() {}),
                                  child: SocialButtonWidget(
                                    icon: 'https://cdn.simpleicons.org/apple/1a1a1a.svg',
                                    label: 'Apple',
                                    onTap: () async {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Apple Sign-In coming soon!'))
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
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
                          Text('Don\'t have an account? ', style: FlutterFlowTheme.of(context).bodyMedium),
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
    );
  }

  Widget _buildLang(String label, String code) {
    final isSelected = FFAppState.instance.locale == code;
    return InkWell(
      onTap: () => setState(() => FFAppState.instance.locale = code),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).secondaryText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        context.goNamed('_initialize');
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
        context.goNamed('_initialize');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
