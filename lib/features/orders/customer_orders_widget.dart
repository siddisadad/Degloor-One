import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'customer_orders_model.dart';
export 'customer_orders_model.dart';

class CustomerOrdersWidget extends StatefulWidget {
  const CustomerOrdersWidget({super.key});

  static String routeName = 'CustomerOrders';
  static String routePath = '/customerOrders';

  @override
  State<CustomerOrdersWidget> createState() => _CustomerOrdersWidgetState();
}

class _CustomerOrdersWidgetState extends State<CustomerOrdersWidget> {
  late CustomerOrdersModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<OrdersRow> _orders = [];
  bool _isLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  int _loadToken = 0;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomerOrdersModel());
    _loadPage(reset: true);
  }

  Future<void> _loadPage({bool reset = false}) async {
    final userId = currentUserUid;
    if (userId == '') {
      if (mounted) {
        setState(() {
          _orders = [];
          _isLoading = false;
          _hasMore = false;
        });
      }
      return;
    }
    if (!reset && (_loadingMore || !_hasMore)) return;
    final token = reset ? ++_loadToken : _loadToken;
    if (reset) {
      _offset = 0;
      _hasMore = true;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = reset && _orders.isEmpty;
      _loadingMore = !reset;
    });
    try {
      final page = await OrderService.instance.listForUser(
        userId,
        page: PageQuery(limit: _pageSize, offset: _offset),
      );
      final ids = page.items.map((order) => order.businessId).toSet().toList();
      final shops = await DiscoveryService.instance.businessesByIds(ids);
      if (!mounted || token != _loadToken) return;
      setState(() {
        for (final shop in shops) {
          _model.businesses[shop.id] = shop;
        }
        if (reset) {
          _orders = page.items;
        } else {
          _orders.addAll(page.items);
        }
        _offset += _pageSize;
        _hasMore = page.hasMore;
        _isLoading = false;
        _loadingMore = false;
        _model.ordersFuture = Future.value(_orders);
      });
    } catch (e) {
      AppLogger.error('Error fetching orders', e);
      if (mounted && token == _loadToken) {
        setState(() {
          _isLoading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    final theme = FlutterFlowTheme.of(context);
    switch (OrderLifecycle.normalizeStatus(status)) {
      case OrderLifecycle.pending:
        return theme.warning;
      case OrderLifecycle.accepted:
        return theme.info;
      case OrderLifecycle.ready:
        return theme.secondary;
      case OrderLifecycle.shipping:
      case OrderLifecycle.outForDelivery:
        return theme.primary;
      case OrderLifecycle.delivered:
        return theme.success;
      case OrderLifecycle.cancelled:
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        title: Text(
          'My Orders',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? EmptyStateView(
                  icon: Icons.receipt_long_rounded,
                  title: 'No orders yet',
                  description:
                      'Your cart and local shops are ready when you are.',
                  buttonText: 'Start shopping',
                  onTap: () => context.goNamed('CustomerHome'),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadPage(reset: true),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length + (_hasMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index >= _orders.length) {
                        return TextButton(
                          onPressed:
                              _loadingMore ? null : () => _loadPage(),
                          child: _loadingMore
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Load more'),
                        );
                      }
                      final order = _orders[index];
                      final business = _model.businesses[order.businessId];

                      return InkWell(
                        onTap: () => context.pushNamed(
                          'OrderTracking',
                          queryParameters: {'orderId': order.id},
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(
                              FlutterFlowTheme.of(context)
                                  .designToken
                                  .radius
                                  .lg,
                            ),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                            boxShadow: [
                              FlutterFlowTheme.of(context).designToken.shadow.sm,
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        business?.name ?? 'Loading...',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.inter(),
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                                context, order.status)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        OrderLifecycle.label(order.status),
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.inter(),
                                              color: _getStatusColor(
                                                  context, order.status),
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Order #${order.id.substring(0, 8)}',
                                  style:
                                      FlutterFlowTheme.of(context).labelSmall,
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateTimeFormat(
                                          'MMM d, yyyy HH:mm', order.createdAt),
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall,
                                    ),
                                    Text(
                                      '₹${order.totalAmount.toStringAsFixed(2)}',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.inter(),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
