import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:degloor_one/shared/otp_copy.dart';
import 'package:flutter/material.dart';
import 'order_success_model.dart';
export 'order_success_model.dart';

class OrderSuccessWidget extends StatefulWidget {
  const OrderSuccessWidget({
    super.key,
    this.orderId,
  });

  final String? orderId;

  static String routeName = 'OrderSuccess';
  static String routePath = '/orderSuccess';

  @override
  State<OrderSuccessWidget> createState() => _OrderSuccessWidgetState();
}

class _OrderSuccessWidgetState extends State<OrderSuccessWidget> {
  late OrderSuccessModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderSuccessModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: degloorBackButton(context, color: theme.primaryText),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BrandMark(size: 56, showWordmark: true, compact: true),
                  const SizedBox(height: 28),
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: theme.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: theme.success,
                      size: 72,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Order placed',
                    style: theme.headlineMedium.override(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The shop will confirm your cash-on-delivery order. After it ships, Track Order shows a 4-digit delivery OTP — not the 6-digit SMS login code.',
                    textAlign: TextAlign.center,
                    style: theme.bodyMedium.override(
                      fontFamily: 'Inter',
                      color: theme.secondaryText,
                      lineHeight: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    OtpCopy.checkoutHint,
                    textAlign: TextAlign.center,
                    style: theme.labelSmall.override(
                      fontFamily: 'Inter',
                      color: theme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (widget.orderId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.alternate),
                      ),
                      child: Text(
                        'Order ID: #${widget.orderId!.substring(0, 8).toUpperCase()}',
                        style: theme.titleSmall.override(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  FFButtonWidget(
                    onPressed: () async {
                      if (widget.orderId != null) {
                        context.pushNamed(
                          'OrderTracking',
                          queryParameters: {
                            'orderId': serializeParam(
                              widget.orderId,
                              ParamType.string,
                            ),
                          }.withoutNulls,
                        );
                      } else {
                        context.goNamed('CustomerHome');
                      }
                    },
                    text: 'Track Order',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      color: theme.primary,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FFButtonWidget(
                    onPressed: () async {
                      context.goNamed('CustomerHome');
                    },
                    text: 'Continue Shopping',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      color: Colors.transparent,
                      textStyle: TextStyle(
                        color: theme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      borderSide: BorderSide(color: theme.primary),
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
}
