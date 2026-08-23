import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import '/components/action_tile/action_tile_widget.dart';
import '/components/completeness_card/completeness_card_widget.dart';
import '/components/stat_card/stat_card_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_charts.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/shop.dart';
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
  Shop? _business;
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final currentUser = currentUserUid;
    if (currentUser == '') {
      safeSetState(() => _isLoading = false);
      return;
    }

    try {
      final businesses = await DiscoveryService.instance.ownedBy(currentUser);
      if (businesses.isEmpty) {
        safeSetState(() => _isLoading = false);
        return;
      }

      final business = businesses.first;
      final insights = await DiscoveryService.instance.insightsFor(business.id);
      final pending = await OrderService.instance.pendingCount(business.id);
      if (!mounted) return;

      setState(() {
        _business = business;
        _totalReviews = insights.reviewCount;
        _profileViews = insights.profileViews;
        _callClicks = insights.callClicks;
        _whatsappClicks = insights.whatsappClicks;
        _directionsClicks = insights.directionsClicks;
        _pendingOrders = pending;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error fetching analytics', e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  ProfileCompleteness get _completeness =>
      BusinessService.completeness(_business);

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_business == null) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: EmptyStateView(
          icon: Icons.storefront_outlined,
          title: 'No shop yet',
          description:
              'Register your business to see pending orders and Degloor insights.',
          buttonText: 'Register business',
          onTap: () => context.pushNamed('BusinessRegistration'),
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
          onPressed: () {
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
          icon: const Icon(
            Icons.edit_rounded,
            color: Colors.white,
            size: 24.0,
          ),
          elevation: 0.0,
          label: Text(
            'Quick Edit',
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 24.0, 20.0, 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
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
                                      children: [
                                        Container(
                                          width: 8.0,
                                          height: 8.0,
                                          decoration: BoxDecoration(
                                            color: (_business?.isVerified ?? false)
                                                ? FlutterFlowTheme.of(context).success
                                                : FlutterFlowTheme.of(context).warning,
                                            borderRadius:
                                                BorderRadius.circular(9999.0),
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
                                      ].divide(const SizedBox(width: 4.0)),
                                    ),
                                  ].divide(const SizedBox(height: 4.0)),
                                ),
                                Row(
                                  children: [
                                    FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 8.0,
                                      buttonSize: 44.0,
                                      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                      icon: Icon(
                                        Icons.logout_rounded,
                                        color: FlutterFlowTheme.of(context).error,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Sign Out'),
                                            content: const Text('Are you sure you want to sign out?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Sign Out'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await authManager.signOut();
                                          if (context.mounted) {
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
                                      alignment: const AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        _business != null && _business!.name.trim().isNotEmpty
                                            ? _business!.name.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase()
                                            : 'DH',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FlutterFlowTheme.of(context)
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
                                  ].divide(const SizedBox(width: 8.0)),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
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
                          Row(
                            children: [
                              Expanded(
                                child: wrapWithModel(
                                  model: _model.statCardModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: StatCardWidget(
                                    hasTrend: false,
                                    icon: Icon(
                                      Icons.visibility_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 20.0,
                                    ),
                                    label: 'Profile Views',
                                    trend: '',
                                    value: '$_profileViews',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: wrapWithModel(
                                  model: _model.statCardModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: StatCardWidget(
                                    hasTrend: false,
                                    icon: Icon(
                                      Icons.contact_phone_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 20.0,
                                    ),
                                    label: 'Calls',
                                    trend: '',
                                    value: '$_callClicks',
                                  ),
                                ),
                              ),
                            ].divide(const SizedBox(width: 16.0)),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: wrapWithModel(
                                  model: _model.statCardModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: StatCardWidget(
                                    hasTrend: false,
                                    icon: Icon(
                                      Icons.chat_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 20.0,
                                    ),
                                    label: 'WhatsApp',
                                    trend: '',
                                    value: '$_whatsappClicks',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: wrapWithModel(
                                  model: _model.statCardModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: StatCardWidget(
                                    hasTrend: false,
                                    icon: Icon(
                                      Icons.near_me_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 20.0,
                                    ),
                                    label: 'Directions',
                                    trend: '',
                                    value: '$_directionsClicks',
                                  ),
                                ),
                              ),
                            ].divide(const SizedBox(width: 16.0)),
                          ),
                        ].divide(const SizedBox(height: 16.0)),
                      ),
                      wrapWithModel(
                        model: _model.completenessCardModel,
                        updateCallback: () => safeSetState(() {}),
                        child: CompletenessCardWidget(
                          hint: _completeness.hint,
                          percent: '${_completeness.percent}',
                          progressVal: _completeness.ratio,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Engagement',
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
                              SizedBox(
                                height: 180.0,
                                child: FlutterFlowBarChart(
                                  barData: [
                                    FFBarChartData(
                                      yData: [
                                        45.0,
                                        67.0,
                                        32.0,
                                        89.0,
                                        54.0,
                                        76.0,
                                        90.0
                                      ],
                                      color: FlutterFlowTheme.of(context).primary,
                                    )
                                  ],
                                  xLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                                  barWidth: 24.0,
                                  barBorderRadius: BorderRadius.circular(4.0),
                                  groupSpace: 12.0,
                                  alignment: BarChartAlignment.spaceEvenly,
                                  chartStylingInfo: const ChartStylingInfo(
                                    backgroundColor: Colors.transparent,
                                    showBorder: false,
                                  ),
                                  axisBounds: const AxisBounds(
                                    minY: 0.0,
                                    maxX: 6.0,
                                    maxY: 108.0,
                                  ),
                                  xAxisLabelInfo: AxisLabelInfo(
                                    showLabels: true,
                                    labelTextStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily: GoogleFonts.inter().fontFamily,
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          fontSize: 10.0,
                                        ),
                                    reservedSize: 20.0,
                                  ),
                                  yAxisLabelInfo: const AxisLabelInfo(
                                    reservedSize: 0.0,
                                  ),
                                ),
                              ),
                            ].divide(const SizedBox(height: 16.0)),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Store Management',
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontWeight: FontWeight.bold,
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
                                subtitle: 'Add or edit products in your digital store',
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
                                  Icons.shopping_bag_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20.0,
                                ),
                                subtitle: _pendingOrders > 0
                                    ? 'You have $_pendingOrders pending orders'
                                    : 'View and fulfill customer orders',
                                title: AppLocalizations.of(context)!.manageOrders,
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
                                subtitle: 'Set your weekly opening and closing times',
                                title: 'Business Hours',
                              ),
                            ),
                          ),
                          wrapWithModel(
                            model: _model.actionTileModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: InkWell(
                              onTap: () async {
                                if (_business != null) {
                                  await context.pushNamed(
                                    'EditBusinessProfile',
                                    extra: {'business': _business},
                                  );
                                  _fetchData();
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
                          wrapWithModel(
                            model: _model.actionTileModel10,
                            updateCallback: () => safeSetState(() {}),
                            child: InkWell(
                              onTap: () => context.pushNamed('ManageJobs'),
                              child: ActionTileWidget(
                                icon: Icon(
                                  Icons.work_outline_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20.0,
                                ),
                                subtitle: 'Hire local talent for your business',
                                title: 'Manage Jobs',
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(height: 16.0)),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Marketing & Growth',
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          wrapWithModel(
                            model: _model.actionTileModel9,
                            updateCallback: () => safeSetState(() {}),
                            child: InkWell(
                              onTap: () => context.pushNamed(
                                'BusinessAnalytics',
                                queryParameters: {
                                  'businessId': serializeParam(
                                    _business!.id,
                                    ParamType.string,
                                  ),
                                }.withoutNulls,
                              ),
                              child: ActionTileWidget(
                                icon: Icon(
                                  Icons.analytics_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20.0,
                                ),
                                subtitle: 'View detailed visitor charts',
                                title: 'Detailed Insights',
                              ),
                            ),
                          ),
                          wrapWithModel(
                            model: _model.actionTileModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: InkWell(
                              onTap: () async {
                                if (_business != null) {
                                  await context.pushNamed(
                                    'EditBusinessProfile',
                                    extra: {'business': _business},
                                  );
                                  _fetchData();
                                }
                              },
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
                          ),
                          wrapWithModel(
                            model: _model.actionTileModel3,
                            updateCallback: () => safeSetState(() {}),
                            child: InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Offers feature coming soon!')),
                                );
                              },
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
                          ),
                          wrapWithModel(
                            model: _model.actionTileModel4,
                            updateCallback: () => safeSetState(() {}),
                            child: InkWell(
                              onTap: () {
                                if (_business != null) {
                                  context.pushNamed(
                                    'BusinessProfile',
                                    queryParameters: {
                                      'businessId': serializeParam(
                                        _business!.id,
                                        ParamType.string,
                                      ),
                                    }.withoutNulls,
                                  );
                                }
                              },
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
                          ),
                          wrapWithModel(
                            model: _model.actionTileModel5,
                            updateCallback: () => safeSetState(() {}),
                            child: InkWell(
                              onTap: () {
                                final isVerified = _business?.isVerified ?? false;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isVerified
                                        ? 'Your business is verified!'
                                        : 'Your verification is being processed by the admin.'),
                                  ),
                                );
                              },
                              child: ActionTileWidget(
                                icon: Icon(
                                  Icons.verified_user_rounded,
                                  color: (_business?.isVerified ?? false)
                                      ? FlutterFlowTheme.of(context).success
                                      : FlutterFlowTheme.of(context).primary,
                                  size: 20.0,
                                ),
                                subtitle: (_business?.isVerified ?? false)
                                    ? 'Your documents are up to date'
                                    : 'Awaiting verification from admin',
                                title: 'Verification Status',
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(height: 16.0)),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const BrandMark(size: 56),
                            const SizedBox(height: 8),
                            Text(
                              'DEGLOOR ONE Business Portal',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).onSurface,
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
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).onSurface,
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
                          ].divide(const SizedBox(height: 4.0)),
                        ),
                      ),
                    ].divide(const SizedBox(height: 24.0)),
                  ),
                ),
                const SizedBox(height: 80.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
