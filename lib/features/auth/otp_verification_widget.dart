import 'package:degloor_one/auth/auth_send_rate_limit.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/components/auth_page_header.dart';
import 'package:degloor_one/components/supabase_unreachable_banner.dart';
import 'package:degloor_one/shared/otp_copy.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:flutter/material.dart';
import 'otp_verification_model.dart';
export 'otp_verification_model.dart';

class OtpVerificationWidget extends StatefulWidget {
  const OtpVerificationWidget({
    super.key,
    required this.phone,
  });

  final String phone;

  static String routeName = 'OtpVerification';
  static String routePath = '/otpVerification';

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  late OtpVerificationModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final AuthResendCooldown _resendCooldown;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OtpVerificationModel());
    _resendCooldown = AuthResendCooldown(
      onTick: () {
        if (mounted) setState(() {});
      },
    );
    _resendCooldown.start(notify: false);
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: AuthPageScaffold(
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthPageHeader(
                  title: 'Verification Code',
                  subtitle: OtpCopy.smsSentTo(widget.phone),
                ),
                const SizedBox(height: 8),
                Text(
                  OtpCopy.smsHint,
                  style: FlutterFlowTheme.of(context).labelSmall.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
                const SizedBox(height: 24),
                const SupabaseUnreachableBanner(),
                TextFormField(
                  controller: _model.textController,
                  focusNode: _model.textFieldFocusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '000000',
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
                  ),
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8.0,
                      ),
                ),
                const SizedBox(height: 32),
                FFButtonWidget(
                  onPressed: _isLoading ||
                          SupabaseConnection.shouldSkipAuthRequest
                      ? null
                      : _handleVerify,
                  text: _isLoading ? 'Verifying...' : 'Verify Code',
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
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _isLoading ||
                            _resendCooldown.isActive ||
                            SupabaseConnection.shouldSkipAuthRequest
                        ? null
                        : _handleResend,
                    child: Text(
                      _resendCooldown.isActive
                          ? 'Resend code in ${_resendCooldown.remainingSeconds}s'
                          : 'Resend Code',
                      style: TextStyle(
                        color: FlutterFlowTheme.of(context).primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

  Future<void> _handleVerify() async {
    final code = _model.textController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await authManager.verifySmsCode(
        context: context,
        phoneNumber: widget.phone,
        smsCode: code,
      );
      if (user != null && mounted) {
        if ((user.displayName ?? '').isEmpty) {
          context.goNamed(
            'UserProfileReports',
            queryParameters: {'editProfile': 'true'},
          );
        } else {
          context.goNamed('_initialize');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isLoading = true);
    try {
      await authManager.beginPhoneAuth(
        context: context,
        phoneNumber: widget.phone,
        onCodeSent: (_) {
          if (!mounted) return;
          _resendCooldown.start();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code resent successfully')),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
