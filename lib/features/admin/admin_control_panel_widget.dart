import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/components/action_item/action_item_widget.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/category_chip/category_chip_widget.dart';
import 'package:degloor_one/components/stat_card2/stat_card2_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_charts.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_control_panel_model.dart';
export 'admin_control_panel_model.dart';

class AdminControlPanelWidget extends StatefulWidget {
  const AdminControlPanelWidget({super.key});

  static String routeName = 'AdminControlPanel';
  static String routePath = '/adminControlPanel';

  @override
  State<AdminControlPanelWidget> createState() =>
      _AdminControlPanelWidgetState();
}

class _AdminControlPanelWidgetState extends State<AdminControlPanelWidget> {
  late AdminControlPanelModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminControlPanelModel());
    _loadDesk();
  }

  Future<void> _loadDesk() async {
    await _model.load(
      userId: currentUserUid,
      onBusyChanged: () {
        if (mounted) safeSetState(() {});
      },
    );
  }

  Future<void> _verifyBusiness(Shop business) async {
    try {
      await _model.verifyBusiness(
        userId: currentUserUid,
        businessId: business.id,
        onBusyChanged: () {
          if (mounted) safeSetState(() {});
        },
      );
    } catch (e) {
      AppLogger.error('Error verifying business', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLogger.userFacingMessage(
              e,
              fallback: 'Unable to verify the shop. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _resolveComplaint(ListingComplaint complaint) async {
    try {
      await _model.resolveComplaint(
        userId: currentUserUid,
        complaintId: complaint.id,
        onBusyChanged: () {
          if (mounted) safeSetState(() {});
        },
      );
    } catch (e) {
      AppLogger.error('Error resolving complaint', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLogger.userFacingMessage(
              e,
              fallback: 'Unable to resolve the complaint. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _addCategory() async {
    String? newCategoryName;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(onChanged: (val) => newCategoryName = val),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _model.addCategory(
                  userId: currentUserUid,
                  name: newCategoryName ?? '',
                  onBusyChanged: () {
                    if (mounted) safeSetState(() {});
                  },
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLogger.userFacingMessage(
                        e,
                        fallback:
                            'Unable to add the category. Please try again.',
                      ),
                    ),
                  ),
                );
              }
            },
            child: const Text('Add'),
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

  Widget _gate({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: EmptyStateView(
        icon: icon,
        title: title,
        description: description,
        buttonText: 'Go home',
        onTap: () => context.goNamed('CustomerHome'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_model.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_model.isSignedOut) {
      return _gate(
        icon: Icons.lock_outline_rounded,
        title: 'Please sign in',
        description: 'Sign in with an administrator account to open this desk.',
      );
    }
    if (_model.isAccessDenied) {
      return _gate(
        icon: Icons.lock_outline_rounded,
        title: 'Admin only',
        description: 'This desk is for Degloor One administrators.',
      );
    }
    if (_model.hasError) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Unable to load the desk',
          description: 'The verification queues could not be loaded.',
          buttonText: 'Retry',
          onTap: _loadDesk,
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            automaticallyImplyLeading: false,
            leading: degloorBackButton(
              context,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
            title: Text(
              'Admin Control',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Text(
                    'AD',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          color: FlutterFlowTheme.of(context).onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              labelColor: FlutterFlowTheme.of(context).primary,
              unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
              indicatorColor: FlutterFlowTheme.of(context).primary,
              tabs: const [
                Tab(icon: Icon(Icons.verified_user_rounded), text: 'Verify'),
                Tab(icon: Icon(Icons.report_problem_rounded), text: 'Complaints'),
                Tab(icon: Icon(Icons.settings_rounded), text: 'System'),
              ],
            ),
            elevation: 0.0,
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: TabBarView(
            children: [
              // Verification Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: wrapWithModel(
                            model: _model.statCardModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: StatCard2Widget(
                              label: 'Pending',
                              trend: '',
                              value: _model.counts.pending.toString(),
                              isPositive: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: wrapWithModel(
                            model: _model.statCardModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: StatCard2Widget(
                              label: 'Verified',
                              trend: '',
                              value: _model.counts.verified.toString(),
                              isPositive: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_model.verificationQueue.isEmpty)
                      const EmptyStateView(
                        icon: Icons.verified_user_outlined,
                        title: 'Queue is clear',
                        description:
                            'New Degloor shops will show up here for verification.',
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Business Queue', style: FlutterFlowTheme.of(context).titleMedium),
                          const SizedBox(height: 12),
                          ..._model.verificationQueue.map((business) => ActionItemWidget(
                                icon: Icon(Icons.store_rounded, color: FlutterFlowTheme.of(context).primary),
                                statusBg: const Color(0xFFFFF3E0),
                                statusLabel: 'BUSINESS',
                                statusText: const Color(0xFFE65100),
                                subtitle: 'Owner: ${business.ownerName ?? 'Unknown'}',
                                title: business.name,
                                onApprove: () => _verifyBusiness(business),
                              )),
                        ].divide(const SizedBox(height: 12)),
                      ),
                    const SizedBox(height: 24),
                    /* Removed Provider Queue UI */
                  ],
                ),
              ),
              // Complaints Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _model.pendingComplaints.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.report_problem_outlined,
                        title: 'No pending complaints',
                        description:
                            'Customer reports from Degloor shops will land here.',
                      )
                    : Column(
                        children: _model.pendingComplaints
                            .map((complaint) => ActionItemWidget(
                                  icon: Icon(Icons.report_problem_rounded, color: FlutterFlowTheme.of(context).error),
                                  statusBg: const Color(0xFFFFEBEE),
                                  statusLabel: 'PENDING',
                                  statusText: FlutterFlowTheme.of(context).error,
                                  subtitle: complaint.description,
                                  title: complaint.subject,
                                  onApprove: () => _resolveComplaint(complaint),
                                ))
                            .toList()
                            .divide(const SizedBox(height: 16)),
                      ),
              ),
              // System Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Categories', style: FlutterFlowTheme.of(context).titleMedium),
                        wrapWithModel(
                          model: _model.buttonModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: ButtonWidget(
                            icon: const Icon(Icons.add_rounded, size: 20),
                            iconPresent: true,
                            content: 'Add',
                            variant: 'secondary',
                            size: 'small',
                            onTap: _addCategory,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _model.categories
                          .map((c) => CategoryChipWidget(
                                icon: Icon(Icons.category_rounded, color: FlutterFlowTheme.of(context).secondaryText, size: 16),
                                name: c.name,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                    Text('Platform Activity', style: FlutterFlowTheme.of(context).titleMedium),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180.0,
                      child: FlutterFlowBarChart(
                        barData: [
                          FFBarChartData(
                            yData: [45, 78, 56, 89, 64, 92, 70],
                            color: FlutterFlowTheme.of(context).primary,
                          )
                        ],
                        xLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                        xAxisLabelInfo: AxisLabelInfo(
                          showLabels: true,
                          labelTextStyle: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: GoogleFonts.inter().fontFamily,
                                fontSize: 10,
                              ),
                          reservedSize: 24,
                        ),
                        yAxisLabelInfo: const AxisLabelInfo(
                          showLabels: true,
                          reservedSize: 32,
                        ),
                        barWidth: 16,
                        barBorderRadius: BorderRadius.circular(4),
                        alignment: BarChartAlignment.spaceEvenly,
                        chartStylingInfo: const ChartStylingInfo(
                          backgroundColor: Colors.transparent,
                          showBorder: false,
                        ),
                        axisBounds: const AxisBounds(minY: 0, maxY: 100, minX: 0, maxX: 6),
                      ),
                    ),
                  ].divide(const SizedBox(height: 16)),
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
}
