import 'package:degloor_one/shared/job_application.dart';
import 'package:degloor_one/shared/job_application_draft.dart';
import 'package:degloor_one/shared/job_posting.dart';
import 'package:degloor_one/shared/job_posting_draft.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';

/// Data access for jobs and applications. Screens go through [JobService].
/// Concrete implementations map table rows or API JSON.
abstract class JobRepository {
  Future<List<JobListing>> listActive({
    String? search,
    String? jobType,
    PageQuery page = const PageQuery(),
  });

  Future<List<JobPosting>> forBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  });

  Future<JobPosting> insert(
    JobPostingDraft draft, {
    required String businessId,
    required String posterId,
  });

  Future<JobApplication> apply(JobApplicationDraft draft);

  Future<List<JobApplicant>> applicants(String jobId);
}
