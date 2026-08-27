import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/backend/location_service.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/load_more_control.dart';
import 'package:degloor_one/components/order_list_card.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:degloor_one/shared/delivery_assignment.dart';
import 'package:degloor_one/shared/delivery_partner.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/placed_order.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/user_profile.dart';
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

  DeliveryPartner? _partner;
  DeliveryAssignment? _assignment;
  PlacedOrder? _activeOrder;
  UserProfile? _customer;
  final Map<String, Shop> _shops = {};
  List<PlacedOrder> _ready = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  int _loadToken = 0;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeliveryDashboardModel());
    _load(reset: true);
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

  Future<void> _load({bool reset = false}) async {
    final userId = currentUserUid;
    if (userId.isEmpty) {
      if (mounted) {
        setState(() {
          _partner = null;
          _loading = false;
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
      _loading = reset && _ready.isEmpty && _partner == null;
      _loadingMore = !reset;
    });
    try {
      final partner = reset
          ? await DeliveryService.instance.partnerForUser(userId)
          : _partner;
      if (!mounted || token != _loadToken) return;
      if (partner == null) {
        setState(() {
          _partner = null;
          _assignment = null;
          _activeOrder = null;
          _customer = null;
          _ready = [];
          _loading = false;
          _loadingMore = false;
          _hasMore = false;
          _model.isOnline = false;
        });
        _stopLocationSync();
        return;
      }

      DeliveryAssignment? assignment = _assignment;
      PlacedOrder? activeOrder = _activeOrder;
      UserProfile? customer = _customer;
      if (reset) {
        assignment =
            await DeliveryService.instance.activeForPartner(partner.id);
        activeOrder = assignment == null
            ? null
            : await OrderService.instance.findById(assignment.orderId);
        final users = activeOrder == null
            ? const <UserProfile>[]
            : await DiscoveryService.instance.profile(activeOrder.userId);
        customer = users.isEmpty ? null : users.first;
      }

      final page = await DeliveryService.instance.readyOrders(
        page: PageQuery(offset: _offset),
      );
      final shopIds = {
        ...page.items.map((order) => order.businessId),
        if (activeOrder != null) activeOrder.businessId,
      }.where((id) => !_shops.containsKey(id)).toList();
      if (shopIds.isNotEmpty) {
        final shops = await DiscoveryService.instance.businessesByIds(shopIds);
        for (final shop in shops) {
          _shops[shop.id] = shop;
        }
      }
      if (!mounted || token != _loadToken) return;
      setState(() {
        _partner = partner;
        _assignment = assignment;
        _activeOrder = activeOrder;
        _customer = customer;
        if (reset) {
          _ready = page.items;
        } else {
          _ready.addAll(page.items);
        }
        _offset += _pageSize;
        _hasMore = page.hasMore;
        _loading = false;
        _loadingMore = false;
        _model.isOnline = partner.isAvailable;
      });
      if (partner.isAvailable) {
        _startLocationSync(partner.id);
      } else {
        _stopLocationSync();
      }
    } catch (e) {
      AppLogger.error('Error loading delivery dashboard', e);
      if (mounted && token == _loadToken) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    final partner = _partner;
    if (partner == null) return;
    try {
      await DeliveryService.instance.setAvailability(
        partnerId: partner.id,
        available: value,
        verified: partner.isVerified,
      );
      if (value) {
        _startLocationSync(partner.id);
      } else {
        _stopLocationSync();
      }
      if (!mounted) return;
      setState(() => _model.isOnline = value);
      await _load(reset: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DeliveryService.messageFor(e)),
          backgroundColor: FlutterFlowTheme.of(context).warning,
        ),
      );
    }
  }

  Future<void> _register() async {
    try {
      await DeliveryService.instance.registerPartner(currentUserUid);
      if (mounted) await _load(reset: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DeliveryService.messageFor(e)),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _acceptOrder(String orderId) async {
    final partner = _partner;
    if (partner == null) return;
    if (partner.isVerified != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Verification required: you cannot accept orders until your account is verified.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }
    try {
      await DeliveryService.instance.acceptOrder(orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order accepted'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
      await _load(reset: true);
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
      await DeliveryService.instance.confirmPickup(assignmentId);
      if (!mounted) return;
      await _load(reset: true);
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
    final theme = FlutterFlowTheme.of(context);
    final verified = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.designToken.radius.lg),
          ),
          title: const Text('Verify delivery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ask the customer for the 4-digit delivery OTP.',
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
              onPressed: () => Navigator.pop(dialogContext, false),
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
                    orderId: orderId,
                    otp: otpController.text.trim(),
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                } catch (e) {
                  setDialogState(
                    () => errorText = DeliveryService.messageFor(e),
                  );
                }
              },
              child: const Text('Verify & deliver'),
            ),
          ],
        ),
      ),
    );
    otpController.dispose();

    if (verified != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order delivered'),
        backgroundColor: FlutterFlowTheme.of(context).success,
      ),
    );
    await _load(reset: true);
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
        appBar: degloorAppBar(context, title: 'Delivery'),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                      ),
                    )
                  : _partner == null
                      ? EmptyStateView(
                          icon: Icons.delivery_dining_rounded,
                          title: 'Not a delivery partner yet',
                          description:
                              'Register to pick up ready Degloor orders. Admin verifies new riders before they can go online.',
                          buttonText: 'Register now',
                          onTap: _register,
                        )
                      : RefreshIndicator(
                          color: theme.primary,
                          onRefresh: () => _load(reset: true),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(theme.designToken.spacing.md),
                            children: [
                              _statusCard(theme),
                              SizedBox(height: theme.designToken.spacing.lg),
                              Text(
                                'Active task',
                                style: theme.titleMedium.override(
                                  font: GoogleFonts.inter(),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: theme.designToken.spacing.sm),
                              if (_assignment == null || _activeOrder == null)
                                Text(
                                  'No active delivery. Accept a ready order below.',
                                  style: theme.bodyMedium.override(
                                    font: GoogleFonts.inter(),
                                    color: theme.secondaryText,
                                  ),
                                )
                              else
                                _activeTaskCard(theme),
                              SizedBox(height: theme.designToken.spacing.lg),
                              Text(
                                'Available orders',
                                style: theme.titleMedium.override(
                                  font: GoogleFonts.inter(),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: theme.designToken.spacing.sm),
                              if (_ready.isEmpty)
                                Text(
                                  'No ready orders right now.',
                                  style: theme.bodyMedium.override(
                                    font: GoogleFonts.inter(),
                                    color: theme.secondaryText,
                                  ),
                                )
                              else
                                ..._ready.map(_readyCard),
                              if (_hasMore)
                                LoadMoreControl(
                                  loading: _loadingMore,
                                  onPressed: () => _load(),
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

  Widget _statusCard(FlutterFlowTheme theme) {
    final partner = _partner!;
    return Container(
      padding: EdgeInsets.all(theme.designToken.spacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.lg),
        border: Border.all(color: theme.alternate),
        boxShadow: [theme.designToken.shadow.sm],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _model.isOnline ? 'Online' : 'Offline',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.inter(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: partner.isVerified ? theme.success : theme.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        partner.isVerified
                            ? 'Verified partner'
                            : 'Pending verification',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: _model.isOnline,
            onChanged: _toggleAvailability,
            activeThumbColor: theme.primary,
          ),
        ],
      ),
    );
  }

  Widget _activeTaskCard(FlutterFlowTheme theme) {
    final order = _activeOrder!;
    final assignment = _assignment!;
    final shop = _shops[order.businessId];
    final phone = _customer?.phoneNumber;
    return OrderListCard(
      title: shop?.name ?? 'Active delivery',
      orderId: order.id,
      createdAt: order.createdAt,
      totalAmount: order.totalAmount,
      status: order.status,
      subtitle: _customer?.fullName,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Assignment: ${assignment.status.replaceAll('_', ' ')}',
            style: theme.labelSmall,
          ),
          if (phone != null && phone.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final opened = await WhatsAppService.launchWhatsApp(
                  phoneNumber: phone,
                  message:
                      'Hello, this is your delivery partner regarding order #${order.id.substring(0, 8)} on DEGLOOR ONE.',
                );
                  if (!opened) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(WhatsAppService.unableToOpenMessage),
                      ),
                    );
                  }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: theme.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WhatsApp customer',
                    style: theme.labelMedium.override(
                      font: GoogleFonts.inter(),
                      color: theme.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (assignment.status == 'assigned')
            FFButtonWidget(
              onPressed: () => _confirmPickup(assignment.id),
              text: 'Confirm pickup',
              options: FFButtonOptions(
                width: double.infinity,
                height: 44,
                color: theme.primary,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                borderRadius: BorderRadius.circular(theme.designToken.radius.md),
              ),
            ),
          if (assignment.status == 'picked_up')
            FFButtonWidget(
              onPressed: () => _confirmDelivery(order.id),
              text: 'Confirm delivery',
              options: FFButtonOptions(
                width: double.infinity,
                height: 44,
                color: theme.success,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                borderRadius: BorderRadius.circular(theme.designToken.radius.md),
              ),
            ),
        ],
      ),
    );
  }

  Widget _readyCard(PlacedOrder order) {
    final shop = _shops[order.businessId];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OrderListCard(
        title: shop?.name ?? 'Ready for pickup',
        orderId: order.id,
        createdAt: order.createdAt,
        totalAmount: order.totalAmount,
        status: order.status,
        footer: FFButtonWidget(
          onPressed: () => _acceptOrder(order.id),
          text: 'Accept',
          options: FFButtonOptions(
            width: double.infinity,
            height: 40,
            color: FlutterFlowTheme.of(context).primary,
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            borderRadius: BorderRadius.circular(
              FlutterFlowTheme.of(context).designToken.radius.md,
            ),
          ),
        ),
      ),
    );
  }
}
