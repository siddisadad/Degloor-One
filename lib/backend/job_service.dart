import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/repositories/job_repository.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/job_application.dart';
import 'package:degloor_one/shared/job_application_draft.dart';
import 'package:degloor_one/shared/job_posting.dart';
import 'package:degloor_one/shared/job_posting_draft.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/rpc_row.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class JobService {
  JobService({JobRepository? repository})
      : _repository = repository ?? JobRepository();

  final JobRepository _repository;

  static final instance = JobService();

  Future<PageResult<JobListing>> listActive({
    String? search,
    String? jobType,
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _repository.listActive(
      search: search,
      jobType: jobType,
      page: page,
    );
    return PageResult(items: rows, hasMore: rows.length >= page.limit);
  }

  Future<PageResult<JobPosting>> forBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _repository.forBusiness(businessId, page: page);
    return PageResult(
      items: rows.map(JobPosting.fromRow).toList(),
      hasMore: rows.length >= page.limit,
    );
  }

  Future<JobPosting> post({
    required String businessId,
    required String posterId,
    required JobPostingDraft draft,
  }) async {
    final normalized = JobPostingDraft.fromForm(
      title: draft.title,
      description: draft.description,
      jobType: draft.jobType,
      salaryRange: draft.salaryRange,
      locationText: draft.locationText,
    );
    await BusinessService.instance.requireOwnedBusiness(
      userId: posterId,
      businessId: businessId,
    );
    final row = await _repository.insert(
      normalized,
      businessId: businessId,
      posterId: posterId,
    );
    return JobPosting.fromRow(row);
  }

  Future<JobApplication> apply(JobApplicationDraft draft) async {
    if (draft.applicantId.isEmpty) {
      throw Exception('Please sign in to apply');
    }
    final normalized = JobApplicationDraft.fromForm(
      jobId: draft.jobId,
      applicantId: draft.applicantId,
      experienceSummary: draft.experienceSummary,
    );

    if (kUseShowcaseData) {
      final existing = ShowcaseCatalog.query(
        'job_applications',
        ShowcaseQuery()
          ..eq('job_id', normalized.jobId)
          ..eq('applicant_id', normalized.applicantId),
      );
      if (existing.isNotEmpty) {
        throw Exception('You have already applied for this job');
      }
      final row = await _repository.insertApplication(normalized);
      return JobApplication.fromRow(row);
    }

    final response = await SupaFlow.client.rpc(
      'apply_to_job',
      params: {
        'p_job_id': normalized.jobId,
        'p_experience': normalized.experienceSummary,
      },
    );
    final row = asRpcRow(response);
    if (row == null) {
      throw Exception('Failed to apply for this job');
    }
    return JobApplication.fromRow(JobApplicationsRow(row));
  }

  Future<List<JobApplicant>> applicants(String jobId) =>
      _repository.applicants(jobId);
}
