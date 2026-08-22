import 'package:degloor_one/auth/phone_number.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/components/auth_page_header.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/shared/otp_copy.dart';
import 'package:degloor_one/components/supabase_unreachable_banner.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'phone_auth_model.dart';
export 'phone_auth_model.dart';

class PhoneAuthWidget extends StatefulWidget {
  const PhoneAuthWidget({super.key});

  static String routeName = 'PhoneAuth';
  static String routePath = '/phoneAuth';

  @override
  State<PhoneAuthWidget> createState() => _PhoneAuthWidgetState();
}

class _PhoneAuthWidgetState extends State<PhoneAuthWidget> {
  late PhoneAuthModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneAuthModel());
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
                const AuthPageHeader(
                  title: 'Welcome to DEGLOOR ONE',
                  subtitle: OtpCopy.phoneSubtitle,
                ),
                const SizedBox(height: 24),
                const SupabaseUnreachableBanner(),
                TextFormField(
                  controller: _model.textController,
                  focusNode: _model.textFieldFocusNode,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+91 12345 67890',
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
                      Icons.phone_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                  style: FlutterFlowTheme.of(context).bodyLarge,
                ),
                const SizedBox(height: 32),
                FFButtonWidget(
                  onPressed: _isLoading ||
                          SupabaseConnection.shouldSkipAuthRequest
                      ? null
                      : _handleSendOtp,
                  text: _isLoading ? 'Sending...' : 'Send OTP',
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
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendOtp() async {
    final phone = PhoneNumber.normalize(_model.textController.text);
    if (phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await authManager.beginPhoneAuth(
        context: context,
        phoneNumber: phone,
        onCodeSent: (context) {
          context.pushNamed(
            'OtpVerification',
            queryParameters: {
              'phone': phone,
            },
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
