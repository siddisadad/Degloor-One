import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/load_more_control.dart';
import 'package:degloor_one/components/order_list_card.dart';
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

  List<PlacedOrder> _orders = [];
  final Map<String, String> _customerNames = {};
  final Map<String, String> _customerPhones = {};
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  int _loadToken = 0;
  static const _pageSize = 20;
  BusinessesRow? _business;
  StreamSubscription<List<PlacedOrder>>? _ordersSubscription;

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
        page: PageQuery(offset: _offset),
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
            content: Text(
              'Order status updated to ${OrderService.instance.statusLabel(newStatus)}',
            ),
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
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: degloorAppBar(context, title: 'Manage Orders'),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: EdgeInsets.all(theme.designToken.spacing.md),
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
                      Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(theme.primary),
                          ),
                        ),
                      )
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
                        child: RefreshIndicator(
                          color: theme.primary,
                          onRefresh: () => _loadPage(reset: true),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _orders.length + (_hasMore ? 1 : 0),
                            separatorBuilder: (context, index) =>
                                SizedBox(height: theme.designToken.spacing.sm),
                            itemBuilder: (context, index) {
                              if (index >= _orders.length) {
                                return LoadMoreControl(
                                  loading: _loadingMore,
                                  onPressed: () => _loadPage(),
                                );
                              }
                              final order = _orders[index];
                              final actions =
                                  OrderService.instance.ownerActions(order.status);
                              final customerName =
                                  _customerNames[order.userId] ?? 'Loading…';
                              return OrderListCard(
                                title: customerName,
                                orderId: order.id,
                                createdAt: order.createdAt,
                                totalAmount: order.totalAmount,
                                status: order.status,
                                subtitle: _customerPhones[order.userId],
                                footer: !actions.isTerminal
                                    ? _orderActions(order, actions)
                                    : _buildInfoRow(
                                        'Customer',
                                        customerName,
                                        phoneNumber:
                                            _customerPhones[order.userId],
                                        orderId: order.id,
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderActions(PlacedOrder order, OrderOwnerActions actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'Customer',
          _customerNames[order.userId] ?? 'Loading…',
          phoneNumber: _customerPhones[order.userId],
          orderId: order.id,
        ),
        SizedBox(height: FlutterFlowTheme.of(context).designToken.spacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (actions.canAccept)
              FFButtonWidget(
                onPressed: () =>
                    _updateOrderStatus(order.id, actions.acceptStatus),
                text: 'Accept',
                options: _buttonOptions(
                  context,
                  FlutterFlowTheme.of(context).success,
                ),
              ),
            if (actions.canMarkReady)
              FFButtonWidget(
                onPressed: () =>
                    _updateOrderStatus(order.id, actions.readyStatus),
                text: 'Mark ready',
                options: _buttonOptions(
                  context,
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            if (actions.canCounterDeliver)
              FFButtonWidget(
                onPressed: () => _showOtpVerificationDialog(order),
                text: 'Deliver with OTP',
                options: _buttonOptions(
                  context,
                  FlutterFlowTheme.of(context).secondary,
                ),
              ),
            if (actions.canCancel)
              FFButtonWidget(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancel order'),
                      content: const Text(
                        'Cancel this order? The customer will be notified.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Keep'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes, cancel'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _updateOrderStatus(order.id, actions.cancelStatus);
                  }
                },
                text: 'Cancel',
                options: _buttonOptions(
                  context,
                  FlutterFlowTheme.of(context).error,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {String? phoneNumber, String? orderId}) {
    final theme = FlutterFlowTheme.of(context);
    final shortId = (orderId != null && orderId.length >= 8)
        ? orderId.substring(0, 8)
        : orderId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: theme.labelMedium),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: theme.bodyMedium.override(
                font: GoogleFonts.inter(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
              child: InkWell(
                onTap: () async {
                  await WhatsAppService.launchWhatsApp(
                    phoneNumber: phoneNumber,
                    message:
                        'Hello, this is regarding your order #$shortId on DEGLOOR ONE.',
                  );
                },
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: theme.success,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showOtpVerificationDialog(PlacedOrder order) async {
    final otpController = TextEditingController();
    String? errorText;

    final theme = FlutterFlowTheme.of(context);
    final verified = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.designToken.radius.lg),
          ),
          title: const Text('Verify delivery OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ask the customer for the 4-digit code on their tracking screen.',
                style: theme.bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  color: theme.primary,
                ),
                decoration: InputDecoration(
                  hintText: '0000',
                  errorText: errorText,
                  filled: true,
                  fillColor: theme.primary.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(theme.designToken.radius.lg),
                  ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
              ),
              onPressed: () async {
                try {
                  await DeliveryService.instance.confirmDeliveryWithOtp(
                    orderId: order.id,
                    otp: otpController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  setDialogState(() => errorText = DeliveryService.messageFor(e));
                }
              },
              child: const Text('Verify & deliver'),
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
    final theme = FlutterFlowTheme.of(context);
    return FFButtonOptions(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      iconPadding: EdgeInsets.zero,
      color: color,
      textStyle: theme.titleSmall.override(
        font: GoogleFonts.inter(),
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      elevation: 0,
      borderRadius: BorderRadius.circular(theme.designToken.radius.md),
    );
  }
}
