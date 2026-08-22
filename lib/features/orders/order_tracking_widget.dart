import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/otp_copy.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    _model.orderFuture = OrdersTable().queryRows(
      queryFn: (q) => q.eq('id', widget.orderId).eq('user_id', currentUserUid),
    );
    _model.orderItemsFuture = OrderItemsTable().queryRows(
      queryFn: (q) => q.eq('order_id', widget.orderId),
    );
    _model.historyFuture = OrderStatusHistoryTable().queryRows(
      queryFn: (q) => q.eq('order_id', widget.orderId).order('created_at', ascending: false),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  int _getStatusIndex(String status) => OrderLifecycle.stepperIndex(status);

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
            'Track Order',
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
        body: StreamBuilder<List<OrdersRow>>(
          stream: OrdersTable().stream(
            primaryKey: 'id',
            queryFn: (q) =>
                q.eq('id', widget.orderId).eq('user_id', currentUserUid),
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: 'Order not found',
                description: 'This order is missing or belongs to another account.',
                buttonText: 'My orders',
                onTap: () => context.goNamed('CustomerOrders'),
              );
            }

            final order = snapshot.data!.first;
            final statusIndex = _getStatusIndex(order.status);
            final isCancelled = order.status.toLowerCase() == 'cancelled';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCancelled)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: FlutterFlowTheme.of(context).error),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cancel_rounded, color: FlutterFlowTheme.of(context).error),
                            const SizedBox(width: 12),
                            Text(
                              'This order was cancelled.',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context).error,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    // Status Stepper
                    if (!isCancelled) _buildStatusStepper(statusIndex),

                    const SizedBox(height: 32),

                    // OTP is fetched via RPC so partners cannot read it from the orders row.
                    if (order.status.toLowerCase() != 'pending' && order.status.toLowerCase() != 'delivered' && order.status.toLowerCase() != 'cancelled')
                      FutureBuilder<String?>(
                        future: DeliveryService.fetchMyDeliveryOtp(order.id),
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
                        context.pushNamed('UserProfileReports');
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
                        borderSide: BorderSide(color: FlutterFlowTheme.of(context).error),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusStepper(int currentIndex) {
    final statuses = ['Placed', 'Accepted', 'Ready', 'On the Way', 'Delivered'];
    return Column(
      children: List.generate(statuses.length, (index) {
        final isCompleted = index <= currentIndex;
        final isLast = index == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? FlutterFlowTheme.of(context).primary : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? FlutterFlowTheme.of(context).primary : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statuses[index],
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(),
                          fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted ? FlutterFlowTheme.of(context).primaryText : Colors.grey,
                        ),
                  ),
                  if (index == currentIndex)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'This step is in progress or completed.',
                        style: FlutterFlowTheme.of(context).labelSmall,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOtpCard(String? otp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FlutterFlowTheme.of(context).primary),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.vpn_key_rounded, color: FlutterFlowTheme.of(context).primary),
              const SizedBox(width: 12),
              Text(
                'Delivery Verification OTP',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            otp ?? '----',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            OtpCopy.deliveryHint,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryPartnerInfo(String orderId) {
    return FutureBuilder<List<DeliveryAssignmentsRow>>(
      future: DeliveryAssignmentsTable().querySingleRow(
        queryFn: (q) => q.eq('order_id', orderId).neq('status', 'delivered'),
      ),
      builder: (context, assignmentSnapshot) {
        final assignment = assignmentSnapshot.data?.firstOrNull;
        if (assignment == null) return Container();

        return StreamBuilder<List<DeliveryPartnersRow>>(
          stream: DeliveryPartnersTable().stream(
            primaryKey: 'id',
            queryFn: (q) => q.eq('id', assignment.deliveryPartnerId),
          ),
          builder: (context, partnerSnapshot) {
            final partner = partnerSnapshot.data?.firstOrNull;
            if (partner == null) return Container();

            return FutureBuilder<List<UsersRow>>(
              future: UsersTable().querySingleRow(
                queryFn: (q) => q.eq('id', partner.userId),
              ),
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
                            if (user?.phoneNumber != null && user!.phoneNumber!.trim().isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_rounded,
                                    color: Colors.green),
                                onPressed: () =>
                                    WhatsAppService.launchWhatsApp(
                                  phoneNumber: user.phoneNumber!.trim(),
                                  message:
                                      'Hello, I am tracking my order #${orderId.substring(0, 8)}.',
                                ),
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

  Widget _buildBusinessInfo(String businessId, OrdersRow order) {
    return FutureBuilder<List<BusinessesRow>>(
      future: BusinessesTable().querySingleRow(
        queryFn: (q) => q.eq('id', businessId),
      ),
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
                  child: CachedNetworkImage(
                    imageUrl: business.imageUrl ?? 'https://images.unsplash.com/photo-1534723452862-4c874018d66d?auto=format&fit=crop&w=100&h=100&q=80',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
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
                      icon: const Icon(Icons.call_rounded, color: Colors.blue),
                      onPressed: () {
                        if (business.phoneNumber != null && business.phoneNumber!.isNotEmpty) {
                          launchURL('tel:${business.phoneNumber}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Phone number not available')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_rounded, color: Colors.green),
                      onPressed: () {
                        if (business.whatsappNumber != null && business.whatsappNumber!.isNotEmpty) {
                          WhatsAppService.launchWhatsApp(
                            phoneNumber: business.whatsappNumber!,
                            message: 'Hello, I have a query regarding my order #${widget.orderId.substring(0, 8)}.',
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('WhatsApp not available')),
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

  Widget _buildOrderSummary(OrdersRow order) {
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
        FutureBuilder<List<Map<String, dynamic>>>(
          future: kUseShowcaseData
              ? Future.value(ShowcaseCatalog.orderItemsWithProducts(order.id))
              : SupaFlow.client
                  .from('order_items')
                  .select('*, products(*)')
                  .eq('order_id', order.id)
                  .then((v) => List<Map<String, dynamic>>.from(v)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LinearProgressIndicator());
            }
            final items = snapshot.data ?? [];
            return Column(
              children: items.map((item) {
                final product = item['products'] as Map<String, dynamic>?;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item['quantity']}x ${product?['name'] ?? 'Item'}'),
                      Text('₹${((item['price_at_purchase'] as num) * (item['quantity'] as num)).toStringAsFixed(2)}'),
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
            Text('Delivery Fee', style: FlutterFlowTheme.of(context).labelMedium),
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
