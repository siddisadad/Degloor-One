import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/order_service.dart';
import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/action_card.dart';
import 'package:degloor_one/components/stat_card/stat_card_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_charts.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:flutter/material.dart';
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
  int _pendingOrders = 0;
  int _productCount = 0;
  Map<String, int> _dailyCounts = {};

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
      final catalog = await ShopService.instance.catalog(business.id);
      if (!mounted) return;

      setState(() {
        _business = business;
        _totalReviews = insights.reviewCount;
        _profileViews = insights.profileViews;
        _callClicks = insights.callClicks;
        _whatsappClicks = insights.whatsappClicks;
        _dailyCounts = insights.dailyCounts;
        _pendingOrders = pending;
        _productCount = catalog.products.length;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error fetching dashboard data', e);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: DegloorTheme.background,
        appBar: degloorAppBar(context, title: 'Dashboard'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_business == null) {
      return Scaffold(
        backgroundColor: DegloorTheme.background,
        appBar: degloorAppBar(context, title: 'Dashboard'),
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: DegloorTheme.background,
        appBar: degloorAppBar(
          context,
          title: 'Business Portal',
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: DegloorTheme.error),
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
                  if (!context.mounted) return;
                  await authManager.signOutToLogin(context);
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: RefreshIndicator(
                onRefresh: _fetchData,
                color: DegloorTheme.primary,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DegloorTheme.spacingMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      if (!(_business?.isVerified ?? false))
                        _buildVerificationAlert(),
                      if (_productCount == 0) _buildCataloguePrompt(),
                      
                      _sectionTitle('Quick Actions'),
                      const SizedBox(height: 12),
                      _buildActionGrid(),
                      
                      const SizedBox(height: 28),
                      _sectionTitle('Performance Snapshot'),
                      const SizedBox(height: 12),
                      _buildInsightsGrid(),
                      
                      const SizedBox(height: 24),
                      _buildWeeklyEngagement(),
                      
                      const SizedBox(height: 24),
                      _sectionTitle('Account & Settings'),
                      const SizedBox(height: 12),
                      _buildSecondaryActions(),
                      
                      const SizedBox(height: 40),
                      const Center(child: BrandMark(size: 48, compact: true)),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'DEGLOOR ONE Business Portal v2.0',
                          style: TextStyle(color: DegloorTheme.textSecondary, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DegloorTheme.cardBackground,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        boxShadow: DegloorTheme.softShadow,
        border: Border.all(color: DegloorTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [DegloorTheme.primary, Color(0xFF1A3A70)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _business!.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_business!.name, style: DegloorTheme.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      (_business!.isVerified ?? false) ? Icons.verified_rounded : Icons.info_outline_rounded,
                      size: 14,
                      color: (_business!.isVerified ?? false) ? DegloorTheme.success : DegloorTheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (_business!.isVerified ?? false) ? 'Verified Shop' : 'Verification Pending',
                      style: DegloorTheme.labelSmall.copyWith(
                        color: (_business!.isVerified ?? false) ? DegloorTheme.success : DegloorTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: DegloorTheme.primary),
            onPressed: () => context.pushNamed(
              'EditBusinessProfile',
              extra: {'business': _business},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationAlert() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        border: Border.all(color: DegloorTheme.secondary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: DegloorTheme.secondary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DegloorTheme.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_outlined, color: DegloorTheme.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Boost Your Visibility', style: DegloorTheme.titleSmall.copyWith(color: DegloorTheme.secondary)),
                    Text(
                      'Verification Pending',
                      style: DegloorTheme.labelSmall.copyWith(color: DegloorTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Verified shops appear higher in search results and gain more customer trust. Send your Shop Act or GST details to get started.',
            style: TextStyle(color: DegloorTheme.textPrimary, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => BusinessService.instance.contactSupportForVerification(_business!),
            style: ElevatedButton.styleFrom(
              backgroundColor: DegloorTheme.secondary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DegloorTheme.radiusSM)),
            ),
            child: const Text('Contact Support for Verification', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCataloguePrompt() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DegloorTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        border: Border.all(color: DegloorTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: DegloorTheme.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Your shop is empty. Add products to start selling!',
              style: TextStyle(color: DegloorTheme.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => context.pushNamed('ManageCatalogue'),
            child: const Text('Add Items'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        ActionCard(
          title: 'Catalogue',
          subtitle: '$_productCount Products',
          icon: Icons.inventory_2_rounded,
          onTap: () => context.pushNamed('ManageCatalogue'),
        ),
        ActionCard(
          title: 'Orders',
          subtitle: '$_pendingOrders Pending',
          icon: Icons.shopping_bag_rounded,
          badgeCount: _pendingOrders,
          onTap: () => context.pushNamed('ManageOrders'),
        ),
        ActionCard(
          title: 'Jobs',
          subtitle: 'Hire talent',
          icon: Icons.work_outline_rounded,
          onTap: () => context.pushNamed('ManageJobs'),
        ),
        ActionCard(
          title: 'Hours',
          subtitle: 'Set open times',
          icon: Icons.access_time_rounded,
          onTap: () => context.pushNamed('ManageHours'),
        ),
      ],
    );
  }

  Widget _buildInsightsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: [
        StatCardWidget(
          hasTrend: false,
          icon: const Icon(Icons.visibility_rounded, color: DegloorTheme.primary, size: 18),
          label: 'Total Views',
          value: '$_profileViews',
        ),
        StatCardWidget(
          hasTrend: false,
          icon: const Icon(Icons.chat_bubble_outline_rounded, color: DegloorTheme.success, size: 18),
          label: 'Total Clicks',
          value: '${_callClicks + _whatsappClicks}',
        ),
      ],
    );
  }

  Widget _buildWeeklyEngagement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DegloorTheme.cardBackground,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        border: Border.all(color: DegloorTheme.border),
        boxShadow: DegloorTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Engagement', style: DegloorTheme.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => context.pushNamed(
                  'BusinessAnalytics',
                  queryParameters: {'businessId': _business!.id},
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: () {
              final last7Days = List.generate(7, (i) {
                final date = DateTime.now().subtract(Duration(days: 6 - i));
                return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
              });
              final yData = last7Days.map((d) => (_dailyCounts[d] ?? 0).toDouble()).toList();
              
              return FlutterFlowBarChart(
                barData: [
                  FFBarChartData(
                    yData: yData,
                    color: DegloorTheme.primary,
                  )
                ],
                xLabels: last7Days,
                barWidth: 20,
                barBorderRadius: BorderRadius.circular(4),
                groupSpace: 12,
                alignment: BarChartAlignment.spaceEvenly,
                chartStylingInfo: const ChartStylingInfo(
                  backgroundColor: Colors.transparent,
                  showBorder: false,
                ),
                axisBounds: AxisBounds(
                  minY: 0.0,
                  maxX: 6.0,
                  maxY: yData.isEmpty ? 10.0 : (yData.reduce((a, b) => a > b ? a : b) + 5.0).clamp(10.0, 1000.0),
                ),
                xAxisLabelInfo: const AxisLabelInfo(
                  showLabels: true,
                  labelTextStyle: TextStyle(color: DegloorTheme.textSecondary, fontSize: 9),
                  reservedSize: 20,
                ),
                yAxisLabelInfo: const AxisLabelInfo(reservedSize: 0),
              );
            }(),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActions() {
    return Column(
      children: [
        _secondaryTile(
          icon: Icons.star_outline_rounded,
          title: 'Customer Reviews',
          trailing: '$_totalReviews',
          onTap: () => context.pushNamed(
            'BusinessProfile',
            queryParameters: {'businessId': _business!.id},
          ),
        ),
        const SizedBox(height: 12),
        _secondaryTile(
          icon: Icons.analytics_outlined,
          title: 'Detailed Analytics',
          onTap: () => context.pushNamed(
            'BusinessAnalytics',
            queryParameters: {'businessId': _business!.id},
          ),
        ),
      ],
    );
  }

  Widget _secondaryTile({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: DegloorTheme.cardBackground,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
            border: Border.all(color: DegloorTheme.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: DegloorTheme.textSecondary, size: 20),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: DegloorTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500))),
              if (trailing != null)
                Text(trailing, style: const TextStyle(color: DegloorTheme.primary, fontWeight: FontWeight.bold)),
              const Icon(Icons.chevron_right_rounded, color: DegloorTheme.border, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: DegloorTheme.labelSmall.copyWith(
        color: DegloorTheme.textSecondary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}
