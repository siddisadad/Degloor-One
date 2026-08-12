import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/action_tile/action_tile_widget.dart';
import 'package:degloor_one/components/completeness_card/completeness_card_widget.dart';
import 'package:degloor_one/components/stat_card/stat_card_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import '../../flutter_flow/flutter_flow_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'business_dashboard_model.dart';
export 'business_dashboard_model.dart';

class BusinessDashboardWidget extends StatefulWidget {
  const BusinessDashboardWidget({super.key});

  static String routeName = 'BusinessDashboard';
  static String routePath = '/businessDashboard';

  @override
  State<BusinessDashboardWidget> createState() =>
      _BusinessDashboardWidgetState();
}

class _BusinessDashboardWidgetState extends State<BusinessDashboardWidget> {
  late BusinessDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  BusinessesRow? _business;
  int _totalReviews = 0;
  int _profileViews = 0;
  int _callClicks = 0;
  int _whatsappClicks = 0;
  int _directionsClicks = 0;
  int _pendingOrders = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessDashboardModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAnalytics());
  }

  Future<void> _fetchAnalytics() async {
    final currentUser = currentUserUid;
    if (currentUser == '') return;

    try {
      // 1. Fetch Business
      final businesses = await BusinessesTable().queryRows(
        queryFn: (q) => q.eq('owner_id', currentUser),
      );

      if (businesses.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      _business = businesses.first;

      // 2. Fetch Reviews
      final reviews = await ReviewsTable().queryRows(
        queryFn: (q) => q.eq('business_id', _business!.id),
      );

      // 3. Fetch Business Analytics
      final analytics = await SupaFlow.client
          .from('business_analytics')
          .select('event_type')
          .eq('business_id', _business!.id);

      final List<dynamic> events = analytics as List<dynamic>;
      int views = 0;
      int calls = 0;
      int whatsapp = 0;
      int directions = 0;

      for (var e in events) {
        final type = e['event_type'] as String;
        if (type == 'PROFILE_VIEW') views++;
        else if (type == 'CALL_CLICK') calls++;
        else if (type == 'WHATSAPP_CLICK') whatsapp++;
        else if (type == 'DIRECTIONS_CLICK') directions++;
      }

      // 4. Fetch Pending Orders
      final pendingOrders = await OrdersTable().queryRows(
        queryFn: (q) => q.eq('business_id', _business!.id).eq('status', 'pending'),
      );

      if (!mounted) return;

      setState(() {
        _totalReviews = reviews.length;
        _profileViews = views;
        _callClicks = calls;
        _whatsappClicks = whatsapp;
        _directionsClicks = directions;
        _pendingOrders = pendingOrders.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching analytics: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  double _calculateCompleteness() {
    if (_business == null) return 0.0;
    int score = 0;
    int total = 100;

    // 1. Basic Info (25%)
    if (_business!.name.trim().isNotEmpty) score += 10;
    if ((_business!.description ?? '').trim().isNotEmpty) score += 15;

    // 2. Contact & Category (20%)
    if ((_business!.categoryId ?? '').isNotEmpty) score += 10;
    if ((_business!.whatsappNumber ?? '').trim().isNotEmpty) score += 10;

    // 3. Location (35%)
    if ((_business!.addressText ?? '').trim().isNotEmpty) score += 15;
    if (_business!.latitude != 0 && _business!.longitude != 0) score += 20;

    // 4. Visuals (20%)
    if ((_business!.imageUrl ?? '').trim().isNotEmpty) score += 20;

    return score / total;
  }

  String _getCompletenessHint() {
    if (_business == null) return '';
    if ((_business!.imageUrl ?? '').isEmpty) return 'Add business photos to reach 100%';
    if ((_business!.description ?? '').isEmpty) return 'Describe what you provide to help customers find you';
    if ((_business!.addressText ?? '').isEmpty) return 'Add your shop address for better visibility';
    if (_business!.latitude == 0) return 'Pin your location on the map for accurate delivery';
    return 'Your profile looks great!';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_business == null) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No business registered with this account.'),
              SizedBox(height: 16),
              FFButtonWidget(
                onPressed: () => context.pushNamed('BusinessRegistration'),
                text: 'Register Business',
                options: FFButtonOptions(
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (_business != null) {
              context.pushNamed(
                'EditBusinessProfile',
                extra: <String, dynamic>{
                  'business': _business,
                },
              );
            }
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          icon: Icon(
            Icons.edit_rounded,
            color: FlutterFlowTheme.of(context).onPrimary,
            size: 24.0,
          ),
          elevation: 0.0,
          label: Text(
            'Quick Edit',
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.inter(
                    fontWeight:
                        FlutterFlowTheme.of(context).labelLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).onPrimary,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).labelLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  lineHeight: 1.4,
                ),
          ),
        ),
        body: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 24.0, 20.0, 24.0),
                      child: Container(
                        child: Row(
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
                                  _business?.name ?? 'Dashboard',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w800,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineSmall
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w800,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .fontStyle,
                                        lineHeight: 1.3,
                                      ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 8.0,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: (_business?.isVerified ?? false)
                                            ? FlutterFlowTheme.of(context)
                                                .success
                                            : FlutterFlowTheme.of(context)
                                                .warning,
                                        borderRadius:
                                            BorderRadius.circular(9999.0),
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    Text(
                                      (_business?.isVerified ?? false)
                                          ? 'Verified Business'
                                          : 'Pending Verification',
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
                                            color: FlutterFlowTheme.of(context)
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
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                              ].divide(SizedBox(height: 4.0)),
                            ),
                            Row(
                              children: <Widget>[
                                FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 8.0,
                                  buttonSize: 44.0,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  icon: Icon(
                                    Icons.logout_rounded,
                                    color: FlutterFlowTheme.of(context).error,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Sign Out'),
                                        content: Text(
                                            'Are you sure you want to sign out?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text('Sign Out'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await authManager.signOut();
                                      if (mounted) {
                                        context.goNamed('Authentication');
                                      }
                                    }
                                  },
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
                                    'DH',
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
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                          lineHeight: 1.4,
                                        ),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 1.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).alternate,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insights',
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.statCardModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: StatCardWidget(
                                      hasTrend: false,
                                      icon: Icon(
                                        Icons.visibility_rounded,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        size: 20.0,
                                      ),
                                      label: 'Views',
                                      trend: '',
                                      value: '$_profileViews',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.statCardModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: StatCardWidget(
                                      hasTrend: false,
                                      icon: Icon(
                                        Icons.call_rounded,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        size: 20.0,
                                      ),
                                      label: 'Calls',
                                      trend: '',
                                      value: '$_callClicks',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.statCardModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: StatCardWidget(
                                      hasTrend: false,
                                      icon: Icon(
                                        Icons.chat_rounded,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        size: 20.0,
                                      ),
                                      label: 'WhatsApp',
                                      trend: '',
                                      value: '$_whatsappClicks',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.statCardModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: StatCardWidget(
                                      hasTrend: false,
                                      icon: Icon(
                                        Icons.near_me_rounded,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        size: 20.0,
                                      ),
                                      label: 'Directions',
                                      trend: '',
                                      value: '$_directionsClicks',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                    wrapWithModel(
                      model: _model.completenessCardModel,
                      updateCallback: () => safeSetState(() {}),
                      child: CompletenessCardWidget(
                        hint: _getCompletenessHint(),
                        percent: '${(_calculateCompleteness() * 100).toInt()}',
                        progressVal: _calculateCompleteness(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Store Management',
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: GoogleFonts.inter().fontFamily,
                                fontWeight: FontWeight.bold,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                        ),
                        wrapWithModel(
                          model: _model.actionTileModel10,
                          updateCallback: () => safeSetState(() {}),
                          child: InkWell(
                            onTap: () => context.pushNamed(
                              'BusinessAnalytics',
                              queryParameters: {
                                'businessId': _business!.id,
                              }.withoutNulls,
                            ),
                            child: ActionTileWidget(
                              icon: Icon(
                                Icons.analytics_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              subtitle: 'Detailed engagement and visitor stats',
                              title: 'Detailed Insights',
                            ),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.actionTileModel8,
                          updateCallback: () => safeSetState(() {}),
                          child: InkWell(
                            onTap: () => context.pushNamed('ManageHours'),
                            child: ActionTileWidget(
                              icon: Icon(
                                Icons.access_time_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              subtitle: 'Set weekly opening and closing times',
                              title: 'Business Hours',
                            ),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.actionTileModel6,
                          updateCallback: () => safeSetState(() {}),
                          child: InkWell(
                            onTap: () => context.pushNamed('ManageCatalogue'),
                            child: ActionTileWidget(
                              icon: Icon(
                                Icons.inventory_2_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              subtitle: 'Add products and manage prices',
                              title: 'Manage Catalogue',
                            ),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.actionTileModel7,
                          updateCallback: () => safeSetState(() {}),
                          child: InkWell(
                            onTap: () => context.pushNamed('ManageOrders'),
                            child: ActionTileWidget(
                              icon: Icon(
                                Icons.receipt_long_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              subtitle: _pendingOrders > 0
                                  ? 'You have $_pendingOrders pending orders'
                                  : 'View and track customer orders',
                              title: 'Orders',
                            ),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.actionTileModel9,
                          updateCallback: () => safeSetState(() {}),
                          child: InkWell(
                            onTap: () => context.pushNamed('ManageJobs'),
                            child: ActionTileWidget(
                              icon: Icon(
                                Icons.work_history_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              subtitle: 'Post vacancies and view applicants',
                              title: 'Manage Jobs',
                            ),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.actionTileModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: InkWell(
                            onTap: () {
                              if (_business != null) {
                                context.pushNamed(
                                  'EditBusinessProfile',
                                  extra: {'business': _business},
                                );
                              }
                            },
                            child: ActionTileWidget(
                              icon: Icon(
                                Icons.edit_note_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              subtitle: 'Update address and contact info',
                              title: 'Edit Profile',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Marketing & Growth',
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: GoogleFonts.inter().fontFamily,
                                fontWeight: FontWeight.bold,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                        ),
                        wrapWithModel(
                          model: _model.actionTileModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: ActionTileWidget(
                            icon: Icon(
                              Icons.add_a_photo_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 20.0,
                            ),
                            subtitle: 'Show your workspace and products',
                            title: 'Add Photos',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.actionTileModel3,
                          updateCallback: () => safeSetState(() {}),
                          child: ActionTileWidget(
                            icon: Icon(
                              Icons.campaign_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 20.0,
                            ),
                            subtitle: 'Post a discount or seasonal deal',
                            title: 'Create Offer',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.actionTileModel4,
                          updateCallback: () => safeSetState(() {}),
                          child: ActionTileWidget(
                            icon: Icon(
                              Icons.star_outline_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 20.0,
                            ),
                            subtitle: 'See what customers are saying',
                            title: 'Reviews ($_totalReviews)',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.actionTileModel5,
                          updateCallback: () => safeSetState(() {}),
                          child: ActionTileWidget(
                            icon: Icon(
                              Icons.verified_user_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 20.0,
                            ),
                            subtitle: 'Your documents are up to date',
                            title: 'Verification Status',
                          ),
                        ),
                      ].divide(const SizedBox(height: 12.0)),
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 20.0),
                        child: Container(
                          child: Container(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'DEGLOOR ONE Business Portal',
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
                                        color: FlutterFlowTheme.of(context)
                                            .onSurface,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                        lineHeight: 1.2,
                                      ),
                                ),
                                Text(
                                  'Deshmukh Technologies • Phase 1',
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
                                        color: FlutterFlowTheme.of(context)
                                            .onSurface,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
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
                  ].divide(SizedBox(height: 24.0)),
                ),
              ),
              Container(
                height: 80.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
