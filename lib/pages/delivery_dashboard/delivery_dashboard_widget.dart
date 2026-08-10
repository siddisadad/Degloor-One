import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeliveryDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _toggleAvailability(bool value, String partnerId) async {
    await DeliveryPartnersTable().update(
      data: {'is_available': value},
      matchingRows: (src) => src.eq('id', partnerId),
    );
    setState(() {
      _model.isOnline = value;
    });
  }

  Future<void> _acceptOrder(String orderId, String partnerId) async {
    await DeliveryAssignmentsTable().insert({
      'order_id': orderId,
      'delivery_partner_id': partnerId,
      'status': 'assigned',
    });
    await OrdersTable().update(
      data: {'status': 'shipping'},
      matchingRows: (src) => src.eq('id', orderId),
    );
    // Log status history
    await OrderStatusHistoryTable().insert({
      'order_id': orderId,
      'status': 'Shipping',
      'notes': 'Order accepted by delivery partner.',
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order accepted!')),
    );
    setState(() {});
  }

  Future<void> _confirmPickup(String assignmentId, String orderId) async {
    await DeliveryAssignmentsTable().update(
      data: {'status': 'picked_up'},
      matchingRows: (src) => src.eq('id', assignmentId),
    );
    // Update order status as well
    await OrdersTable().update(
      data: {'status': 'out_for_delivery'},
      matchingRows: (src) => src.eq('id', orderId),
    );
    // Log status history
    await OrderStatusHistoryTable().insert({
      'order_id': orderId,
      'status': 'Picked Up',
      'notes': 'Order picked up by delivery partner.',
    });
    setState(() {});
  }

  Future<void> _confirmDelivery(String assignmentId, String orderId) async {
    final orderList = await OrdersTable().querySingleRow(
      queryFn: (q) => q.eq('id', orderId),
    );
    if (orderList.isEmpty) return;
    final order = orderList.first;
    final correctOtp = order.deliveryOtp;

    final otpController = TextEditingController();
    final verified = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verify Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ask the customer for the 4-digit delivery OTP.'),
            SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (otpController.text == correctOtp) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid OTP. Please try again.')),
                );
              }
            },
            child: Text('Verify & Confirm'),
          ),
        ],
      ),
    );

    if (verified != true) return;

    await DeliveryAssignmentsTable().update(
      data: {'status': 'delivered'},
      matchingRows: (src) => src.eq('id', assignmentId),
    );
    await OrdersTable().update(
      data: {'status': 'delivered'},
      matchingRows: (src) => src.eq('id', orderId),
    );
    // Log status history
    await OrderStatusHistoryTable().insert({
      'order_id': orderId,
      'status': 'Delivered',
      'notes': 'Order delivered successfully after OTP verification.',
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order delivered!')),
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
          automaticallyImplyLeading: true,
          title: Text(
            'Delivery Dashboard',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
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
                      Text('You are not registered as a Delivery Partner.'),
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
                          padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.inter(),
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                          elevation: 3,
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1,
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

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status: ${_model.isOnline ? "Online" : "Offline"}',
                            style: FlutterFlowTheme.of(context).titleLarge,
                          ),
                          Switch(
                            value: _model.isOnline,
                            onChanged: (value) => _toggleAvailability(value, partner.id),
                            activeColor: FlutterFlowTheme.of(context).primary,
                          ),
                        ],
                      ),
                      Divider(height: 32),

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
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Order ID: ${order.id}', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('Total: \$${order.totalAmount}'),
                                          Text('Status: ${assignment.status}'),
                                          SizedBox(height: 16),
                                          if (assignment.status == 'assigned')
                                            FFButtonWidget(
                                              onPressed: () => _confirmPickup(assignment.id, order.id),
                                              text: 'Confirm Pickup',
                                              options: FFButtonOptions(
                                                width: double.infinity,
                                                color: Colors.blue,
                                                textStyle: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          if (assignment.status == 'picked_up')
                                            FFButtonWidget(
                                              onPressed: () => _confirmDelivery(assignment.id, order.id),
                                              text: 'Confirm Delivery',
                                              options: FFButtonOptions(
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
                                return Text('Loading order details...');
                              },
                            );
                          }
                          return Text('No active task.');
                        },
                      ),

                      Divider(height: 32),

                      // Available Orders Section
                      Text('Available Orders', style: FlutterFlowTheme.of(context).headlineSmall),
                      FutureBuilder<List<OrdersRow>>(
                        future: OrdersTable().queryRows(
                          queryFn: (q) => q.eq('status', 'ready'),
                        ),
                        builder: (context, ordersSnapshot) {
                          if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          final orders = ordersSnapshot.data ?? [];
                          if (orders.isEmpty) return Text('No orders available.');

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return Card(
                                child: ListTile(
                                  title: Text('Order #${order.id.substring(0, 8)}'),
                                  subtitle: Text('Amount: \$${order.totalAmount}'),
                                  trailing: FFButtonWidget(
                                    onPressed: () => _acceptOrder(order.id, partner.id),
                                    text: 'Accept',
                                    options: FFButtonOptions(
                                      color: FlutterFlowTheme.of(context).primary,
                                      textStyle: TextStyle(color: Colors.white),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
