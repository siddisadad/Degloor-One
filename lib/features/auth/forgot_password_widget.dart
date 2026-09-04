import 'package:degloor_one/auth/auth_send_rate_limit.dart';
import 'package:degloor_one/auth/password_recovery.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/components/auth_page_header.dart';
import 'package:degloor_one/components/supabase_unreachable_banner.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'forgot_password_model.dart';
export 'forgot_password_model.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({
    super.key,
    this.email,
  });

  final String? email;

  static String routeName = 'ForgotPassword';
  static String routePath = '/forgotPassword';

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  late ForgotPasswordModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final AuthResendCooldown _resendCooldown;
  bool _isLoading = false;
  bool _emailSent = false;

  bool get _authBlocked =>
      SupabaseConnection.shouldSkipAuthRequest && !JavaApiConfig.enabled;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ForgotPasswordModel());
    _resendCooldown = AuthResendCooldown(
      onTick: () {
        if (mounted) setState(() {});
      },
    );
    final initialEmail = widget.email?.trim() ?? '';
    if (initialEmail.isNotEmpty) {
      _model.emailController.text = initialEmail;
    }
  }

  @override
  void dispose() {
    _resendCooldown.dispose();
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _emailSent ? _buildSentState() : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthPageHeader(
          title: 'Forgot password',
          subtitle:
              'Enter the email on your account. We will send a link to set a new password.',
        ),
        const SizedBox(height: 24),
        const SupabaseUnreachableBanner(),
        TextFormField(
          controller: _model.emailController,
          focusNode: _model.emailFocusNode,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'you@example.com',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).alternate,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
          style: FlutterFlowTheme.of(context).bodyLarge,
        ),
        const SizedBox(height: 32),
        FFButtonWidget(
          onPressed: _isLoading || _authBlocked ? null : _handleSendReset,
          text: _isLoading ? 'Sending...' : 'Send reset link',
          options: FFButtonOptions(
            width: double.infinity,
            height: 54,
            color: FlutterFlowTheme.of(context).primary,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.mark_email_read_outlined,
          size: 56,
          color: FlutterFlowTheme.of(context).primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Check your email',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'If an account exists for ${_model.emailController.text.trim()}, you will receive a reset link shortly. Open it on this device to choose a new password.',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
        const SizedBox(height: 32),
        FFButtonWidget(
          onPressed: () => context.goNamed('Authentication'),
          text: 'Back to sign in',
          options: FFButtonOptions(
            width: double.infinity,
            height: 54,
            color: FlutterFlowTheme.of(context).primary,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        FFButtonWidget(
          onPressed: _isLoading ||
                  _resendCooldown.isActive ||
                  _authBlocked
              ? null
              : _handleSendReset,
          text: _resendCooldown.isActive
              ? 'Resend in ${_resendCooldown.remainingSeconds}s'
              : 'Resend link',
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
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendReset() async {
    final email = _model.emailController.text.trim();
    if (!PasswordRecovery.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final sent = await authManager.resetPassword(
        email: email,
        context: context,
        redirectTo: PasswordRecovery.redirectTo(),
      );
      if (mounted && sent) {
        if (PasswordRecovery.pending.value &&
            PasswordRecovery.resetToken != null) {
          context.goNamed('ResetPassword');
          return;
        }
        setState(() => _emailSent = true);
        _resendCooldown.start();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
