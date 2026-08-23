import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/repositories/job_repository.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/rpc_row.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class JobService {
  JobService({JobRepository? repository})
      : _repository = repository ?? JobRepository();

  final JobRepository _repository;

  static final instance = JobService();

  Future<PageResult<Map<String, dynamic>>> listActive({
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

  Future<PageResult<JobsRow>> forBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _repository.forBusiness(businessId, page: page);
    return PageResult(items: rows, hasMore: rows.length >= page.limit);
  }

  Future<JobsRow> post({
    required String businessId,
    required String posterId,
    required String title,
    required String description,
    required String jobType,
    String? salaryRange,
    String? locationText,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw Exception('Job title is required');
    }
    await BusinessService.instance.requireOwnedBusiness(
      userId: posterId,
      businessId: businessId,
    );
    return _repository.insert({
      'business_id': businessId,
      'poster_id': posterId,
      'title': trimmed,
      'description': description.trim(),
      'salary_range': salaryRange?.trim(),
      'job_type': jobType,
      'location_text': locationText,
      'is_active': true,
    });
  }

  Future<JobApplicationsRow> apply({
    required String jobId,
    required String applicantId,
    required String experienceSummary,
  }) async {
    if (applicantId.isEmpty) {
      throw Exception('Please sign in to apply');
    }
    final summary = experienceSummary.trim();
    if (summary.isEmpty) {
      throw Exception('Please enter your experience summary');
    }

    if (kUseShowcaseData) {
      final existing = ShowcaseCatalog.query(
        'job_applications',
        ShowcaseQuery()
          ..eq('job_id', jobId)
          ..eq('applicant_id', applicantId),
      );
      if (existing.isNotEmpty) {
        throw Exception('You have already applied for this job');
      }
      return _repository.insertApplication({
        'job_id': jobId,
        'applicant_id': applicantId,
        'experience_summary': summary,
        'status': 'applied',
      });
    }

    final response = await SupaFlow.client.rpc(
      'apply_to_job',
      params: {
        'p_job_id': jobId,
        'p_experience': summary,
      },
    );
    final row = asRpcRow(response);
    if (row == null) {
      throw Exception('Failed to apply for this job');
    }
    return JobApplicationsRow(row);
  }

  Future<List<Map<String, dynamic>>> applicants(String jobId) =>
      _repository.applicants(jobId);
}
