import 'dart:async';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/load_more_control.dart';
import 'package:degloor_one/components/order_list_card.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/core/error_handler.dart';
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
  Shop? _business;
  StreamSubscription<List<PlacedOrder>>? _ordersSubscription;
  String _filter = 'active'; // 'active', 'completed', 'cancelled'

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageOrdersModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final currentUser = currentUserUid;
    if (currentUser == '') {
      if (mounted) setState(() => _loading = false);
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
    _ordersSubscription =
        OrderService.instance.watchBusiness(_business!.id).listen((_) {
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

      final filteredItems = page.items.where((order) {
        final status = OrderLifecycle.normalizeStatus(order.status);
        if (_filter == 'active') {
          return !OrderLifecycle.isTerminal(status);
        } else if (_filter == 'completed') {
          return status == OrderLifecycle.delivered;
        } else if (_filter == 'cancelled') {
          return status == OrderLifecycle.cancelled;
        }
        return true;
      }).toList();

      for (final order in filteredItems) {
        final id = order.userId;
        if (id.isEmpty) continue;
        final name = order.user?.fullName?.trim();
        if (name != null && name.isNotEmpty) {
          _customerNames[id] = name;
        }
        final phone = order.user?.phoneNumber?.trim();
        if (phone != null && phone.isNotEmpty) {
          _customerPhones[id] = phone;
        }
      }

      final existingUserIds = _customerNames.keys.toSet();
      final newUserIds = filteredItems
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
          _orders = filteredItems;
        } else {
          _orders.addAll(filteredItems);
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
              'Order status updated to ${OrderService.instance.statusLabel(newStatus, l10n: AppLocalizations.of(context))}',
            ),
            backgroundColor: DegloorTheme.success,
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
            backgroundColor: DegloorTheme.error,
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
        backgroundColor: DegloorTheme.background,
        appBar: degloorAppBar(context, title: 'Manage Orders'),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  if (_business != null) _buildFilters(),
                  const SizedBox(height: 12),
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
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: DegloorTheme.primary,
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
                        color: DegloorTheme.primary,
                        onRefresh: () => _loadPage(reset: true),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _orders.length + (_hasMore ? 1 : 0),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
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
                            final customerName = order.user?.displayName(
                                  fallback: 'Unknown Customer',
                                ) ??
                                _customerNames[order.userId] ??
                                'Loading…';
                            final customerPhone = order.user?.phoneNumber ??
                                _customerPhones[order.userId];
                            return OrderListCard(
                              title: customerName,
                              orderId: order.id,
                              createdAt: order.createdAt,
                              totalAmount: order.totalAmount,
                              status: order.status,
                              subtitle: customerPhone,
                              footer: !actions.isTerminal
                                  ? _orderActions(order, actions)
                                  : _buildInfoRow(
                                      'Customer',
                                      customerName,
                                      phoneNumber: customerPhone,
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
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _filterChip('Active', 'active'),
          const SizedBox(width: 8),
          _filterChip('Completed', 'completed'),
          const SizedBox(width: 8),
          _filterChip('Cancelled', 'cancelled'),
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

  Widget _orderActions(PlacedOrder order, OrderOwnerActions actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'Customer',
          order.user?.displayName(fallback: 'Unknown Customer') ??
              _customerNames[order.userId] ??
              'Loading…',
          phoneNumber: order.user?.phoneNumber ?? _customerPhones[order.userId],
          orderId: order.id,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (actions.canAccept)
              FFButtonWidget(
                onPressed: () =>
                    _updateOrderStatus(order.id, actions.acceptStatus),
                text: 'Accept',
                options: _buttonOptions(context, DegloorTheme.success),
              ),
            if (actions.canMarkReady)
              FFButtonWidget(
                onPressed: () =>
                    _updateOrderStatus(order.id, actions.readyStatus),
                text: 'Mark ready',
                options: _buttonOptions(context, DegloorTheme.primary),
              ),
            if (actions.canCounterDeliver)
              FFButtonWidget(
                onPressed: () => _showOtpVerificationDialog(order),
                text: 'Deliver with OTP',
                options: _buttonOptions(context, DegloorTheme.secondary),
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
                options: _buttonOptions(context, DegloorTheme.error),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {String? phoneNumber, String? orderId}) {
    final shortId = (orderId != null && orderId.length >= 8)
        ? orderId.substring(0, 8)
        : orderId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: DegloorTheme.labelSmall),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: DegloorTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
              child: InkWell(
                onTap: () async {
                  final opened = await WhatsAppService.launchWhatsApp(
                    phoneNumber: phoneNumber,
                    message:
                        'Hello, this is regarding your order #$shortId on DEGLOOR ONE.',
                  );
                  if (!opened && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(WhatsAppService.unableToOpenMessage),
                      ),
                    );
                  }
                },
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: DegloorTheme.success,
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

    final verified = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DegloorTheme.radiusLG),
          ),
          title: const Text('Verify delivery OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ask the customer for the 4-digit code on their tracking screen.',
                style: DegloorTheme.bodyMedium.copyWith(
                  color: DegloorTheme.textSecondary,
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
                  color: DegloorTheme.primary,
                ),
                decoration: InputDecoration(
                  hintText: '0000',
                  errorText: errorText,
                  filled: true,
                  fillColor: DegloorTheme.primary.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DegloorTheme.radiusLG),
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
                backgroundColor: DegloorTheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await DeliveryService.instance.confirmDeliveryWithOtp(
                    orderId: order.id,
                    otp: otpController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  setDialogState(
                      () => errorText = DeliveryService.messageFor(e));
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
        const SnackBar(
          content: Text('Order delivered after OTP verification'),
          backgroundColor: DegloorTheme.success,
        ),
      );
      await _loadPage(reset: true);
    }
  }

  FFButtonOptions _buttonOptions(BuildContext context, Color color) {
    return FFButtonOptions(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      iconPadding: EdgeInsets.zero,
      color: color,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      elevation: 0,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
    );
  }
}
