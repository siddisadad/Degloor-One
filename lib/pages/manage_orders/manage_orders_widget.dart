import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_orders_model.dart';
export 'manage_orders_model.dart';

class ManageOrdersWidget extends StatefulWidget {
  const ManageOrdersWidget({super.key});

  static String routeName = 'ManageOrders';
  static String routePath = '/manageOrders';

  @override
  State<ManageOrdersWidget> createState() => _ManageOrdersWidgetState();
}

class _ManageOrdersWidgetState extends State<ManageOrdersWidget> {
  late ManageOrdersModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<OrdersRow> _orders = [];
  Map<String, String> _customerNames = {};
  bool _loading = true;
  BusinessesRow? _business;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageOrdersModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final currentUser = currentUserUid;
    if (currentUser == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final businesses = await BusinessesTable().queryRows(
        queryFn: (q) => q.eq('owner_id', currentUser),
      );

      if (businesses.isNotEmpty) {
        _business = businesses.first;
        await _fetchOrders();
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error fetching business: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchOrders() async {
    if (_business == null) return;
    setState(() => _loading = true);
    try {
      final orders = await OrdersTable().queryRows(
        queryFn: (q) => q
            .eq('business_id', _business!.id)
            .order('created_at', ascending: false),
      );

      // Fetch customer names
      final userIds = orders.map((o) => o.userId).toSet().toList();
      if (userIds.isNotEmpty) {
        final users = await UsersTable().queryRows(
          queryFn: (q) => q.inFilter('id', userIds),
        );
        for (var user in users) {
          _customerNames[user.id] = user.fullName ?? 'Unknown Customer';
        }
      }

      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    setState(() => _loading = true);
    try {
      await OrdersTable().update(
        data: {'status': newStatus},
        matchingRows: (q) => q.eq('id', orderId),
      );

      // Log status history
      await OrderStatusHistoryTable().insert({
        'order_id': orderId,
        'status': newStatus,
        'notes': 'Order status updated by business owner.',
      });

      // Send Notification to Customer
      final orderRows = await OrdersTable().queryRows(
        queryFn: (q) => q.eq('id', orderId),
      );
      if (orderRows.isNotEmpty) {
        final order = orderRows.first;
        await NotificationsTable().insert({
          'user_id': order.userId,
          'title': 'Order Status Updated',
          'message':
              'Your order #${order.id.substring(0, 8)} is now $newStatus.',
          'type': 'order_status',
          'is_read': false,
        });
      }

      await _fetchOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      setState(() => _loading = false);
    }
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
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          title: Text(
            'Manage Orders',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (_business == null && !_loading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No business found for this account. Please register your business first.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    ),
                  )
                else if (_loading && _orders.isEmpty)
                  Center(child: CircularProgressIndicator())
                else if (_orders.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No orders found for your business.',
                        style: FlutterFlowTheme.of(context).labelMedium,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _orders.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12.0),
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final customerName = _customerNames[order.userId] ?? 'Loading...';

                        return Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${order.id.substring(0, 8)}',
                                      style: FlutterFlowTheme.of(context).titleSmall.override(
                                            font: GoogleFonts.inter(),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        order.status.toUpperCase(),
                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                              font: GoogleFonts.inter(),
                                              color: _getStatusColor(order.status),
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 24),
                                _buildInfoRow('Customer', customerName),
                                _buildInfoRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(2)}'),
                                _buildInfoRow('Date', dateTimeFormat('MMM d, y HH:mm', order.createdAt)),
                                SizedBox(height: 16),
                                if (order.status != 'delivered' && order.status != 'cancelled')
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: [
                                      if (order.status == 'pending')
                                        FFButtonWidget(
                                          onPressed: () => _updateOrderStatus(order.id, 'accepted'),
                                          text: 'Accept',
                                          options: _buttonOptions(context, FlutterFlowTheme.of(context).success),
                                        ),
                                      if (order.status == 'accepted')
                                        FFButtonWidget(
                                          onPressed: () => _updateOrderStatus(order.id, 'ready'),
                                          text: 'Mark as Ready',
                                          options: _buttonOptions(context, FlutterFlowTheme.of(context).primary),
                                        ),
                                      if (order.status == 'ready')
                                        FFButtonWidget(
                                          onPressed: () => _updateOrderStatus(order.id, 'delivered'),
                                          text: 'Deliver',
                                          options: _buttonOptions(context, FlutterFlowTheme.of(context).tertiary),
                                        ),
                                      if (order.status != 'delivered' && order.status != 'cancelled')
                                        FFButtonWidget(
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Cancel Order'),
                                                content: Text('Are you sure you want to cancel this order?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: Text('No'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: Text('Yes, Cancel'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await _updateOrderStatus(order.id, 'cancelled');
                                            }
                                          },
                                          text: 'Cancel',
                                          options: _buttonOptions(context, FlutterFlowTheme.of(context).error),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: FlutterFlowTheme.of(context).labelMedium),
          Text(value, style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(),
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'ready': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  FFButtonOptions _buttonOptions(BuildContext context, Color color) {
    return FFButtonOptions(
      height: 36.0,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      iconPadding: EdgeInsets.zero,
      color: color,
      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
            font: GoogleFonts.inter(),
            color: Colors.white,
            fontSize: 14.0,
          ),
      elevation: 2.0,
      borderRadius: BorderRadius.circular(8.0),
    );
  }
}
