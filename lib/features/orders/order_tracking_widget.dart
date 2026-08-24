import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/order_status_chip.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:degloor_one/shared/delivery_assignment.dart';
import 'package:degloor_one/shared/delivery_partner.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/shared/placed_order.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'order_tracking_model.dart';
export 'order_tracking_model.dart';

class OrderTrackingWidget extends StatefulWidget {
  const OrderTrackingWidget({
    super.key,
    required this.orderId,
  });

  final String orderId;

  static String routeName = 'OrderTracking';
  static String routePath = '/orderTracking';

  @override
  State<OrderTrackingWidget> createState() => _OrderTrackingWidgetState();
}

class _OrderTrackingWidgetState extends State<OrderTrackingWidget> {
  late OrderTrackingModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderTrackingModel());
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
        appBar: degloorAppBar(context, title: 'Track order'),
        body: StreamBuilder<List<PlacedOrder>>(
          stream: OrderService.instance.watchUserOrder(
            orderId: widget.orderId,
            userId: currentUserUid,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: 'Order not found',
                description:
                    'This order is missing or belongs to another account.',
                buttonText: 'My orders',
                onTap: () => context.goNamed('CustomerOrders'),
              );
            }

            final order = snapshot.data!.first;
            final actions = OrderService.instance.customerActions(order.status);
            final statusIndex = actions.stepperIndex;
            final isCancelled = actions.isCancelled;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Order #${order.id.substring(0, 8)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.inter(),
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            OrderStatusChip(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (isCancelled)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .error
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                FlutterFlowTheme.of(context)
                                    .designToken
                                    .radius
                                    .lg,
                              ),
                              border: Border.all(
                                  color: FlutterFlowTheme.of(context).error),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.cancel_rounded,
                                    color: FlutterFlowTheme.of(context).error),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'This order was cancelled.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (actions.canCancel)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: FFButtonWidget(
                              onPressed: () async {
                                try {
                                  await OrderService.instance.cancelOrder(
                                    orderId: order.id,
                                    actorUserId: currentUserUid,
                                    reason: 'Cancelled by customer',
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLogger.userFacingMessage(
                                          e,
                                          fallback:
                                              'Unable to cancel the order. Please try again.',
                                        ),
                                      ),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).error,
                                    ),
                                  );
                                }
                              },
                              text: 'Cancel order',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 48,
                                color: FlutterFlowTheme.of(context).error,
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        // Status Stepper
                        if (actions.showStepper)
                          _buildStatusStepper(statusIndex),

                        const SizedBox(height: 32),

                        // OTP is fetched via RPC so partners cannot read it from the orders row.
                        if (actions.showDeliveryOtp)
                          FutureBuilder<String?>(
                            future: DeliveryService.instance
                                .fetchMyDeliveryOtp(order.id),
                            builder: (context, otpSnapshot) =>
                                _buildOtpCard(otpSnapshot.data),
                          ),

                        const SizedBox(height: 24),

                        // Delivery Partner Info
                        _buildDeliveryPartnerInfo(order.id),

                        const SizedBox(height: 24),

                        // Business Info
                        _buildBusinessInfo(order.businessId, order),

                        const SizedBox(height: 24),

                        // Order Summary
                        _buildOrderSummary(order),

                        const SizedBox(height: 32),

                        // Help / Report
                        FFButtonWidget(
                          onPressed: () {
                            context.pushNamed('MyProfile');
                          },
                          text: 'Report an Issue',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50,
                            color: Colors.transparent,
                            textStyle: TextStyle(
                              color: FlutterFlowTheme.of(context).error,
                              fontWeight: FontWeight.bold,
                            ),
                            borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusStepper(int currentIndex) {
    final statuses = [
      {'title': 'Order Placed', 'desc': 'We have received your order'},
      {'title': 'Accepted', 'desc': 'The shop has started preparing'},
      {'title': 'Ready', 'desc': 'Packed and waiting for pickup'},
      {'title': 'On the Way', 'desc': 'Rider is delivering your order'},
      {'title': 'Delivered', 'desc': 'Enjoy your purchase!'},
    ];

    return Container(
      padding: const EdgeInsets.all(DegloorTheme.spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        border: Border.all(color: DegloorTheme.border),
      ),
      child: Column(
        children: List.generate(statuses.length, (index) {
          final isCompleted = index <= currentIndex;
          final isLast = index == statuses.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color:
                            isCompleted ? DegloorTheme.success : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? DegloorTheme.success
                              : DegloorTheme.border,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check,
                              size: 12, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isCompleted
                              ? DegloorTheme.success
                              : DegloorTheme.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statuses[index]['title']!,
                          style: DegloorTheme.titleMedium.copyWith(
                            color: isCompleted
                                ? DegloorTheme.textPrimary
                                : DegloorTheme.textSecondary,
                            fontWeight:
                                isCompleted ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statuses[index]['desc']!,
                          style: DegloorTheme.bodySmall.copyWith(
                            color: isCompleted
                                ? DegloorTheme.textSecondary
                                : DegloorTheme.textSecondary
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOtpCard(String? otp) {
    return Container(
      padding: const EdgeInsets.all(DegloorTheme.spacingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DegloorTheme.primary,
            DegloorTheme.primary.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DegloorTheme.radiusLG),
        boxShadow: DegloorTheme.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            'DELIVERY CODE',
            style: DegloorTheme.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7), letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Text(
            otp ?? '----',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
            ),
            child: Text(
              'Share this code with the rider only',
              style: DegloorTheme.bodySmall
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryPartnerInfo(String orderId) {
    return FutureBuilder<DeliveryAssignment?>(
      future: DeliveryService.instance.activeAssignment(orderId),
      builder: (context, assignmentSnapshot) {
        final assignment = assignmentSnapshot.data;
        if (assignment == null) return Container();

        return StreamBuilder<List<DeliveryPartner>>(
          stream: DeliveryService.instance
              .watchPartner(assignment.deliveryPartnerId),
          builder: (context, partnerSnapshot) {
            final partner = partnerSnapshot.data?.firstOrNull;
            if (partner == null) return Container();

            return FutureBuilder<List<UserProfile>>(
              future: DiscoveryService.instance.profile(partner.userId),
              builder: (context, userSnapshot) {
                final user = userSnapshot.data?.firstOrNull;
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withValues(alpha: 0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  FlutterFlowTheme.of(context).primary,
                              child: const Icon(Icons.delivery_dining_rounded,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName ?? 'Delivery Partner',
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.inter(),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'Delivery Partner Assigned',
                                    style:
                                        FlutterFlowTheme.of(context).labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            if (user?.phoneNumber != null &&
                                user!.phoneNumber!.trim().isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.chat_bubble_rounded,
                                  color: FlutterFlowTheme.of(context).success,
                                ),
                                onPressed: () async {
                                  final opened =
                                      await WhatsAppService.launchWhatsApp(
                                    phoneNumber: user.phoneNumber!.trim(),
                                    message:
                                        'Hello, I am tracking my order #${orderId.substring(0, 8)}.',
                                  );
                                  if (!opened && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          WhatsAppService.unableToOpenMessage,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                        if (partner.currentLatitude != null &&
                            partner.currentLongitude != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 16,
                                    color:
                                        FlutterFlowTheme.of(context).primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Partner is active and tracking.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBusinessInfo(String businessId, PlacedOrder order) {
    return FutureBuilder<List<Shop>>(
      future: DiscoveryService.instance.businessesByIds([businessId]),
      builder: (context, snapshot) {
        final business = snapshot.data?.firstOrNull;
        if (business == null) return Container();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: FlutterFlowTheme.of(context).alternate),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child:
                        business.imageUrl == null || business.imageUrl!.isEmpty
                            ? ColoredBox(
                                color: FlutterFlowTheme.of(context)
                                    .primary
                                    .withValues(alpha: 0.08),
                                child: Icon(
                                  Icons.storefront_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              )
                            : CachedRemoteImage(
                                url: business.imageUrl!,
                                width: 60,
                                height: 60,
                                placeholderIcon: Icons.storefront_rounded,
                              ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        business.addressText ?? 'Degloor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).labelSmall,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.call_rounded,
                        color: FlutterFlowTheme.of(context).info,
                      ),
                      onPressed: () {
                        if (business.phoneNumber != null &&
                            business.phoneNumber!.isNotEmpty) {
                          launchURL('tel:${business.phoneNumber}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Phone number not available')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_rounded,
                        color: FlutterFlowTheme.of(context).success,
                      ),
                      onPressed: () async {
                        if (business.whatsappNumber != null &&
                            business.whatsappNumber!.isNotEmpty) {
                          final opened = await WhatsAppService.launchWhatsApp(
                            phoneNumber: business.whatsappNumber!,
                            message:
                                'Hello, I have a query regarding my order #${widget.orderId.substring(0, 8)}.',
                          );
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  WhatsAppService.unableToOpenMessage,
                                ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('WhatsApp not available')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(PlacedOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.inter(),
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<OrderLine>>(
          future: OrderService.instance.itemsWithProducts(order.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LinearProgressIndicator());
            }
            final items = snapshot.data ?? [];
            return Column(
              children: items.map((item) {
                final imageUrl = item.product?.imageUrl;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: imageUrl == null || imageUrl.isEmpty
                              ? ColoredBox(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withValues(alpha: 0.08),
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 20,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                )
                              : CachedRemoteImage(
                                  url: imageUrl,
                                  width: 40,
                                  height: 40,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${item.quantity}× ${item.product?.name ?? 'Item'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₹${item.lineTotal.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delivery Fee',
                style: FlutterFlowTheme.of(context).labelMedium),
            Text('₹${order.deliveryFee?.toStringAsFixed(2) ?? '0.00'}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.inter(),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '₹${order.totalAmount.toStringAsFixed(2)}',
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
