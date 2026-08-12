import '/backend/supabase/supabase.dart';
import '/components/stat_card/stat_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<BusinessAnalyticsRow> _analyticsData = [];
  int _selectedPeriod = 7; // 7, 30, 0 (Overall)

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessAnalyticsModel());
    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
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
      final now = DateTime.now();
      DateTime? startDate;
      if (_selectedPeriod == 7) {
        startDate = now.subtract(const Duration(days: 7));
      } else if (_selectedPeriod == 30) {
        startDate = now.subtract(const Duration(days: 30));
      }

      var query = SupaFlow.client
          .from('business_analytics')
          .select('*')
          .eq('business_id', widget.businessId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      final List<dynamic> response = await query.order('created_at', ascending: true);

      if (!mounted) return;

      safeSetState(() {
        _analyticsData = response.map((e) => BusinessAnalyticsRow(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching analytics: $e');
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Helper getters for stats
  int get profileViews => _analyticsData.where((e) => e.eventType == 'PROFILE_VIEW').length;
  int get callClicks => _analyticsData.where((e) => e.eventType == 'CALL_CLICK').length;
  int get whatsappClicks => _analyticsData.where((e) => e.eventType == 'WHATSAPP_CLICK').length;
  int get directionsClicks => _analyticsData.where((e) => e.eventType == 'DIRECTIONS_CLICK').length;
  int get inquiries => callClicks + whatsappClicks;
  double get conversionRate => profileViews > 0 ? (inquiries / profileViews * 100) : 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Business Insights',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: TabBar(
                  labelColor: FlutterFlowTheme.of(context).primary,
                  unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
                  labelStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                  unselectedLabelStyle: FlutterFlowTheme.of(context).titleSmall,
                  indicatorColor: FlutterFlowTheme.of(context).primary,
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
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildStatsGrid(),
                              const SizedBox(height: 24),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: FlutterFlowTheme.of(context).titleMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.bold),
            color: FlutterFlowTheme.of(context).primaryText,
          ),
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
          icon: Icon(Icons.visibility_rounded, color: FlutterFlowTheme.of(context).primary, size: 24),
          label: 'Profile Views',
          value: '$profileViews',
        ),
        StatCardWidget(
          hasTrend: false,
          icon: Icon(Icons.forum_rounded, color: FlutterFlowTheme.of(context).success, size: 24),
          label: 'Inquiries',
          value: '$inquiries',
        ),
        StatCardWidget(
          hasTrend: false,
          icon: Icon(Icons.near_me_rounded, color: FlutterFlowTheme.of(context).info, size: 24),
          label: 'Directions',
          value: '$directionsClicks',
        ),
        StatCardWidget(
          hasTrend: false,
          icon: Icon(Icons.trending_up_rounded, color: FlutterFlowTheme.of(context).secondary, size: 24),
          label: 'Conv. Rate',
          value: '${conversionRate.toStringAsFixed(1)}%',
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    // Group data by date
    final Map<String, int> dailyCounts = {};
    for (var event in _analyticsData) {
      final date = DateFormat('MM/dd').format(event.createdAt);
      dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
    }

    final sortedDates = dailyCounts.keys.toList()..sort();
    // Take last 7 or 14 points to avoid clutter
    final displayDates = sortedDates.length > 10
        ? sortedDates.sublist(sortedDates.length - 10)
        : sortedDates;

    if (displayDates.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No data for this period')),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (dailyCounts.values.isEmpty ? 0 : dailyCounts.values.reduce((a, b) => a > b ? a : b)) * 1.2,
          barGroups: displayDates.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: dailyCounts[entry.value]!.toDouble(),
                  color: FlutterFlowTheme.of(context).primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= displayDates.length) return const Text('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      displayDates[value.toInt()],
                      style: FlutterFlowTheme.of(context).labelSmall,
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
                    style: FlutterFlowTheme.of(context).labelSmall,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: FlutterFlowTheme.of(context).alternate,
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
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No data for this period')),
      );
    }

    final List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: profileViews.toDouble(),
        title: 'Views',
        color: FlutterFlowTheme.of(context).primary,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: callClicks.toDouble(),
        title: 'Calls',
        color: FlutterFlowTheme.of(context).success,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: whatsappClicks.toDouble(),
        title: 'WhatsApp',
        color: FlutterFlowTheme.of(context).secondary,
        radius: 50,
        showTitle: false,
      ),
      PieChartSectionData(
        value: directionsClicks.toDouble(),
        title: 'Directions',
        color: FlutterFlowTheme.of(context).info,
        radius: 50,
        showTitle: false,
      ),
    ].where((s) => s.value > 0).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
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
              _buildLegendItem('Views', FlutterFlowTheme.of(context).primary),
              _buildLegendItem('Calls', FlutterFlowTheme.of(context).success),
              _buildLegendItem('WhatsApp', FlutterFlowTheme.of(context).secondary),
              _buildLegendItem('Directions', FlutterFlowTheme.of(context).info),
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
          Text(label, style: FlutterFlowTheme.of(context).labelMedium),
        ],
      ),
    );
  }
}
