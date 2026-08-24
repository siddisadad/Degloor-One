import 'dart:async';

import 'package:degloor_one/backend/job_service.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/components/apply_job_sheet/apply_job_sheet_widget.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/degloor_filter_chip.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/job_card/job_card_widget.dart';
import 'package:degloor_one/components/load_more_control.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_model.dart';
import 'package:flutter/material.dart';
import 'package:degloor_one/features/jobs/jobs_marketplace_model.dart';
export 'package:degloor_one/features/jobs/jobs_marketplace_model.dart';

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
  List<JobListing> _jobs = [];
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
        page: PageQuery(offset: _offset),
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

  void _applyForJob(JobListing job) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplyJobSheetWidget(
        jobId: job.id,
        jobTitle: job.title,
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
        backgroundColor: DegloorTheme.background,
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
                color: DegloorTheme.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(DegloorTheme.spacingMD),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _model.searchBarController,
                        focusNode: _model.searchBarFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search for jobs...',
                          hintStyle: DegloorTheme.bodyMedium.copyWith(
                            color: DegloorTheme.textSecondary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: DegloorTheme.border),
                            borderRadius:
                                BorderRadius.circular(DegloorTheme.radiusMD),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: DegloorTheme.primary,
                            ),
                            borderRadius:
                                BorderRadius.circular(DegloorTheme.radiusMD),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: DegloorTheme.textSecondary,
                          ),
                          suffixIcon: _model.searchBarController!.text.isNotEmpty
                              ? InkWell(
                                  onTap: () async {
                                    _model.searchBarController?.clear();
                                    _loadJobs();
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    color: DegloorTheme.textSecondary,
                                    size: 20,
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: DegloorTheme.background,
                        ),
                        style: DegloorTheme.bodyMedium,
                        onFieldSubmitted: (_) => _loadJobs(),
                      ),
                      const SizedBox(height: DegloorTheme.spacingMD),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Full-time', 'Part-time', 'Daily Wage']
                              .map((type) {
                            final isSelected =
                                (_model.jobTypeFilter ?? 'All') == type;
                            return DegloorFilterChip(
                              label: type,
                              selected: isSelected,
                              onTap: () {
                                setState(() {
                                  _model.jobTypeFilter =
                                      isSelected ? 'All' : type;
                                });
                                _loadJobs();
                              },
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
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: DegloorTheme.primary,
                        ),
                      )
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
                            padding: const EdgeInsets.all(DegloorTheme.spacingMD),
                            itemCount: _jobs.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _jobs.length) {
                                return LoadMoreControl(
                                  loading: _loading,
                                  onPressed: () => _loadJobs(loadMore: true),
                                );
                              }
                              final job = _jobs[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: JobCardWidget(
                                  title: job.title,
                                  companyName: job.shop?.displayName ?? 'Employer',
                                  location: job.shop?.displayLocation ?? 'Degloor',
                                  salary: job.salaryRange ??
                                      'Salary Not Specified',
                                  jobType: job.jobType,
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

