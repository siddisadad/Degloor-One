import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const BrandMark(size: 56, showWordmark: true, compact: true),
                const SizedBox(height: 20),
                Text(
                  'Welcome to DEGLOOR ONE',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to continue.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                  text: 'Send OTP',
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
    );
  }

  Future<void> _handleSendOtp() async {
    String phone = _model.textController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    // Normalize phone number: remove all non-digit characters except '+'
    // and ensure it starts with '+'
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!phone.startsWith('+')) {
      // Default to +91 if no country code provided and it's a 10-digit number
      if (phone.length == 10) {
        phone = '+91$phone';
      } else {
        // Just prepend + if it's missing but might have country code (e.g. 91...)
        phone = '+$phone';
      }
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
