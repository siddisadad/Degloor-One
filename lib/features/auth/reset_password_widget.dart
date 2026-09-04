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
import 'reset_password_model.dart';
export 'reset_password_model.dart';

class ResetPasswordWidget extends StatefulWidget {
  const ResetPasswordWidget({super.key});

  static String routeName = 'ResetPassword';
  static String routePath = PasswordRecovery.routePath;

  @override
  State<ResetPasswordWidget> createState() => _ResetPasswordWidgetState();
}

class _ResetPasswordWidgetState extends State<ResetPasswordWidget> {
  late ResetPasswordModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  bool get _authBlocked =>
      SupabaseConnection.shouldSkipAuthRequest && !JavaApiConfig.enabled;

  bool get _canSetPassword => PasswordRecovery.pending.value || loggedIn;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResetPasswordModel());
    PasswordRecovery.pending.addListener(_onRecoveryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final token = GoRouterState.of(context).uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        PasswordRecovery.beginWithToken(token);
      }
    });
  }

  void _onRecoveryChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    PasswordRecovery.pending.removeListener(_onRecoveryChanged);
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
            onPressed: () => context.goNamed('Authentication'),
          ),
        ),
        body: SafeArea(
          child: AuthPageScaffold(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _canSetPassword ? _buildForm() : _buildExpired(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpired() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthPageHeader(
          title: 'Link expired',
          subtitle:
              'This reset link is invalid or has already been used. Request a new one to continue.',
        ),
        const SizedBox(height: 32),
        FFButtonWidget(
          onPressed: () => context.goNamed('ForgotPassword'),
          text: 'Request a new link',
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

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthPageHeader(
            title: 'Set a new password',
            subtitle: 'Choose a password with at least 6 characters.',
          ),
          const SizedBox(height: 24),
          const SupabaseUnreachableBanner(),
          _passwordField(
            controller: _model.passwordController,
            focusNode: _model.passwordFocusNode,
            label: 'New password',
            obscure: _model.obscurePassword,
            onToggle: () => setState(
              () => _model.obscurePassword = !_model.obscurePassword,
            ),
          ),
          const SizedBox(height: 20),
          _passwordField(
            controller: _model.confirmController,
            focusNode: _model.confirmFocusNode,
            label: 'Confirm password',
            obscure: _model.obscureConfirm,
            onToggle: () => setState(
              () => _model.obscureConfirm = !_model.obscureConfirm,
            ),
          ),
          const SizedBox(height: 32),
          FFButtonWidget(
            onPressed: _isLoading || _authBlocked ? null : _handleSave,
            text: _isLoading ? 'Saving...' : 'Update password',
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
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      autofillHints: const [AutofillHints.newPassword],
      decoration: InputDecoration(
        labelText: label,
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
          Icons.lock_outline_rounded,
          color: FlutterFlowTheme.of(context).primary,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
      ),
      style: FlutterFlowTheme.of(context).bodyLarge,
    );
  }

  Future<void> _handleSave() async {
    final error = PasswordRecovery.validateNewPassword(
      _model.passwordController.text,
      _model.confirmController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await authManager.updatePassword(
        context: context,
        newPassword: _model.passwordController.text,
      );
      if (!mounted) return;
      PasswordRecovery.clear();
      context.goNamed('_initialize');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
