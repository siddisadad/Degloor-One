import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/components/auth_page_header.dart';
import 'package:degloor_one/components/social_button/social_button_widget.dart';
import 'package:degloor_one/components/supabase_unreachable_banner.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/core/app_flags.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signup_model.dart';
export 'signup_model.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({
    super.key,
    this.role,
  });

  final String? role;

  static String routeName = 'SignUp';
  static String routePath = '/signUp';

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  late SignUpModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignUpModel());
    _model.isBusinessOwner = (widget.role ?? '').trim() == 'business';
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          buttonSize: 60,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 30,
          ),
          onPressed: () => context.safePop(),
        ),
      ),
      body: SafeArea(
        child: AuthPageScaffold(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthPageHeader(
                  title: 'Sign up',
                  subtitle: _model.isBusinessOwner
                      ? 'Create an account to list your Degloor shop.'
                      : 'Create an account to shop local in Degloor.',
                ),
                const SizedBox(height: 24),
                _roleTabs(),
                const SizedBox(height: 20),
                const SupabaseUnreachableBanner(),
                wrapWithModel(
                  model: _model.emailModel,
                  updateCallback: () => setState(() {}),
                  child: const TextFieldWidget(
                    label: 'Email',
                    labelPresent: true,
                    hint: 'you@example.com',
                    leadingIcon: Icon(Icons.mail_outline_rounded),
                    leadingIconPresent: true,
                    variant: 'outlined',
                  ),
                ),
                const SizedBox(height: 16),
                wrapWithModel(
                  model: _model.passwordModel,
                  updateCallback: () => setState(() {}),
                  child: const TextFieldWidget(
                    label: 'Password',
                    labelPresent: true,
                    hint: 'At least 6 characters',
                    leadingIcon: Icon(Icons.lock_outline_rounded),
                    leadingIconPresent: true,
                    trailingIconPresent: true,
                    variant: 'outlined',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 16),
                wrapWithModel(
                  model: _model.confirmModel,
                  updateCallback: () => setState(() {}),
                  child: const TextFieldWidget(
                    label: 'Confirm password',
                    labelPresent: true,
                    hint: 'Re-enter your password',
                    leadingIcon: Icon(Icons.lock_outline_rounded),
                    leadingIconPresent: true,
                    trailingIconPresent: true,
                    variant: 'outlined',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 32),
                FFButtonWidget(
                  text: _isLoading ? 'Signing up...' : 'Sign up',
                  onPressed: _isLoading ? null : _handleSignUp,
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 54,
                    color: FlutterFlowTheme.of(context).primary,
                    elevation: 2,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 16),
                FFButtonWidget(
                  text: 'Continue with Phone',
                  onPressed:
                      _isLoading ? null : () => context.pushNamed('PhoneAuth'),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 54,
                    color: Colors.transparent,
                    textStyle: TextStyle(
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: FlutterFlowTheme.of(context).labelSmall,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                wrapWithModel(
                  model: _model.socialButtonModel,
                  updateCallback: () => setState(() {}),
                  child: SocialButtonWidget(
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      size: 18,
                    ),
                    label: 'Continue with Google',
                    onTap: () => _continueWithProvider(
                      () => authManager.signInWithGoogle(context),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                wrapWithModel(
                  model: _model.appleButtonModel,
                  updateCallback: () => setState(() {}),
                  child: SocialButtonWidget(
                    icon: const FaIcon(
                      FontAwesomeIcons.apple,
                      size: 20,
                    ),
                    label: 'Continue with Apple',
                    onTap: () => _continueWithProvider(
                      () => authManager.signInWithApple(context),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      InkWell(
                        onTap: () => context.goNamed('Authentication'),
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: FlutterFlowTheme.of(context).primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
            key: const ValueKey('signup-tab-customer'),
            label: 'Customer',
            selected: !_model.isBusinessOwner,
            onTap: () => setState(() => _model.isBusinessOwner = false),
          ),
          _roleTab(
            key: const ValueKey('signup-tab-business'),
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
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
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
      ),
    );
  }

  Future<void> _handleSignUp() async {
    final error = _model.validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await authManager.createAccountWithEmail(
        context,
        _model.email,
        _model.password,
      );
      if (!mounted) return;
      if (user != null) {
        await _continueAfterAuth();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueWithProvider(
    Future<Object?> Function() signIn,
  ) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final user = await signIn();
      if (!mounted) return;
      if (user != null) {
        await _continueAfterAuth();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueAfterAuth() async {
    final route = await _model.routeAfterAuth(bypassAuth: kBypassAuth);
    if (!mounted) return;
    context.goNamed(route);
  }
}
