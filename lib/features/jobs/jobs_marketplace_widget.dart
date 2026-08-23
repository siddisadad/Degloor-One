import 'dart:async';

import 'package:degloor_one/backend/job_service.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/components/apply_job_sheet/apply_job_sheet_widget.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/job_card/job_card_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'jobs_marketplace_model.dart';
export 'jobs_marketplace_model.dart';

class JobsMarketplaceWidget extends StatefulWidget {
  const JobsMarketplaceWidget({super.key});

  static String routeName = 'JobsMarketplace';
  static String routePath = '/jobsMarketplace';

  @override
  State<JobsMarketplaceWidget> createState() => _JobsMarketplaceWidgetState();
}

class _JobsMarketplaceWidgetState extends State<JobsMarketplaceWidget> {
  late JobsMarketplaceModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _jobs = [];
  bool _loading = false;
  bool _hasMore = true;
  int _offset = 0;
  int _loadToken = 0;
  Timer? _searchDebounce;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JobsMarketplaceModel());

    _model.searchBarController ??= TextEditingController();
    _model.searchBarFocusNode ??= FocusNode();

    _model.searchBarController!.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadJobs());
  }

  void _onSearchChanged() {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _loadJobs();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _model.searchBarController?.removeListener(_onSearchChanged);
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadJobs({bool loadMore = false}) async {
    if (loadMore && _loading) return;
    final token = loadMore ? _loadToken : ++_loadToken;
    setState(() {
      _loading = true;
      if (!loadMore) {
        _jobs = [];
        _offset = 0;
        _hasMore = true;
      }
    });
    try {
      final page = await JobService.instance.listActive(
        search: _model.searchBarController!.text,
        jobType: _model.jobTypeFilter,
        page: PageQuery(limit: _pageSize, offset: _offset),
      );
      if (!mounted || token != _loadToken) return;
      setState(() {
        _jobs.addAll(page.items);
        _offset += _pageSize;
        _hasMore = page.hasMore;
        _loading = false;
      });
    } catch (_) {
      if (mounted && token == _loadToken) {
        setState(() => _loading = false);
      }
    }
  }

  void _applyForJob(Map<String, dynamic> job) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplyJobSheetWidget(
        jobId: job['id'].toString(),
        jobTitle: job['title'] ?? 'Job Position',
      ),
    );
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
        appBar: degloorAppBar(context, title: 'Local jobs'),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _model.searchBarController,
                        focusNode: _model.searchBarFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Search for jobs...',
                          labelStyle: FlutterFlowTheme.of(context).labelMedium,
                          hintStyle: FlutterFlowTheme.of(context).labelMedium,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          suffixIcon: _model.searchBarController!.text.isNotEmpty
                              ? InkWell(
                                  onTap: () async {
                                    _model.searchBarController?.clear();
                                    _loadJobs();
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    size: 20,
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: FlutterFlowTheme.of(context).primaryBackground,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium,
                        onFieldSubmitted: (_) => _loadJobs(),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Full-time', 'Part-time', 'Daily Wage'].map((type) {
                            final isSelected = (_model.jobTypeFilter ?? 'All') == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(type),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _model.jobTypeFilter = selected ? type : 'All';
                                  });
                                  _loadJobs();
                                },
                                selectedColor: FlutterFlowTheme.of(context).primary,
                                backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primaryText,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isSelected ? Colors.transparent : FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _loading && _jobs.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _jobs.isEmpty
                        ? EmptyStateView(
                            icon: Icons.work_outline_rounded,
                            title: 'No jobs found',
                            description:
                                'Try another search or check services nearby.',
                            buttonText: 'Clear filters',
                            onTap: () {
                              _model.searchBarController?.clear();
                              _model.jobTypeFilter = 'All';
                              _loadJobs();
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _jobs.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _jobs.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TextButton(
                                    onPressed: _loading
                                        ? null
                                        : () => _loadJobs(loadMore: true),
                                    child: Text(
                                      _loading ? 'Loading...' : 'Load more',
                                    ),
                                  ),
                                );
                              }
                              final job = _jobs[index];
                              final business =
                                  job['businesses'] as Map<String, dynamic>?;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: JobCardWidget(
                                  title: job['title'] ?? 'Job Title',
                                  companyName: business?['name'] ?? 'Employer',
                                  location: business?['address_text'] ??
                                      business?['location'] ??
                                      'Degloor',
                                  salary: job['salary_range'] ??
                                      'Salary Not Specified',
                                  jobType: job['job_type'] ?? 'Type',
                                  onActionPressed: () async => _applyForJob(job),
                                ),
                              );
                            },
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

