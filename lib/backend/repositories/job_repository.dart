import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/job_posting_draft.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/rpc_row.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

/// Data access for jobs and applications. Widgets should go through
/// [JobService].
class JobRepository {
  Future<List<JobListing>> listActive({
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
      ).map(JobListing.fromJoin).toList();
    }

    var query = SupaFlow.client
        .from('jobs')
        .select('*, businesses(name, location, address_text)')
        .eq('is_active', true);

    final needle = search == null ? '' : sanitizeIlike(search);
    if (needle.isNotEmpty) {
      query = query.ilike('title', '%$needle%');
    }
    if (jobType != null && jobType != 'All') {
      query = query.eq('job_type', jobType);
    }

    final response =
        await query.order('created_at', ascending: false).range(page.from, page.to);
    return List<Map<String, dynamic>>.from(response)
        .map(JobListing.fromJoin)
        .toList();
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

  Future<JobsRow> insert(
    JobPostingDraft draft, {
    required String businessId,
    required String posterId,
  }) {
    return JobsTable().insert(
      draft.toInsertJson(businessId: businessId, posterId: posterId),
    );
  }

  Future<JobApplicationsRow> insertApplication(Map<String, dynamic> data) {
    return JobApplicationsTable().insert(data);
  }

  Future<List<JobApplicant>> applicants(String jobId) async {
    if (kUseShowcaseData) {
      return ShowcaseCatalog.jobApplicants(jobId)
          .map(JobApplicant.fromJoin)
          .toList();
    }
    final response = await SupaFlow.client
        .from('job_applications')
        .select('*, users(full_name, phone_number)')
        .eq('job_id', jobId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response)
        .map(JobApplicant.fromJoin)
        .toList();
  }
}
