import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: FlutterFlowTheme.of(context).success,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Order Placed!',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.inter(),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Your order has been successfully placed and is waiting for business confirmation.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
            ),
            const SizedBox(height: 32),
            if (widget.orderId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                ),
                child: Text(
                  'Order ID: #${widget.orderId!.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.bold,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
              ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  FFButtonWidget(
                    onPressed: () async {
                      if (widget.orderId != null) {
                        context.pushNamed(
                          'OrderTracking',
                          queryParameters: {
                            'orderId': serializeParam(widget.orderId, ParamType.string),
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
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                        color: FlutterFlowTheme.of(context).primary,
                        fontWeight: FontWeight.bold,
                      ),
                      borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
