import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
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
  bool _isBusinessOwner = false;

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
          automaticallyImplyLeading: true,
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
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 40),
                // Role Toggle
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTab('Customer', !_isBusinessOwner, () {
                        setState(() => _isBusinessOwner = false);
                      }),
                      _buildTab('Owner', _isBusinessOwner, () {
                        setState(() => _isBusinessOwner = true);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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
                  onPressed: _isLoading ? null : _handleSendOtp,
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

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? FlutterFlowTheme.of(context).primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : FlutterFlowTheme.of(context).secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendOtp() async {
    final phone = _model.textController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
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
              'role': _isBusinessOwner ? 'business_owner' : 'customer',
            },
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
