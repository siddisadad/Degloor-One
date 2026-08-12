import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/apply_job_sheet/apply_job_sheet_widget.dart';
import 'package:degloor_one/components/job_card/job_card_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JobsMarketplaceModel());

    _model.searchBarController ??= TextEditingController();
    _model.searchBarFocusNode ??= FocusNode();

    _model.searchBarController!.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchJobs() async {
    var query = SupaFlow.client
        .from('jobs')
        .select('*, businesses(name, location)')
        .eq('is_active', true);

    if (_model.searchBarController!.text.isNotEmpty) {
      query = query.ilike('title', '%${_model.searchBarController!.text}%');
    }

    if (_model.jobTypeFilter != null && _model.jobTypeFilter != 'All') {
      query = query.eq('job_type', _model.jobTypeFilter!);
    }

    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
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
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Job Marketplace',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter',
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
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
                                    setState(() {});
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
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchJobs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final jobs = snapshot.data ?? [];
                    if (jobs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No jobs found',
                              style: FlutterFlowTheme.of(context).titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters or search terms',
                              style: FlutterFlowTheme.of(context).bodySmall,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        final business = job['businesses'] as Map<String, dynamic>?;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: JobCardWidget(
                            title: job['title'] ?? 'Job Title',
                            companyName: business?['name'] ?? 'Employer',
                            location: business?['location'] ?? 'Degloor',
                            salary: job['salary_range'] ?? 'Salary Not Specified',
                            jobType: job['job_type'] ?? 'Type',
                            onActionPressed: () async => _applyForJob(job),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

