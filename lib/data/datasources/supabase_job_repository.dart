import 'package:degloor_one/backend/repositories/job_repository.dart' as tables;
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/data/datasources/supabase_job_maps.dart';
import 'package:degloor_one/data/repositories/job_repository.dart';
import 'package:degloor_one/shared/job_application.dart';
import 'package:degloor_one/shared/job_application_draft.dart';
import 'package:degloor_one/shared/job_posting.dart';
import 'package:degloor_one/shared/job_posting_draft.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/rpc_row.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

/// Showcase or live table access for jobs and applications.
class SupabaseJobRepository implements JobRepository {
  SupabaseJobRepository({tables.JobRepository? inner})
      : _inner = inner ?? tables.JobRepository();

  final tables.JobRepository _inner;

  @override
  Future<List<JobListing>> listActive({
    String? search,
    String? jobType,
    PageQuery page = const PageQuery(),
  }) {
    return _inner.listActive(
      search: search,
      jobType: jobType,
      page: page,
    );
  }

  @override
  Future<List<JobPosting>> forBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _inner.forBusiness(businessId, page: page);
    return rows.map(jobPostingFromRow).toList();
  }

  @override
  Future<JobPosting> insert(
    JobPostingDraft draft, {
    required String businessId,
    required String posterId,
  }) async {
    final row = await _inner.insert(
      draft,
      businessId: businessId,
      posterId: posterId,
    );
    return jobPostingFromRow(row);
  }

  @override
  Future<JobApplication> apply(JobApplicationDraft draft) async {
    if (kUseShowcaseData) {
      final existing = ShowcaseCatalog.query(
        'job_applications',
        ShowcaseQuery()
          ..eq('job_id', draft.jobId)
          ..eq('applicant_id', draft.applicantId),
      );
      if (existing.isNotEmpty) {
        throw Exception('You have already applied for this job');
      }
      final row = await _inner.insertApplication(draft);
      return jobApplicationFromRow(row);
    }

    final response = await SupaFlow.client.rpc(
      'apply_to_job',
      params: {
        'p_job_id': draft.jobId,
        'p_experience': draft.experienceSummary,
      },
    );
    final row = asRpcRow(response);
    if (row == null) {
      throw Exception('Failed to apply for this job');
    }
    return jobApplicationFromRow(JobApplicationsRow(row));
  }

  @override
  Future<List<JobApplicant>> applicants(String jobId) {
    return _inner.applicants(jobId);
  }
}
