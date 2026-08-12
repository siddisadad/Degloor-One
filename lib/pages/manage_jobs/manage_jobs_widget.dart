import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
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

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Post a Job'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Job Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextField(
                  controller: salaryController,
                  decoration: const InputDecoration(labelText: 'Salary (e.g. ₹500/day)'),
                ),
                DropdownButton<String>(
                  value: jobType,
                  isExpanded: true,
                  items: ['Full-time', 'Part-time', 'Daily Wage'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => jobType = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
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
                if (mounted) {
                  Navigator.pop(context);
                  this.setState(() {});
                }
              },
              child: const Text('Post'),
            ),
          ],
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
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Applicants for ${job.title}', style: FlutterFlowTheme.of(context).headlineSmall),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: SupaFlow.client.from('job_applications').select('*, users(full_name, phone_number)').eq('job_id', job.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final apps = snapshot.data!;
                  if (apps.isEmpty) return const Center(child: Text('No applications yet.'));

                  return ListView.builder(
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      final user = app['users'] as Map<String, dynamic>?;
                      return ListTile(
                        title: Text(user?['full_name'] ?? 'Unknown Applicant'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone: ${user?['phone_number'] ?? 'N/A'}'),
                            Text('Summary: ${app['experience_summary'] ?? 'No summary provided.'}'),
                          ],
                        ),
                        trailing: Text(app['status'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
          icon: Icon(Icons.arrow_back_rounded, color: FlutterFlowTheme.of(context).primaryText, size: 30),
          onPressed: () => context.safePop(),
        ),
        title: Text('Manage Jobs', style: FlutterFlowTheme.of(context).headlineMedium),
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
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final jobs = snapshot.data!;
          if (jobs.isEmpty) return const Center(child: Text('You haven\'t posted any jobs yet.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(job.title, style: FlutterFlowTheme.of(context).titleMedium.override(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                          Text(job.jobType, style: FlutterFlowTheme.of(context).bodySmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(job.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      FFButtonWidget(
                        onPressed: () => _viewApplications(job),
                        text: 'View Applications',
                        options: FFButtonOptions(
                          height: 40,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: const TextStyle(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
