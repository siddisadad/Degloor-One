import '/backend/supabase/supabase.dart';
import '/components/action_item/action_item_widget.dart';
import '/components/button/button_widget.dart';
import '/components/category_chip/category_chip_widget.dart';
import '/components/stat_card2/stat_card2_widget.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  Future<List<BusinessesRow>> fetchVerificationQueue() async {
    return await BusinessesTable().queryRows(
      queryFn: (q) => q.eq('is_verified', false).order('created_at', ascending: false),
    );
  }

  Future<List<ComplaintsRow>> fetchPendingComplaints() async {
    return await ComplaintsTable().queryRows(
      queryFn: (q) => q.eq('status', 'pending').order('created_at', ascending: false),
    );
  }

  Future<void> _resolveComplaint(ComplaintsRow complaint) async {
    await ComplaintsTable().update(
      data: {'status': 'resolved'},
      matchingRows: (q) => q.eq('id', complaint.id),
    );

    // Send notification to user
    await NotificationsTable().insert({
      'user_id': complaint.userId,
      'title': 'Complaint Resolved',
      'message': 'Your complaint regarding "${complaint.subject}" has been resolved.',
      'type': 'complaint_resolved',
      'is_read': false,
    });

    safeSetState(() {});
  }

  Future<List<BusinessCategoriesRow>> fetchCategories() async {
    return await BusinessCategoriesTable().queryRows(
      queryFn: (q) => q.order('display_order', ascending: true),
    );
  }

  Future<int> fetchCount(bool verified) async {
    final response = await Supabase.instance.client
        .from('businesses')
        .select('*', const FetchOptions(count: CountOption.exact, head: true))
        .eq('is_verified', verified);
    return response.count ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminControlPanelModel());
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
                      Row(
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
                                'Admin Control',
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w800,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w800,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .fontStyle,
                                      lineHeight: 1.3,
                                    ),
                              ),
                              Text(
                                'Degloor Discovery Management',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                      lineHeight: 1.5,
                                    ),
                              ),
                            ].divide(SizedBox(height: 4.0)),
                          ),
                          Container(
                            width: 44.0,
                            height: 44.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Text(
                              'AD',
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
                                    color:
                                        FlutterFlowTheme.of(context).onPrimary,
                                    fontSize: 16.72,
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
                      ),
                      FutureBuilder<List<int>>(
                        future: Future.wait([fetchCount(false), fetchCount(true)]),
                        builder: (context, snapshot) {
                          final pendingCount = snapshot.data?[0] ?? 0;
                          final verifiedCount = snapshot.data?[1] ?? 0;
                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: wrapWithModel(
                                  model: _model.statCardModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: StatCard2Widget(
                                    label: 'Pending Claims',
                                    trend: '',
                                    value: pendingCount.toString(),
                                    isPositive: false,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: wrapWithModel(
                                  model: _model.statCardModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: StatCard2Widget(
                                    label: 'Verified',
                                    trend: '',
                                    value: verifiedCount.toString(),
                                    isPositive: true,
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
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Verification Queue',
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontStyle,
                                      lineHeight: 1.4,
                                    ),
                              ),
                              wrapWithModel(
                                model: _model.buttonModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: ButtonWidget(
                                  iconPresent: false,
                                  iconEndPresent: false,
                                  content: 'View All',
                                  variant: 'ghost',
                                  size: 'small',
                                  fullWidth: false,
                                  loading: false,
                                  disabled: false,
                                ),
                              ),
                            ],
                          ),
                          FutureBuilder<List<BusinessesRow>>(
                            future: fetchVerificationQueue(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(child: Text('No pending verifications', style: FlutterFlowTheme.of(context).bodyMedium));
                              }
                              final businesses = snapshot.data!;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: businesses.map((business) => ActionItemWidget(
                                  icon: Icon(
                                    Icons.store_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                  statusBg: Color(0xFFFFF3E0),
                                  statusLabel: 'PENDING',
                                  statusText: Color(0xFFE65100),
                                  subtitle: 'Owner: ${business.ownerName ?? 'Unknown'}',
                                  title: business.name,
                                  onApprove: () async {
                                    await BusinessesTable().update(
                                      data: {'is_verified': true},
                                      matchingRows: (q) => q.eq('id', business.id),
                                    );
                                    safeSetState(() {});
                                  },
                                )).toList().divide(SizedBox(height: 16.0)),
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
                            'User Complaints',
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontWeight: FontWeight.bold,
                                  lineHeight: 1.4,
                                ),
                          ),
                          FutureBuilder<List<ComplaintsRow>>(
                            future: fetchPendingComplaints(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(child: Text('No pending complaints', style: FlutterFlowTheme.of(context).bodyMedium));
                              }
                              final complaints = snapshot.data!;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: complaints.map((complaint) => ActionItemWidget(
                                  icon: Icon(
                                    Icons.report_problem_rounded,
                                    color: FlutterFlowTheme.of(context).error,
                                    size: 24.0,
                                  ),
                                  statusBg: Color(0xFFFFEBEE),
                                  statusLabel: 'PENDING',
                                  statusText: FlutterFlowTheme.of(context).error,
                                  subtitle: complaint.description,
                                  title: complaint.subject,
                                  onApprove: () => _resolveComplaint(complaint),
                                )).toList().divide(SizedBox(height: 16.0)),
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
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Active Categories',
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontStyle,
                                      lineHeight: 1.4,
                                    ),
                              ),
                              InkWell(
                                onTap: () async {
                                  String? newCategoryName;
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Add New Category'),
                                      content: TextField(
                                        onChanged: (val) => newCategoryName = val,
                                        decoration: InputDecoration(hintText: "Category name"),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (newCategoryName != null && newCategoryName!.isNotEmpty) {
                                              await BusinessCategoriesTable().insert({
                                                'name': newCategoryName,
                                              });
                                              Navigator.pop(context);
                                              safeSetState(() {});
                                            }
                                          },
                                          child: Text('Add'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: wrapWithModel(
                                  model: _model.buttonModel2,
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
                                    content: 'Add New',
                                    variant: 'secondary',
                                    size: 'small',
                                    fullWidth: false,
                                    loading: false,
                                    disabled: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          FutureBuilder<List<BusinessCategoriesRow>>(
                            future: fetchCategories(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(child: Text('No categories found', style: FlutterFlowTheme.of(context).bodyMedium));
                              }
                              final categories = snapshot.data!;
                              return Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                direction: Axis.horizontal,
                                runAlignment: WrapAlignment.start,
                                verticalDirection: VerticalDirection.down,
                                clipBehavior: Clip.none,
                                children: categories.map((category) => CategoryChipWidget(
                                  icon: Icon(
                                    Icons.category_rounded,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    size: 18.0,
                                  ),
                                  name: category.name,
                                )).toList(),
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
                            'User Complaints',
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontWeight: FontWeight.bold,
                                  lineHeight: 1.4,
                                ),
                          ),
                          FutureBuilder<List<ComplaintsRow>>(
                            future: fetchPendingComplaints(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(child: Text('No pending complaints', style: FlutterFlowTheme.of(context).bodyMedium));
                              }
                              final complaints = snapshot.data!;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: complaints.map((complaint) => ActionItemWidget(
                                  icon: Icon(
                                    Icons.report_problem_rounded,
                                    color: FlutterFlowTheme.of(context).error,
                                    size: 24.0,
                                  ),
                                  statusBg: Color(0xFFFFEBEE),
                                  statusLabel: 'PENDING',
                                  statusText: FlutterFlowTheme.of(context).error,
                                  subtitle: complaint.description,
                                  title: complaint.subject,
                                  onApprove: () => _resolveComplaint(complaint),
                                )).toList().divide(SizedBox(height: 16.0)),
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
                            'Recent Audit Activity',
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                          Container(
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.history_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .onSurface,
                                          size: 20.0,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Admin \'Suresh\' approved \'Mainak Bakery\'',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          '2m ago',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .onSurface,
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
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                    Divider(
                                      height: 16.0,
                                      thickness: 1.0,
                                      indent: 0.0,
                                      endIndent: 0.0,
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.history_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .onSurface,
                                          size: 20.0,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'System suspended \'Quick Fix Plumbing\' (Reported)',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          '1h ago',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .onSurface,
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
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                    Divider(
                                      height: 16.0,
                                      thickness: 1.0,
                                      indent: 0.0,
                                      endIndent: 0.0,
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.history_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .onSurface,
                                          size: 20.0,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'New category \'Building Materials\' created',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          '4h ago',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .onSurface,
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
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Platform Search Volume',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                Container(
                                  height: 180.0,
                                  child: Container(
                                    height: 180.0,
                                    child: FlutterFlowBarChart(
                                      barData: [
                                        FFBarChartData(
                                          yData: ([
                                            45.0,
                                            78.0,
                                            56.0,
                                            89.0,
                                            64.0,
                                            92.0,
                                            70.0
                                          ]),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                        )
                                      ],
                                      xLabels: ([
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                        'Sun'
                                      ]),
                                      barWidth: 24.0,
                                      barBorderRadius:
                                          BorderRadius.circular(4.0),
                                      groupSpace: 12.0,
                                      alignment: BarChartAlignment.spaceEvenly,
                                      chartStylingInfo: ChartStylingInfo(
                                        backgroundColor: Colors.transparent,
                                        showGrid: true,
                                        showBorder: false,
                                      ),
                                      axisBounds: AxisBounds(
                                        minY: 0.0,
                                        maxX: 6.0,
                                        maxY: 110.39999999999999,
                                      ),
                                      xAxisLabelInfo: AxisLabelInfo(
                                        showLabels: true,
                                        labelTextStyle: FlutterFlowTheme.of(
                                                context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 10.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontStyle,
                                              lineHeight: 1.0,
                                            ),
                                        reservedSize: 20.0,
                                      ),
                                      yAxisLabelInfo: AxisLabelInfo(
                                        reservedSize: 0.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 32.0,
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
