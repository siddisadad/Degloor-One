import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/shared/join_rows.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import '/components/stat_card/stat_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'business_analytics_model.dart';
export 'business_analytics_model.dart';

class BusinessAnalyticsWidget extends StatefulWidget {
  const BusinessAnalyticsWidget({
    super.key,
    required this.businessId,
  });

  final String businessId;

  static String routeName = 'BusinessAnalytics';
  static String routePath = '/businessAnalytics';

  @override
  State<BusinessAnalyticsWidget> createState() =>
      _BusinessAnalyticsWidgetState();
}

class _BusinessAnalyticsWidgetState extends State<BusinessAnalyticsWidget>
    with TickerProviderStateMixin {
  late BusinessAnalyticsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  ShopEventSummary _summary = ShopEventSummary.empty;
  int _selectedPeriod = 7; // 7, 30, 0 (Overall)
  final Map<String, JoinedProduct> _topProductData = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessAnalyticsModel());
    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
    )..addListener(() {
        if (_model.tabBarController!.indexIsChanging) return;
        int period = 7;
        if (_model.tabBarController!.index == 1) period = 30;
        if (_model.tabBarController!.index == 2) period = 0;
        if (period != _selectedPeriod) {
          safeSetState(() {
            _selectedPeriod = period;
            _isLoading = true;
          });
          _fetchData();
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      final events = await ShopService.instance.eventsFor(
        userId: currentUserUid,
        businessId: widget.businessId,
        days: _selectedPeriod,
      );
      final summary = ShopService.summarizeEvents(events);

      // Resolve product names for top products
      final productIds = summary.topProducts.map((e) => e.key).toList();
      if (productIds.isNotEmpty) {
        final products = await Future.wait(
          productIds.map((id) => ShopService.instance.productById(id)),
        );
        for (final p in products) {
          if (p != null) {
            _topProductData[p.id] = JoinedProduct(
              id: p.id,
              name: p.name,
              imageUrl: p.imageUrl,
            );
          }
        }
      }

      if (!mounted) return;
      safeSetState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error fetching analytics', e);
      if (mounted) {
        safeSetState(() {
          _summary = ShopEventSummary.empty;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  int get profileViews => _summary.profileViews;
  int get callClicks => _summary.callClicks;
  int get whatsappClicks => _summary.whatsappClicks;
  int get directionsClicks => _summary.directionsClicks;
  int get inquiries => _summary.inquiries;
  double get conversionRate => _summary.conversionRate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: DegloorTheme.background,
        appBar: degloorAppBar(context, title: 'Business Insights'),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: DegloorTheme.cardBackground,
                    ),
                    child: TabBar(
                      labelColor: DegloorTheme.primary,
                      unselectedLabelColor: DegloorTheme.textSecondary,
                      labelStyle: DegloorTheme.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: DegloorTheme.titleSmall,
                      indicatorColor: DegloorTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      tabs: const [
                        Tab(text: '7 Days'),
                        Tab(text: '30 Days'),
                        Tab(text: 'Overall'),
                      ],
                      controller: _model.tabBarController,
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: DegloorTheme.primary,
                            ),
                          )
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildStatsGrid(),
                                  const SizedBox(height: 24),
                                  if (_summary.topProducts.isNotEmpty) ...[
                                    _buildSectionTitle(
                                        'Top Performing Products'),
                                    const SizedBox(height: 16),
                                    _buildTopProducts(),
                                    const SizedBox(height: 24),
                                  ],
                                  _buildSectionTitle('Engagement Over Time'),
                                  const SizedBox(height: 16),
                                  _buildBarChart(),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle('Event Distribution'),
                                  const SizedBox(height: 16),
                                  _buildPieChart(),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DegloorTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCardWidget(
          hasTrend: false,
          icon: const Icon(Icons.visibility_rounded,
              color: DegloorTheme.primary, size: 24),
          label: 'Profile Views',
          value: '$profileViews',
        ),
        StatCardWidget(
          hasTrend: false,
          icon: const Icon(Icons.forum_rounded,
              color: DegloorTheme.success, size: 24),
          label: 'Inquiries',
          value: '$inquiries',
        ),
        StatCardWidget(
          hasTrend: false,
          icon: const Icon(Icons.near_me_rounded,
              color: Colors.blue, size: 24),
          label: 'Directions',
          value: '$directionsClicks',
        ),
        StatCardWidget(
          hasTrend: false,
          icon: const Icon(Icons.trending_up_rounded,
              color: DegloorTheme.secondary, size: 24),
          label: 'Conv. Rate',
          value: '${conversionRate.toStringAsFixed(1)}%',
        ),
      ],
    );
  }

  Widget _buildTopProducts() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _summary.topProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final entry = _summary.topProducts[index];
          final product = _topProductData[entry.key];
          return Container(
            width: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DegloorTheme.cardBackground,
              borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
              border: Border.all(color: DegloorTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
                      child: product?.imageUrl != null
                          ? CachedRemoteImage(
                              url: product!.imageUrl!,
                              width: 32,
                              height: 32,
                            )
                          : Container(
                              width: 32,
                              height: 32,
                              color: DegloorTheme.accent,
                              child: const Icon(Icons.inventory_2_rounded,
                                  size: 16, color: DegloorTheme.primary),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product?.name ?? 'Deleted Item',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DegloorTheme.labelSmall.copyWith(
                          color: DegloorTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${entry.value}',
                  style: DegloorTheme.headingMedium.copyWith(
                    color: DegloorTheme.primary,
                  ),
                ),
                Text(
                  'INTERACTIONS',
                  style: DegloorTheme.labelSmall.copyWith(fontSize: 9),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarChart() {
    final dailyCounts = _summary.dailyCounts;
    final sortedDates = dailyCounts.keys.toList()..sort();
    // Take last 7 or 14 points to avoid clutter
    final displayDates = sortedDates.length > 10
        ? sortedDates.sublist(sortedDates.length - 10)
        : sortedDates;

    if (displayDates.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: DegloorTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DegloorTheme.border),
        ),
        child: const Center(child: Text('No data for this period')),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration: BoxDecoration(
        color: DegloorTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DegloorTheme.border),
        boxShadow: DegloorTheme.softShadow,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (dailyCounts.values.isEmpty
                  ? 0
                  : dailyCounts.values.reduce((a, b) => a > b ? a : b)) *
              1.2,
          barGroups: displayDates.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: dailyCounts[entry.value]!.toDouble(),
                  color: DegloorTheme.primary,
                  width: 16,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= displayDates.length) {
                    return const Text('');
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      displayDates[value.toInt()],
                      style: DegloorTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: DegloorTheme.labelSmall,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: DegloorTheme.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final Map<String, int> typeCounts = {
      'Views': profileViews,
      'Calls': callClicks,
      'WhatsApp': whatsappClicks,
      'Directions': directionsClicks,
    };

    final total = typeCounts.values.fold(0, (sum, val) => sum + val);

    if (total == 0) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: DegloorTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DegloorTheme.border),
        ),
        child: const Center(child: Text('No data for this period')),
      );
    }

    final List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: profileViews.toDouble(),
        title: 'Views',
        color: DegloorTheme.primary,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: callClicks.toDouble(),
        title: 'Calls',
        color: DegloorTheme.success,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: whatsappClicks.toDouble(),
        title: 'WhatsApp',
        color: DegloorTheme.secondary,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: directionsClicks.toDouble(),
        title: 'Directions',
        color: Colors.blue,
        radius: 50,
        showTitle: false,
      ),
    ].where((s) => s.value > 0).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DegloorTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DegloorTheme.border),
        boxShadow: DegloorTheme.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Views', DegloorTheme.primary),
              _buildLegendItem('Calls', DegloorTheme.success),
              _buildLegendItem('WhatsApp', DegloorTheme.secondary),
              _buildLegendItem('Directions', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: DegloorTheme.labelMedium),
        ],
      ),
    );
  }
}
