import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/data/repositories/job_repository.dart';
import 'package:degloor_one/shared/job_application.dart';
import 'package:degloor_one/shared/job_application_draft.dart';
import 'package:degloor_one/shared/job_posting.dart';
import 'package:degloor_one/shared/job_posting_draft.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';

class JobService {
  JobService({required JobRepository repository}) : _repository = repository;

  final JobRepository _repository;

  static JobService? _instance;

  static JobService get instance {
    final bound = _instance;
    if (bound == null) {
      throw StateError('JobService is not bound.');
    }
    return bound;
  }

  /// Called from the composition root with a concrete repository.
  static void bind(JobRepository repository) {
    _instance = JobService(repository: repository);
  }

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
    return PageResult(items: rows, hasMore: rows.length >= page.limit);
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
    return _repository.insert(
      normalized,
      businessId: businessId,
      posterId: posterId,
    );
  }

  Future<JobApplication> apply(JobApplicationDraft draft) async {
    if (draft.applicantId.isEmpty) {
      throw Exception('Please sign in to apply');
    }
    final summary = draft.experienceSummary.trim();
    if (summary.length < 10) {
      throw Exception('Please provide a more detailed experience summary (min 10 characters)');
    }

    final normalized = JobApplicationDraft.fromForm(
      jobId: draft.jobId,
      applicantId: draft.applicantId,
      experienceSummary: summary,
    );
    return _repository.apply(normalized);
  }

  Future<List<JobApplicant>> applicants(String jobId) =>
      _repository.applicants(jobId);

  Future<void> updateApplicantStatus({
    required String applicationId,
    required String status,
  }) {
    return _repository.updateApplicantStatus(
      applicationId: applicationId,
      status: status,
    );
  }
}
