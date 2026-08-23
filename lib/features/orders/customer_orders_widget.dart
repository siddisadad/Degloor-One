import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/load_more_control.dart';
import 'package:degloor_one/components/order_list_card.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
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
        page: PageQuery(offset: _offset),
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

  Widget _shopThumb(BusinessesRow? shop) {
    final theme = FlutterFlowTheme.of(context);
    final imageUrl = shop?.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.designToken.radius.md),
      child: SizedBox(
        width: 48,
        height: 48,
        child: imageUrl == null || imageUrl.isEmpty
            ? ColoredBox(
                color: theme.primary.withValues(alpha: 0.08),
                child: Icon(
                  Icons.storefront_rounded,
                  color: theme.primary,
                  size: 22,
                ),
              )
            : CachedRemoteImage(
                url: imageUrl,
                placeholderIcon: Icons.storefront_rounded,
              ),
      ),
    );
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
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: degloorAppBar(context, title: 'My Orders'),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                    ),
                  )
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
                        color: theme.primary,
                        onRefresh: () => _loadPage(reset: true),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(theme.designToken.spacing.md),
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
                            final business = _model.businesses[order.businessId];
                            return OrderListCard(
                              title: business?.name ?? 'Loading shop…',
                              orderId: order.id,
                              createdAt: order.createdAt,
                              totalAmount: order.totalAmount,
                              status: order.status,
                              leading: _shopThumb(business),
                              onTap: () => context.pushNamed(
                                'OrderTracking',
                                queryParameters: {'orderId': order.id},
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
