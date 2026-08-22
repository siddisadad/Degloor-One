import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'dart:async';
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
  final Map<String, String> _customerNames = {};
  final Map<String, String> _customerPhones = {};
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  int _loadToken = 0;
  static const _pageSize = 20;
  BusinessesRow? _business;
  StreamSubscription<List<OrdersRow>>? _ordersSubscription;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageOrdersModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final currentUser = currentUserUid;
    if (currentUser == '') {
      setState(() => _loading = false);
      return;
    }

    try {
      final businesses = await DiscoveryService.instance.ownedBy(currentUser);

      if (businesses.isNotEmpty) {
        _business = businesses.first;
        _listenToOrders();
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      AppLogger.error('Error fetching business', e);
      if (mounted) setState(() => _loading = false);
    }
  }

  void _listenToOrders() {
    if (_business == null) return;
    _ordersSubscription?.cancel();
    _ordersSubscription = OrderService.instance
        .watchBusiness(_business!.id)
        .listen((_) {
      if (mounted) _loadPage(reset: true);
    });
    _loadPage(reset: true);
  }

  Future<void> _loadPage({bool reset = false}) async {
    final business = _business;
    if (business == null) return;
    if (!reset && (_loadingMore || !_hasMore)) return;
    final token = reset ? ++_loadToken : _loadToken;
    if (reset) {
      _offset = 0;
      _hasMore = true;
    }
    if (!mounted) return;
    setState(() {
      _loading = reset && _orders.isEmpty;
      _loadingMore = !reset;
    });
    try {
      final page = await OrderService.instance.listForBusiness(
        business.id,
        page: PageQuery(limit: _pageSize, offset: _offset),
      );
      final existingUserIds = _customerNames.keys.toSet();
      final newUserIds = page.items
          .map((order) => order.userId)
          .where((id) => id.length > 10 && !existingUserIds.contains(id))
          .toSet()
          .toList();
      if (newUserIds.isNotEmpty) {
        final users = await DiscoveryService.instance.usersByIds(newUserIds);
        for (final user in users) {
          _customerNames[user.id] = user.fullName ?? 'Unknown Customer';
          if (user.phoneNumber != null) {
            _customerPhones[user.id] = user.phoneNumber!;
          }
        }
      }
      if (!mounted || token != _loadToken) return;
      setState(() {
        if (reset) {
          _orders = page.items;
        } else {
          _orders.addAll(page.items);
        }
        _offset += _pageSize;
        _hasMore = page.hasMore;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      AppLogger.error('Error fetching shop orders', e);
      if (mounted && token == _loadToken) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    setState(() => _loading = true);
    try {
      await OrderService.instance.updateOwnerStatus(
        orderId: orderId,
        nextStatus: newStatus,
        ownerId: currentUserUid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: FlutterFlowTheme.of(context).success,
          ),
        );
        await _loadPage(reset: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLogger.userFacingMessage(
                e,
                fallback: 'Unable to update the order. Please try again.',
              ),
            ),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _ordersSubscription?.cancel();
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
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          title: Text(
            'Manage Orders',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_business == null && !_loading)
                  const Expanded(
                    child: EmptyStateView(
                      icon: Icons.storefront_outlined,
                      title: 'No shop yet',
                      description:
                          'Register your business to accept and fulfill Degloor orders.',
                    ),
                  )
                else if (_loading && _orders.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (_orders.isEmpty)
                  const Expanded(
                    child: EmptyStateView(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders yet',
                      description:
                          'New customer orders for your shop will show up here.',
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _orders.length + (_hasMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                      itemBuilder: (context, index) {
                        if (index >= _orders.length) {
                          return TextButton(
                            onPressed: _loadingMore ? null : () => _loadPage(),
                            child: _loadingMore
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Load more'),
                          );
                        }
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
                            padding: const EdgeInsets.all(16.0),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.status).withValues(alpha: 0.1),
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
                                const Divider(height: 24),
                                _buildInfoRow(
                                  'Customer',
                                  customerName,
                                  phoneNumber: _customerPhones[order.userId],
                                  orderId: order.id,
                                ),
                                _buildInfoRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(2)}'),
                                _buildInfoRow('Date', dateTimeFormat('MMM d, y HH:mm', order.createdAt)),
                                const SizedBox(height: 16),
                                if (!OrderLifecycle.isTerminal(order.status))
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: [
                                      if (OrderLifecycle.canTransition(
                                        from: order.status,
                                        to: OrderLifecycle.accepted,
                                      ))
                                        FFButtonWidget(
                                          onPressed: () => _updateOrderStatus(order.id, 'accepted'),
                                          text: 'Accept',
                                          options: _buttonOptions(context, FlutterFlowTheme.of(context).success),
                                        ),
                                      if (OrderLifecycle.canTransition(
                                        from: order.status,
                                        to: OrderLifecycle.ready,
                                      ))
                                        FFButtonWidget(
                                          onPressed: () => _updateOrderStatus(order.id, 'ready'),
                                          text: 'Mark as Ready',
                                          options: _buttonOptions(context, FlutterFlowTheme.of(context).primary),
                                        ),
                                      if (OrderLifecycle.normalizeStatus(order.status) ==
                                          OrderLifecycle.ready)
                                        FFButtonWidget(
                                          onPressed: () => _showOtpVerificationDialog(order),
                                          text: 'Deliver (Verify OTP)',
                                          options: _buttonOptions(context, FlutterFlowTheme.of(context).tertiary),
                                        ),
                                      if (OrderLifecycle.canOwnerCancel(order.status))
                                        FFButtonWidget(
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Cancel Order'),
                                                content: const Text('Are you sure you want to cancel this order?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text('No'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text('Yes, Cancel'),
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

  Widget _buildInfoRow(String label, String value, {String? phoneNumber, String? orderId}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: FlutterFlowTheme.of(context).labelMedium),
          Row(
            children: [
              Text(value, style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                fontWeight: FontWeight.w500,
              )),
              if (phoneNumber != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                  child: InkWell(
                    onTap: () async {
                      await WhatsAppService.launchWhatsApp(
                        phoneNumber: phoneNumber,
                        message: 'Hello, this is regarding your order #${orderId?.substring(0, 8)} on DEGLOOR ONE.',
                      );
                    },
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: FlutterFlowTheme.of(context).success,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'ready': return Colors.purple;
      case 'shipping': return Colors.teal;
      case 'out_for_delivery': return Colors.green;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _showOtpVerificationDialog(OrdersRow order) async {
    final otpController = TextEditingController();
    String? errorText;

    final verified = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Verify Delivery OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ask the customer for the 4-digit OTP shown on their tracking screen.'),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '0000',
                  errorText: errorText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
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
                    orderId: order.id,
                    otp: otpController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  setDialogState(() => errorText = DeliveryService.messageFor(e));
                }
              },
              child: const Text('Verify & Deliver'),
            ),
          ],
        ),
      ),
    );
    otpController.dispose();

    if (verified == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order delivered after OTP verification'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
      await _loadPage(reset: true);
    }
  }

  FFButtonOptions _buttonOptions(BuildContext context, Color color) {
    return FFButtonOptions(
      height: 36.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
