import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/components/action_item/action_item_widget.dart';
import 'package:degloor_one/components/category_chip/category_chip_widget.dart';
import 'package:degloor_one/components/stat_card2/stat_card2_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_charts.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop verified successfully!'),
            backgroundColor: DegloorTheme.success,
          ),
        );
      }
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
          backgroundColor: DegloorTheme.error,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint resolved.'),
            backgroundColor: DegloorTheme.success,
          ),
        );
      }
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
          backgroundColor: DegloorTheme.error,
        ),
      );
    }
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Pharmacy',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              try {
                await _model.addCategory(
                  userId: currentUserUid,
                  name: name,
                  onBusyChanged: () {
                    if (mounted) safeSetState(() {});
                  },
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (e) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLogger.userFacingMessage(
                        e,
                        fallback: 'Unable to add the category.',
                      ),
                    ),
                    backgroundColor: DegloorTheme.error,
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
      backgroundColor: DegloorTheme.background,
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
        backgroundColor: DegloorTheme.background,
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
          backgroundColor: DegloorTheme.background,
          appBar: AppBar(
            backgroundColor: DegloorTheme.cardBackground,
            automaticallyImplyLeading: false,
            leading: degloorBackButton(context),
            title: Text('Admin Control', style: DegloorTheme.headingMedium),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: const BoxDecoration(
                    color: DegloorTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              labelColor: DegloorTheme.primary,
              unselectedLabelColor: DegloorTheme.textSecondary,
              indicatorColor: DegloorTheme.primary,
              indicatorWeight: 3,
              labelStyle: DegloorTheme.labelMedium.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: DegloorTheme.labelMedium,
              tabs: const [
                Tab(text: 'Verify'),
                Tab(text: 'Complaints'),
                Tab(text: 'System'),
              ],
            ),
            elevation: 0.0,
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: TabBarView(
                  children: [
                    _buildVerifyTab(),
                    _buildComplaintsTab(),
                    _buildSystemTab(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DegloorTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard2Widget(
                  label: 'Pending',
                  trend: '',
                  value: _model.counts.pending.toString(),
                  isPositive: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard2Widget(
                  label: 'Verified',
                  trend: '',
                  value: _model.counts.verified.toString(),
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _sectionHeader('Registration Queue'),
          const SizedBox(height: 12),
          if (_model.verificationQueue.isEmpty)
            const EmptyStateView(
              icon: Icons.verified_user_outlined,
              title: 'Queue is clear',
              description: 'New Degloor shops will show up here for verification.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _model.verificationQueue.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final business = _model.verificationQueue[index];
                return ActionItemWidget(
                  icon: const Icon(Icons.store_rounded, color: DegloorTheme.primary),
                  statusBg: DegloorTheme.warning.withValues(alpha: 0.1),
                  statusLabel: 'BUSINESS',
                  statusText: DegloorTheme.warning,
                  subtitle: 'Owner: ${business.ownerName ?? 'Unknown'}',
                  title: business.name,
                  onApprove: () => _verifyBusiness(business),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildComplaintsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DegloorTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader('Reported Listings'),
          const SizedBox(height: 12),
          if (_model.pendingComplaints.isEmpty)
            const EmptyStateView(
              icon: Icons.report_problem_outlined,
              title: 'No pending reports',
              description: 'Customer reports from Degloor shops will land here.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _model.pendingComplaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final complaint = _model.pendingComplaints[index];
                return ActionItemWidget(
                  icon: const Icon(Icons.report_problem_rounded, color: DegloorTheme.error),
                  statusBg: DegloorTheme.error.withValues(alpha: 0.1),
                  statusLabel: 'PENDING',
                  statusText: DegloorTheme.error,
                  subtitle: complaint.description,
                  title: complaint.subject,
                  onApprove: () => _resolveComplaint(complaint),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DegloorTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _sectionHeader('Categories')),
              IconButton(
                onPressed: _addCategory,
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: DegloorTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _model.categories
                .map((c) => CategoryChipWidget(
                      icon: const Icon(Icons.category_rounded,
                          color: DegloorTheme.textSecondary, size: 16),
                      name: c.name,
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          _sectionHeader('Platform Activity'),
          const SizedBox(height: 16),
          Container(
            height: 180.0,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DegloorTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DegloorTheme.border),
            ),
            child: FlutterFlowBarChart(
              barData: const [
                FFBarChartData(
                  yData: [45, 78, 56, 89, 64, 92, 70],
                  color: DegloorTheme.primary,
                )
              ],
              xLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
              xAxisLabelInfo: const AxisLabelInfo(
                showLabels: true,
                labelTextStyle: TextStyle(color: DegloorTheme.textSecondary, fontSize: 9),
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
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: DegloorTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
