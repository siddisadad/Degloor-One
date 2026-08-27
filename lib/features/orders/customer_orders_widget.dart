import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/load_more_control.dart';
import 'package:degloor_one/components/order_list_card.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';
import 'package:degloor_one/shared/shop.dart';
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
  List<PlacedOrder> _orders = [];
  bool _isLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  int _loadToken = 0;
  static const _pageSize = 20;
  String _filter = 'active'; // 'active', 'past'

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

      final filteredItems = page.items.where((order) {
        final status = OrderLifecycle.normalizeStatus(order.status);
        if (_filter == 'active') {
          return !OrderLifecycle.isTerminal(status);
        } else {
          return OrderLifecycle.isTerminal(status);
        }
      }).toList();

      final ids = filteredItems.map((order) => order.businessId).toSet().toList();
      final shops = await DiscoveryService.instance.businessesByIds(ids);
      if (!mounted || token != _loadToken) return;
      setState(() {
        for (final shop in shops) {
          _model.businesses[shop.id] = shop;
        }
        if (reset) {
          _orders = filteredItems;
        } else {
          _orders.addAll(filteredItems);
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

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: DegloorTheme.background,
      appBar: degloorAppBar(context, title: 'My Orders'),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: DegloorTheme.primary),
                        )
                      : _orders.isEmpty
                          ? EmptyStateView(
                              icon: Icons.receipt_long_rounded,
                              title: _filter == 'active'
                                  ? 'No active orders'
                                  : 'No past orders',
                              description: _filter == 'active'
                                  ? 'Your current orders will appear here for tracking.'
                                  : 'Your completed and cancelled orders will show up here.',
                              buttonText: _filter == 'active'
                                  ? 'Start shopping'
                                  : null,
                              onTap: _filter == 'active'
                                  ? () => context.goNamed('CustomerHome')
                                  : null,
                            )
                          : RefreshIndicator(
                              color: DegloorTheme.primary,
                              onRefresh: () => _loadPage(reset: true),
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.all(DegloorTheme.spacingMD),
                                itemCount: _orders.length + (_hasMore ? 1 : 0),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                        height: DegloorTheme.spacingSM),
                                itemBuilder: (context, index) {
                                  if (index >= _orders.length) {
                                    return LoadMoreControl(
                                      loading: _loadingMore,
                                      onPressed: () => _loadPage(),
                                    );
                                  }
                                  final order = _orders[index];
                                  final business =
                                      _model.businesses[order.businessId];
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DegloorTheme.spacingMD),
      child: Row(
        children: [
          _filterChip('Active', 'active'),
          const SizedBox(width: 8),
          _filterChip('Past Orders', 'past'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = value;
            _loadPage(reset: true);
          });
        }
      },
      selectedColor: DegloorTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : DegloorTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _shopThumb(Shop? shop) {
    final imageUrl = shop?.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      child: SizedBox(
        width: 48,
        height: 48,
        child: imageUrl == null || imageUrl.isEmpty
            ? const ColoredBox(
                color: DegloorTheme.accent,
                child: Icon(
                  Icons.storefront_rounded,
                  color: DegloorTheme.primary,
                  size: 22,
                ),
              )
            : CachedRemoteImage(
                url: imageUrl,
                width: 48,
                height: 48,
                placeholderIcon: Icons.storefront_rounded,
              ),
      ),
    );
  }
}
