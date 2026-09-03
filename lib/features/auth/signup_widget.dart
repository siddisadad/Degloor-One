import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/components/auth_page_header.dart';
import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/components/supabase_unreachable_banner.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/core/app_flags.dart';
import 'package:degloor_one/features/profile/profile_info_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FlutterFlowTheme.of(context).primary,
              FlutterFlowTheme.of(context).primaryBackground,
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
                const SizedBox(height: 20),
                // Top Portion: DEGLOOR ONE Branding & Role Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const BrandMark(
                        size: 48,
                        showWordmark: true,
                        wordmarkColor: Colors.white,
                        taglineColor: Colors.white70,
                        compact: true,
                      ),
                      const SizedBox(height: 16),
                      _roleTabs(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Sign Up Form Card
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
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign up',
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
                                ? 'Create an account to list your Degloor shop.'
                                : 'Create an account to shop local in Degloor.',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                          ),
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => context.pushNamed(
                                ProfileInfoWidget.termsRouteName),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              'Terms',
                              style: TextStyle(
                                fontSize: 12,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.pushNamed(
                                ProfileInfoWidget.privacyRouteName),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              'Privacy',
                              style: TextStyle(
                                fontSize: 12,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Deshmukh Technologies • Pilot v1.0',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context)
                                  .secondaryText,
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

  Widget _roleTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
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
                color: selected ? theme.primary : Colors.white,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
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
      width: 4,
      height: 4,
      decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          shape: BoxShape.circle));

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
      if (!mounted || user == null) return;
      await _continueAfterAuth();
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
