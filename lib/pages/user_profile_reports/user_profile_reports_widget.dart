import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/button/button_widget.dart';

import '/components/profile_option/profile_option_widget.dart';
import '/components/report_item/report_item_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_profile_reports_model.dart';
export 'user_profile_reports_model.dart';

class UserProfileReportsWidget extends StatefulWidget {
  const UserProfileReportsWidget({super.key});

  static String routeName = 'UserProfileReports';
  static String routePath = '/userProfileReports';

  @override
  State<UserProfileReportsWidget> createState() =>
      _UserProfileReportsWidgetState();
}

class _UserProfileReportsWidgetState extends State<UserProfileReportsWidget> {
  late UserProfileReportsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileReportsModel());
    _model.userProfileFuture = UsersTable().queryRows(
      queryFn: (q) => q.eq('id', currentUserUid),
    );
    _model.ordersFuture = OrdersTable().queryRows(
      queryFn: (q) => q.eq('user_id', currentUserUid).order('created_at', ascending: false),
    );
    _model.complaintsFuture = ComplaintsTable().queryRows(
      queryFn: (q) => q.eq('user_id', currentUserUid).order('created_at', ascending: false),
    );
  }

  Future<void> _showReportDialog({String? orderId, String? businessId}) async {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isEmpty || descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              await ComplaintsTable().insert({
                'user_id': currentUserUid,
                'order_id': orderId,
                'business_id': businessId,
                'subject': subjectController.text,
                'description': descriptionController.text,
                'status': 'pending',
              });
              Navigator.pop(context);
              safeSetState(() {
                _model.complaintsFuture = ComplaintsTable().queryRows(
                  queryFn: (q) => q.eq('user_id', currentUserUid).order('created_at', ascending: false),
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Report submitted successfully')),
              );
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showOrderTimeline(String orderId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Timeline'),
        content: Container(
          width: double.maxFinite,
          child: FutureBuilder<List<OrderStatusHistoryRow>>(
            future: OrderStatusHistoryTable().queryRows(
              queryFn: (q) => q
                  .eq('order_id', orderId)
                  .order('created_at', ascending: true),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return Text('No status history found.');
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 20,
                        ),
                      ],
                    ),
                    title: Text(
                      item.status,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.notes != null)
                          Text(
                            item.notes!,
                            style: FlutterFlowTheme.of(context).labelSmall,
                          ),
                        Text(
                          dateTimeFormat('MMM d, HH:mm', item.createdAt),
                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                font: GoogleFonts.inter(),
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(24.0),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FutureBuilder<List<UsersRow>>(
                        future: _model.userProfileFuture,
                        builder: (context, snapshot) {
                          final userRow = snapshot.data?.firstOrNull;
                          final fullName = userRow?.fullName ?? 'User Name';
                          final initials = fullName
                              .split(' ')
                              .take(2)
                              .map((e) => e.isNotEmpty ? e[0] : '')
                              .join()
                              .toUpperCase();

                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName,
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w800,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .headlineMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w800,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                  ),
                                  Text(
                                    'Manage your profile and reports',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          lineHeight: 1.5,
                                        ),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                              Container(
                                width: 48.0,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  initials.isEmpty ? 'U' : initials,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .onPrimary,
                                        fontSize: 18.24,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      FutureBuilder<List<ComplaintsRow>>(
                        future: _model.complaintsFuture,
                        builder: (context, snapshot) {
                          final complaints = snapshot.data ?? [];
                          final resolvedCount = complaints.where((c) => c.status == 'resolved').length;
                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(12.0),
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${complaints.length}',
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .titleLarge
                                                            .fontStyle,
                                                  ),
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .titleLarge
                                                          .fontStyle,
                                                  lineHeight: 1.4,
                                                ),
                                          ),
                                          Text(
                                            'Reports',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(context)
                                                            .labelSmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(context)
                                                          .labelSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .labelSmall
                                                          .fontStyle,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 4.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(12.0),
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$resolvedCount',
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .titleLarge
                                                            .fontStyle,
                                                  ),
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .success,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .titleLarge
                                                          .fontStyle,
                                                  lineHeight: 1.4,
                                                ),
                                          ),
                                          Text(
                                            'Resolved',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(context)
                                                            .labelSmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(context)
                                                          .labelSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .labelSmall
                                                          .fontStyle,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 4.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 16.0)),
                          );
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Order History',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontWeight: FontWeight.bold,
                                  lineHeight: 1.4,
                                ),
                          ),
                          FutureBuilder<List<OrdersRow>>(
                            future: _model.ordersFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final orders = snapshot.data!;
                              if (orders.isEmpty) {
                                return Text(
                                  'No orders found.',
                                  style: FlutterFlowTheme.of(context).labelSmall,
                                );
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: orders.map((order) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                        borderRadius: BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context).alternate,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Order #${order.id.substring(0, 8)}',
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                      ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: order.status == 'delivered'
                                                        ? FlutterFlowTheme.of(context).success20
                                                        : FlutterFlowTheme.of(context).primary30,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    order.status.toUpperCase(),
                                                    style: FlutterFlowTheme.of(context).labelSmall.override(
                                                          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                          fontSize: 10,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (order.status.toLowerCase() == 'out_for_delivery' || order.status.toLowerCase() == 'shipping' || order.status.toLowerCase() == 'shipped')
                                              Padding(
                                                padding: EdgeInsets.only(top: 8.0),
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.vpn_key_rounded, size: 16, color: FlutterFlowTheme.of(context).primary),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Delivery OTP: ${order.deliveryOtp ?? 'N/A'}',
                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                              font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                              color: FlutterFlowTheme.of(context).primary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  dateTimeFormat('MMM d, yyyy', order.createdAt),
                                                  style: FlutterFlowTheme.of(context).labelSmall,
                                                ),
                                                Text(
                                                  '₹${order.totalAmount}',
                                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                                        font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                        color: FlutterFlowTheme.of(context).primary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 12.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  InkWell(
                                                    onTap: () => _showOrderTimeline(order.id),
                                                    child: Text(
                                                      'View Timeline',
                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                            font: GoogleFonts.inter(),
                                                            color: FlutterFlowTheme.of(context).primary,
                                                            decoration: TextDecoration.underline,
                                                          ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                        onTap: () => _showReportDialog(orderId: order.id),
                                                        child: Container(
                                                          height: 32,
                                                          padding: EdgeInsets.symmetric(horizontal: 12),
                                                          decoration: BoxDecoration(
                                                            color: FlutterFlowTheme.of(context).error,
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            'Report Issue',
                                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                                  color: Colors.white,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      if (order.status == 'delivered')
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 8.0),
                                                          child: InkWell(
                                                            onTap: () async {
                                                              context.pushNamed(
                                                                'BusinessProfile',
                                                                queryParameters: {
                                                                  'businessId': serializeParam(
                                                                    order.businessId,
                                                                    ParamType.String,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 32,
                                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                                              decoration: BoxDecoration(
                                                                color: FlutterFlowTheme.of(context).primary,
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              alignment: Alignment.center,
                                                              child: Text(
                                                                'Rate Order',
                                                                style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                      font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                                      color: FlutterFlowTheme.of(context).info,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Account Settings',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                          InkWell(
                            onTap: () async {
                              print('Personal Information clicked');
                            },
                            child: wrapWithModel(
                              model: _model.profileOptionModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: ProfileOptionWidget(
                                icon: Icon(
                                  Icons.person_outline_rounded,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 20.0,
                                ),
                                subtitle: 'Name, Email, Phone number',
                                title: 'Personal Information',
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              context.pushNamed('LocationRadiusSelector');
                            },
                            child: wrapWithModel(
                              model: _model.profileOptionModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: ProfileOptionWidget(
                                icon: Icon(
                                  Icons.location_on_outlined,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 20.0,
                                ),
                                subtitle: 'Home, Work, Other places',
                                title: 'Saved Locations',
                              ),
                            ),
                          ),
                          wrapWithModel(
                            model: _model.profileOptionModel3,
                            updateCallback: () => safeSetState(() {}),
                            child: ProfileOptionWidget(
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 20.0,
                              ),
                              subtitle: 'Alerts, Business updates',
                              title: 'Notifications',
                            ),
                          ),
                          wrapWithModel(
                            model: _model.profileOptionModel4,
                            updateCallback: () => safeSetState(() {}),
                            child: ProfileOptionWidget(
                              icon: Icon(
                                Icons.security_rounded,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 20.0,
                              ),
                              subtitle: 'Password, Data usage',
                              title: 'Privacy & Security',
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              context.pushNamed('DeliveryDashboard');
                            },
                            child: wrapWithModel(
                              model: _model.profileOptionModel7,
                              updateCallback: () => safeSetState(() {}),
                              child: ProfileOptionWidget(
                                icon: Icon(
                                  Icons.delivery_dining_rounded,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  size: 20.0,
                                ),
                                subtitle: 'Manage your deliveries',
                                title: 'Switch to Delivery Mode',
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'My Reports',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                      lineHeight: 1.4,
                                    ),
                              ),
                              wrapWithModel(
                                model: _model.buttonModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: ButtonWidget(
                                  icon: Icon(
                                    Icons.add_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                  iconPresent: true,
                                  iconEndPresent: false,
                                  content: 'New Report',
                                  variant: 'ghost',
                                  size: 'small',
                                  fullWidth: false,
                                  loading: false,
                                  disabled: false,
                                ),
                              ),
                            ],
                          ),
                          FutureBuilder<List<ComplaintsRow>>(
                            future: _model.complaintsFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(child: CircularProgressIndicator());
                              }
                              final complaints = snapshot.data!;
                              if (complaints.isEmpty) {
                                return Text(
                                  'No reports filed yet.',
                                  style: FlutterFlowTheme.of(context).labelSmall,
                                );
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: complaints.map((complaint) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.0),
                                    child: ReportItemWidget(
                                      businessName: complaint.subject,
                                      date: dateTimeFormat('MMM d, yyyy', complaint.createdAt),
                                      reason: complaint.description,
                                      status: complaint.status,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Support',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                          wrapWithModel(
                            model: _model.profileOptionModel5,
                            updateCallback: () => safeSetState(() {}),
                            child: ProfileOptionWidget(
                              icon: Icon(
                                Icons.help_outline_rounded,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 20.0,
                              ),
                              subtitle: 'FAQ and contact support',
                              title: 'Help Center',
                            ),
                          ),
                          wrapWithModel(
                            model: _model.profileOptionModel6,
                            updateCallback: () => safeSetState(() {}),
                            child: ProfileOptionWidget(
                              icon: Icon(
                                Icons.description_outlined,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 20.0,
                              ),
                              subtitle: 'Legal and usage agreements',
                              title: 'Terms of Service',
                            ),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 24.0, 0.0, 40.0),
                        child: Container(
                          child: Container(
                            child: InkWell(
                              onTap: () async {
                                await authManager.signOut();
                                context.goNamed('Authentication');
                              },
                              child: wrapWithModel(
                                model: _model.buttonModel2,
                                updateCallback: () => safeSetState(() {}),
                                child: ButtonWidget(
                                  icon: Icon(
                                    Icons.logout_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                  iconPresent: true,
                                  iconEndPresent: false,
                                  content: 'Sign Out',
                                  variant: 'outline',
                                  size: 'small',
                                  fullWidth: true,
                                  loading: false,
                                  disabled: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ].divide(SizedBox(height: 24.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
