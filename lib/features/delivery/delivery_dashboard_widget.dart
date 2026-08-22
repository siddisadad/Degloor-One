import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/backend/location_service.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'delivery_dashboard_model.dart';
export 'delivery_dashboard_model.dart';

class DeliveryDashboardWidget extends StatefulWidget {
  const DeliveryDashboardWidget({super.key});

  static String routeName = 'DeliveryDashboard';
  static String routePath = '/deliveryDashboard';

  @override
  State<DeliveryDashboardWidget> createState() =>
      _DeliveryDashboardWidgetState();
}

class _DeliveryDashboardWidgetState extends State<DeliveryDashboardWidget> {
  late DeliveryDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeliveryDashboardModel());
  }

  @override
  void dispose() {
    _stopLocationSync();
    _model.dispose();
    super.dispose();
  }

  void _startLocationSync(String partnerId) {
    if (_locationTimer != null) return;
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await LocationService.syncPartnerLocation(partnerId);
    });
    LocationService.syncPartnerLocation(partnerId);
  }

  void _stopLocationSync() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _toggleAvailability(bool value, DeliveryPartnersRow partner) async {
    if (value && partner.isVerified != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your account is pending verification. Please wait for admin approval.'),
          backgroundColor: FlutterFlowTheme.of(context).warning,
        ),
      );
      return;
    }

    await DeliveryPartnersTable().update(
      data: {'is_available': value},
      matchingRows: (src) => src.eq('id', partner.id),
    );
    if (value) {
      _startLocationSync(partner.id);
    } else {
      _stopLocationSync();
    }
    setState(() {
      _model.isOnline = value;
    });
  }

  Future<void> _acceptOrder(String orderId, DeliveryPartnersRow partner) async {
    if (partner.isVerified != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification Required: You cannot accept orders until your account is verified.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    try {
      await DeliveryService.acceptOrder(orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order accepted!')),
      );
      setState(() {});
    } catch (e) {
      AppLogger.error('Failed to accept order', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DeliveryService.messageFor(e)),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _confirmPickup(String assignmentId) async {
    try {
      await DeliveryService.confirmPickup(assignmentId);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      AppLogger.error('Failed to confirm pickup', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DeliveryService.messageFor(e)),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _confirmDelivery(String orderId) async {
    final otpController = TextEditingController();
    String? errorText;
    final verified = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Verify Delivery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ask the customer for the 4-digit delivery OTP.'),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                ),
                maxLength: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await DeliveryService.confirmDeliveryWithOtp(
                    orderId: orderId,
                    otp: otpController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  setDialogState(() => errorText = DeliveryService.messageFor(e));
                }
              },
              child: const Text('Verify & Confirm'),
            ),
          ],
        ),
      ),
    );
    otpController.dispose();

    if (verified != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order delivered!')),
    );
    setState(() {});
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
          backgroundColor: FlutterFlowTheme.of(context).primary,
          title: Text(
            'Delivery Dashboard',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          child: FutureBuilder<List<DeliveryPartnersRow>>(
            future: DeliveryPartnersTable().querySingleRow(
              queryFn: (q) => q.eq('user_id', currentUserUid),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('You are not registered as a Delivery Partner.'),
                      FFButtonWidget(
                        onPressed: () async {
                          await DeliveryPartnersTable().insert({
                            'user_id': currentUserUid,
                            'is_available': false,
                            'is_verified': false,
                          });
                          setState(() {});
                        },
                        text: 'Register Now',
                        options: FFButtonOptions(
                          height: 40,
                          padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.inter(),
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                          elevation: 3,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final partner = snapshot.data!.first;
              _model.isOnline = partner.isAvailable;
              if (_model.isOnline) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _startLocationSync(partner.id));
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: ${_model.isOnline ? "Online" : "Offline"}',
                                style: FlutterFlowTheme.of(context).titleLarge,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: partner.isVerified
                                          ? FlutterFlowTheme.of(context).success
                                          : FlutterFlowTheme.of(context).warning,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    partner.isVerified
                                        ? 'Verified Partner'
                                        : 'Pending Verification',
                                    style: FlutterFlowTheme.of(context).labelSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: _model.isOnline,
                            onChanged: (value) => _toggleAvailability(value, partner),
                            activeThumbColor: FlutterFlowTheme.of(context).primary,
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Active Task Section
                      Text('Active Task', style: FlutterFlowTheme.of(context).headlineSmall),
                      FutureBuilder<List<DeliveryAssignmentsRow>>(
                        future: DeliveryAssignmentsTable().querySingleRow(
                          queryFn: (q) => q
                              .eq('delivery_partner_id', partner.id)
                              .neq('status', 'delivered'),
                        ),
                        builder: (context, assignmentSnapshot) {
                          if (assignmentSnapshot.hasData && assignmentSnapshot.data!.isNotEmpty) {
                            final assignment = assignmentSnapshot.data!.first;
                            return FutureBuilder<List<OrdersRow>>(
                              future: OrdersTable().querySingleRow(
                                queryFn: (q) => q.eq('id', assignment.orderId),
                              ),
                              builder: (context, orderSnapshot) {
                                if (orderSnapshot.hasData && orderSnapshot.data!.isNotEmpty) {
                                  final order = orderSnapshot.data!.first;
                                  return Card(
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Order ID: ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text('Total: \$${order.totalAmount}'),
                                          Text('Status: ${assignment.status}'),
                                          if (order.userId.length > 10)
                                            FutureBuilder<List<UsersRow>>(
                                              future: UsersTable().querySingleRow(
                                                queryFn: (q) =>
                                                    q.eq('id', order.userId),
                                              ),
                                            builder: (context, userSnapshot) {
                                              if (userSnapshot.hasData && userSnapshot.data!.isNotEmpty) {
                                                final user = userSnapshot.data!.first;
                                                if (user.phoneNumber != null) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        await WhatsAppService.launchWhatsApp(
                                                          phoneNumber: user.phoneNumber!,
                                                          message: 'Hello, this is your delivery partner regarding your order #${order.id.substring(0, 8)} on DEGLOOR ONE.',
                                                        );
                                                      },
                                                      child: const Row(
                                                        children: [
                                                          Icon(Icons.chat_bubble_outline_rounded, color: Colors.green, size: 18),
                                                          SizedBox(width: 8),
                                                          Text('WhatsApp Customer', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                              return Container();
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          if (assignment.status == 'assigned')
                                            FFButtonWidget(
                                              onPressed: () => _confirmPickup(assignment.id),
                                              text: 'Confirm Pickup',
                                              options: const FFButtonOptions(
                                                width: double.infinity,
                                                color: Colors.blue,
                                                textStyle: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          if (assignment.status == 'picked_up')
                                            FFButtonWidget(
                                              onPressed: () => _confirmDelivery(order.id),
                                              text: 'Confirm Delivery',
                                              options: const FFButtonOptions(
                                                width: double.infinity,
                                                color: Colors.green,
                                                textStyle: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return const Text('Loading order details...');
                              },
                            );
                          }
                          return const Text('No active task.');
                        },
                      ),

                      const Divider(height: 32),

                      // Available Orders Section
                      Text('Available Orders', style: FlutterFlowTheme.of(context).headlineSmall),
                      FutureBuilder<List<OrdersRow>>(
                        future: OrdersTable().queryRows(
                          queryFn: (q) => q.eq('status', 'ready'),
                        ),
                        builder: (context, ordersSnapshot) {
                          if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final orders = ordersSnapshot.data ?? [];
                          if (orders.isEmpty) return const Text('No orders available.');

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return Card(
                                child: ListTile(
                                  title: Text('Order #${order.id.substring(0, 8)}'),
                                  subtitle: Text('Amount: \$${order.totalAmount}'),
                                  trailing: FFButtonWidget(
                                    onPressed: () => _acceptOrder(order.id, partner),
                                    text: 'Accept',
                                    options: FFButtonOptions(
                                      color: FlutterFlowTheme.of(context).primary,
                                      textStyle: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
