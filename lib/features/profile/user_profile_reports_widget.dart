import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/components/button/button_widget.dart';

import 'package:degloor_one/components/profile_option/profile_option_widget.dart';
import 'package:degloor_one/components/report_item/report_item_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
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
    if (loggedIn && currentUserUid.length > 10) {
      _model.userProfileFuture = UsersTable().queryRows(
        queryFn: (q) => q.eq('id', currentUserUid),
      );
      _model.complaintsFuture = ComplaintsTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', currentUserUid)
            .order('created_at', ascending: false),
      );
    }
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
                        children: [
                          InkWell(
                            onTap: () => context.pushNamed('CustomerOrders'),
                            child: wrapWithModel(
                              model: _model.profileOptionModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: ProfileOptionWidget(
                                icon: Icon(
                                  Icons.shopping_bag_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 24,
                                ),
                                title: 'My Orders',
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => context.pushNamed('Cart'),
                            child: wrapWithModel(
                              model: _model.profileOptionModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: ProfileOptionWidget(
                                icon: Icon(
                                  Icons.shopping_cart_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 24,
                                ),
                                title: 'My Cart',
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(height: 12)),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.savedLocations,
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
                              context.pushNamed('CustomerOrders');
                            },
                            child: wrapWithModel(
                              model: _model.profileOptionModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: ProfileOptionWidget(
                                icon: Icon(
                                  Icons.shopping_bag_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20.0,
                                ),
                                subtitle: 'History and active orders',
                                title: 'My Orders',
                              ),
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
                              context.pushNamed('AddressList');
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
                              await showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Select Language / भाषा निवडा',
                                        style: FlutterFlowTheme.of(context).headlineSmall,
                                      ),
                                      const SizedBox(height: 16),
                                      ListTile(
                                        title: const Text('English'),
                                        onTap: () {
                                          FFAppState.instance.locale = 'en';
                                          Navigator.pop(context);
                                        },
                                        trailing: FFAppState.instance.locale == 'en' ? Icon(Icons.check, color: FlutterFlowTheme.of(context).primary) : null,
                                      ),
                                      ListTile(
                                        title: const Text('मराठी (Marathi)'),
                                        onTap: () {
                                          FFAppState.instance.locale = 'mr';
                                          Navigator.pop(context);
                                        },
                                        trailing: FFAppState.instance.locale == 'mr' ? Icon(Icons.check, color: FlutterFlowTheme.of(context).primary) : null,
                                      ),
                                      ListTile(
                                        title: const Text('हिन्दी (Hindi)'),
                                        onTap: () {
                                          FFAppState.instance.locale = 'hi';
                                          Navigator.pop(context);
                                        },
                                        trailing: FFAppState.instance.locale == 'hi' ? Icon(Icons.check, color: FlutterFlowTheme.of(context).primary) : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: wrapWithModel(
                              model: _model.profileOptionModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: ProfileOptionWidget(
                                icon: Icon(
                                  Icons.language_rounded,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  size: 20.0,
                                ),
                                subtitle: 'English, मराठी, हिन्दी',
                                title: 'Change Language',
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
