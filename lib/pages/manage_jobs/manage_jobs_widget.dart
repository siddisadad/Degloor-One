import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:degloor_one/components/job_card/job_card_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'manage_jobs_model.dart';
export 'manage_jobs_model.dart';

class ManageJobsWidget extends StatefulWidget {
  const ManageJobsWidget({super.key});

  static String routeName = 'ManageJobs';
  static String routePath = '/manageJobs';

  @override
  State<ManageJobsWidget> createState() => _ManageJobsWidgetState();
}

class _ManageJobsWidgetState extends State<ManageJobsWidget> {
  late ManageJobsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageJobsModel());
    _fetchBusiness();
  }

  Future<void> _fetchBusiness() async {
    final businesses = await BusinessesTable().queryRows(
      queryFn: (q) => q.eq('owner_id', currentUserUid),
    );
    if (businesses.isNotEmpty) {
      setState(() {
        _model.businessId = businesses.first.id;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<JobsRow>> _fetchMyJobs() async {
    if (_model.businessId == null) return [];
    return JobsTable().queryRows(
      queryFn: (q) => q.eq('business_id', _model.businessId!),
    );
  }

  void _showPostJobDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final salaryController = TextEditingController();
    String jobType = 'Full-time';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Post a New Job',
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Job Title',
                  labelStyle: FlutterFlowTheme.of(context).labelMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Job Description',
                  labelStyle: FlutterFlowTheme.of(context).labelMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: salaryController,
                decoration: InputDecoration(
                  labelText: 'Salary (e.g. ₹500/day)',
                  labelStyle: FlutterFlowTheme.of(context).labelMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: jobType,
                decoration: InputDecoration(
                  labelText: 'Job Type',
                  labelStyle: FlutterFlowTheme.of(context).labelMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Full-time', 'Part-time', 'Daily Wage']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) jobType = val;
                },
              ),
              const SizedBox(height: 32),
              FFButtonWidget(
                onPressed: () async {
                  if (titleController.text.isEmpty) return;
                  await JobsTable().insert({
                    'business_id': _model.businessId,
                    'poster_id': currentUserUid,
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'salary_range': salaryController.text,
                    'job_type': jobType,
                    'is_active': true,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {});
                  }
                },
                text: 'Post Job',
                options: FFButtonOptions(
                  height: 50,
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Inter',
                        color: Colors.white,
                      ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _viewApplications(JobsRow job) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Applicants', style: FlutterFlowTheme.of(context).headlineSmall.override(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                        Text(job.title, style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'Inter', color: FlutterFlowTheme.of(context).secondaryText)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: kUseShowcaseData
                    ? Future.value(ShowcaseCatalog.jobApplicants(job.id))
                    : SupaFlow.client
                        .from('job_applications')
                        .select('*, users(full_name, phone_number)')
                        .eq('job_id', job.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final apps = snapshot.data ?? [];
                  if (apps.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 48, color: FlutterFlowTheme.of(context).secondaryText),
                          const SizedBox(height: 16),
                          Text('No applications yet', style: FlutterFlowTheme.of(context).titleMedium),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: apps.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      final user = app['users'] as Map<String, dynamic>?;
                      return Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    user?['full_name'] ?? 'Unknown Applicant',
                                    style: FlutterFlowTheme.of(context).titleMedium.override(fontFamily: 'Inter', fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).accent2,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      app['status'].toString().toUpperCase(),
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context).success,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.phone_rounded, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                                  const SizedBox(width: 4),
                                  Text(user?['phone_number'] ?? 'N/A', style: FlutterFlowTheme.of(context).bodySmall),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('Experience Summary:', style: FlutterFlowTheme.of(context).bodySmall.override(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                              Text(app['experience_summary'] ?? 'No summary provided.', style: FlutterFlowTheme.of(context).bodyMedium),
                            ],
                          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_model.businessId == null) return const Scaffold(body: Center(child: Text('No business found. Please register your business first.')));

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          buttonSize: 60,
          icon: Icon(Icons.arrow_back_rounded, color: FlutterFlowTheme.of(context).primaryText, size: 24),
          onPressed: () => context.safePop(),
        ),
        title: Text('Manage Jobs', style: FlutterFlowTheme.of(context).headlineMedium.override(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 20)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPostJobDialog,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<JobsRow>>(
        future: _fetchMyJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline_rounded, size: 64, color: FlutterFlowTheme.of(context).secondaryText),
                  const SizedBox(height: 16),
                  Text('You haven\'t posted any jobs yet.', style: FlutterFlowTheme.of(context).titleMedium),
                  const SizedBox(height: 24),
                  FFButtonWidget(
                    onPressed: _showPostJobDialog,
                    text: 'Post Your First Job',
                    options: FFButtonOptions(
                      width: 200,
                      height: 44,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: const TextStyle(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: JobCardWidget(
                  title: job.title,
                  companyName: 'My Business', // Could fetch business name if needed
                  location: 'Degloor',
                  salary: job.salaryRange ?? 'Not disclosed',
                  jobType: job.jobType,
                  actionText: 'View Applications',
                  onActionPressed: () async => _viewApplications(job),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

