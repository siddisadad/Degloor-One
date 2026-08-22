import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

/// Data access for jobs and applications. Widgets should go through
/// [JobService].
class JobRepository {
  Future<List<Map<String, dynamic>>> listActive({
    String? search,
    String? jobType,
    PageQuery page = const PageQuery(),
  }) async {
    if (kUseShowcaseData) {
      return ShowcaseCatalog.activeJobs(
        search: search,
        jobType: jobType,
        limit: page.limit,
        offset: page.offset,
      );
    }

    var query = SupaFlow.client
        .from('jobs')
        .select('*, businesses(name, location, address_text)')
        .eq('is_active', true);

    if (search != null && search.trim().isNotEmpty) {
      query = query.ilike('title', '%${search.trim()}%');
    }
    if (jobType != null && jobType != 'All') {
      query = query.eq('job_type', jobType);
    }

    final response =
        await query.order('created_at', ascending: false).range(page.from, page.to);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<JobsRow>> forBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  }) {
    return JobsTable().queryRows(
      queryFn: (q) =>
          q.eq('business_id', businessId).order('created_at', ascending: false),
      limit: page.limit,
      offset: page.offset,
    );
  }

  Future<JobsRow> insert(Map<String, dynamic> data) {
    return JobsTable().insert(data);
  }

  Future<JobApplicationsRow> insertApplication(Map<String, dynamic> data) {
    return JobApplicationsTable().insert(data);
  }

  Future<List<Map<String, dynamic>>> applicants(String jobId) async {
    if (kUseShowcaseData) {
      return ShowcaseCatalog.jobApplicants(jobId);
    }
    final response = await SupaFlow.client
        .from('job_applications')
        .select('*, users(full_name, phone_number)')
        .eq('job_id', jobId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
