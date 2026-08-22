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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Profile Section
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
                        children: [
                          Expanded(
                            child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w800,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      lineHeight: 1.3,
                                    ),
                              ),
                              Text(
                                'Manage your profile and reports',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      lineHeight: 1.5,
                                    ),
                              ),
                            ],
                          ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 48.0,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Text(
                              initials.isEmpty ? 'U' : initials,
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                    color:
                                        FlutterFlowTheme.of(context).onPrimary,
                                    fontSize: 18.0,
                                  ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Stats Section
                  FutureBuilder<List<ComplaintsRow>>(
                    future: _model.complaintsFuture,
                    builder: (context, snapshot) {
                      final complaints = snapshot.data ?? [];
                      final resolvedCount = complaints
                          .where((c) => c.status == 'resolved')
                          .length;
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              '${complaints.length}',
                              'Reports',
                              FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              '$resolvedCount',
                              'Resolved',
                              FlutterFlowTheme.of(context).success,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Quick Links
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOption(
                        context,
                        _model.profileOptionModel1,
                        Icons.shopping_bag_rounded,
                        'My Orders',
                        onTap: () => context.pushNamed('CustomerOrders'),
                      ),
                      _buildOption(
                        context,
                        _model.profileOptionModel2,
                        Icons.shopping_cart_rounded,
                        'My Cart',
                        onTap: () => context.pushNamed('Cart'),
                      ),
                      _buildOption(
                        context,
                        _model.profileOptionModel10,
                        Icons.handyman_outlined,
                        'Find Services',
                        onTap: () => context.pushNamed('Services'),
                      ),
                    ].divide(const SizedBox(height: 12)),
                  ),

                  // Settings Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.savedLocations,
                        style:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold),
                                ),
                      ),
                      _buildOption(
                        context,
                        _model.profileOptionModel3,
                        Icons.person_outline_rounded,
                        'Personal Information',
                        subtitle: 'Name, Email, Phone number',
                      ),
                      _buildOption(
                        context,
                        _model.profileOptionModel4,
                        Icons.location_on_outlined,
                        'Saved Locations',
                        subtitle: 'Home, Work, Other places',
                        onTap: () => context.pushNamed('AddressList'),
                      ),
                      _buildOption(
                        context,
                        _model.profileOptionModel5,
                        Icons.notifications_none_rounded,
                        'Notifications',
                        subtitle: 'Alerts, Business updates',
                      ),
                      _buildOption(
                        context,
                        _model.profileOptionModel6,
                        Icons.security_rounded,
                        'Privacy & Security',
                        subtitle: 'Password, Data usage',
                      ),
                      _buildOption(
                        context,
                        _model.profileOptionModel7,
                        Icons.language_rounded,
                        'Change Language',
                        subtitle: 'English, मराठी, हिन्दी',
                        onTap: () => _showLanguageSelector(context),
                      ),
                    ].divide(const SizedBox(height: 16.0)),
                  ),

                  // Reports List
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Reports',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold),
                                ),
                          ),
                          wrapWithModel(
                            model: _model.buttonModel1,
                            updateCallback: () => setState(() {}),
                            child: const ButtonWidget(
                              icon: Icon(Icons.add_rounded, size: 24.0),
                              iconPresent: true,
                              content: 'New Report',
                              variant: 'ghost',
                              size: 'small',
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<List<ComplaintsRow>>(
                        future: _model.complaintsFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
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
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: ReportItemWidget(
                                  businessName: complaint.subject,
                                  date: dateTimeFormat(
                                      'MMM d, yyyy', complaint.createdAt),
                                  reason: complaint.description,
                                  status: complaint.status,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ].divide(const SizedBox(height: 16.0)),
                  ),

                  // Support & Sign Out
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Support',
                        style:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold),
                                ),
                      ),
                      _buildOption(
                        context,
                        _model.profileOptionModel8,
                        Icons.help_outline_rounded,
                        'Help Center',
                        subtitle: 'FAQ and contact support',
                      ),
                      _buildOption(
                        context,
                        _model.profileOptionModel9,
                        Icons.description_outlined,
                        'Terms of Service',
                        subtitle: 'Legal and usage agreements',
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () async {
                          await authManager.signOut();
                          if (context.mounted) context.goNamed('Authentication');
                        },
                        child: wrapWithModel(
                          model: _model.buttonModel2,
                          updateCallback: () => setState(() {}),
                          child: ButtonWidget(
                            icon: Icon(
                              Icons.logout_rounded,
                              color: FlutterFlowTheme.of(context).error,
                              size: 24.0,
                            ),
                            iconPresent: true,
                            content: 'Sign Out',
                            variant: 'outline',
                            size: 'large',
                            fullWidth: true,
                          ),
                        ),
                      ),
                    ].divide(const SizedBox(height: 16.0)),
                  ),
                ].divide(const SizedBox(height: 32.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String value, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  color: color,
                ),
          ),
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, ProfileOptionModel model,
      IconData icon, String title,
      {String? subtitle, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: wrapWithModel(
        model: model,
        updateCallback: () => setState(() {}),
        child: ProfileOptionWidget(
          icon: Icon(icon,
              color: FlutterFlowTheme.of(context).primaryText, size: 24),
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Language / भाषा निवडा',
                style: FlutterFlowTheme.of(context).headlineSmall),
            const SizedBox(height: 16),
            _buildLangItem(context, 'English', 'en'),
            _buildLangItem(context, 'मराठी (Marathi)', 'mr'),
            _buildLangItem(context, 'हिन्दी (Hindi)', 'hi'),
          ],
        ),
      ),
    );
  }

  Widget _buildLangItem(BuildContext context, String label, String code) {
    final isSelected = FFAppState.instance.locale == code;
    return ListTile(
      title: Text(label),
      onTap: () {
        FFAppState.instance.locale = code;
        Navigator.pop(context);
        setState(() {});
      },
      trailing: isSelected
          ? Icon(Icons.check, color: FlutterFlowTheme.of(context).primary)
          : null,
    );
  }
}
