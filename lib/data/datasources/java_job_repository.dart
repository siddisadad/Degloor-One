import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/datasources/java_shop_repository.dart';
import 'package:degloor_one/data/repositories/job_repository.dart';
import 'package:degloor_one/shared/job_application.dart';
import 'package:degloor_one/shared/job_application_draft.dart';
import 'package:degloor_one/shared/job_posting.dart';
import 'package:degloor_one/shared/job_posting_draft.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';

/// Job access through the Java API. Table rows stay on the server.
class JavaJobRepository implements JobRepository {
  JavaJobRepository({JavaApiClient? client})
      : _client = client ?? JavaApiClient.instance;

  final JavaApiClient _client;

  static DateTime _createdAt(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static JobPosting postingFromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      description: '${json['description'] ?? ''}',
      jobType: '${json['jobType'] ?? ''}',
      isActive: json['active'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: _createdAt(json['createdAt']),
      businessId: json['businessId'] == null ? null : '${json['businessId']}',
      posterId: json['posterId'] == null ? null : '${json['posterId']}',
      category: json['category'] as String?,
      salaryRange: json['salaryRange'] as String?,
      locationText: json['locationText'] as String?,
    );
  }

  static JobApplication applicationFromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: '${json['id'] ?? ''}',
      jobId: '${json['jobId'] ?? ''}',
      applicantId: '${json['applicantId'] ?? ''}',
      status: '${json['status'] ?? JobApplicationDraft.applied}',
      createdAt: _createdAt(json['createdAt']),
      experienceSummary: json['experienceSummary'] as String?,
    );
  }

  static JobApplicant applicantFromJson(Map<String, dynamic> json) {
    return JobApplicant(
      id: '${json['id'] ?? ''}',
      status: '${json['status'] ?? JobApplicationDraft.applied}',
      experienceSummary: json['experienceSummary'] as String?,
    );
  }

  static JobListing listingFromJson(
    Map<String, dynamic> json, {
    JoinedShop? shop,
  }) {
    final posting = postingFromJson(json);
    return JobListing(
      id: posting.id,
      title: posting.title.isEmpty ? 'Job Title' : posting.title,
      jobType: posting.jobType.isEmpty ? 'Type' : posting.jobType,
      salaryRange: posting.salaryRange,
      shop: shop ??
          (posting.locationText == null
              ? null
              : JoinedShop(
                  location: posting.locationText,
                  addressText: posting.locationText,
                )),
    );
  }

  Future<List<Map<String, dynamic>>> _jobRows({String? search}) async {
    final data = await _client.get('/api/v1/jobs', query: {
      if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
    });
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<Map<String, JoinedShop>> _shopsById(Iterable<String> ids) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet();
    if (unique.isEmpty) return {};
    final data = await _client.get('/api/v1/businesses');
    final rows = data is List ? data : const [];
    final shops = <String, JoinedShop>{};
    for (final row in rows.whereType<Map>()) {
      final shop = JavaShopRepository.fromJson(Map<String, dynamic>.from(row));
      if (!unique.contains(shop.id)) continue;
      shops[shop.id] = JoinedShop(
        name: shop.name,
        location: shop.addressText,
        addressText: shop.addressText,
      );
    }
    return shops;
  }

  List<T> _page<T>(List<T> items, PageQuery page) {
    return items.skip(page.offset).take(page.limit).toList();
  }

  @override
  Future<List<JobListing>> listActive({
    String? search,
    String? jobType,
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _jobRows(search: search);
    final shops = await _shopsById(
      rows.map((row) => '${row['businessId'] ?? ''}'),
    );
    final listings = <JobListing>[];
    for (final row in rows) {
      final posting = postingFromJson(row);
      if (jobType != null && jobType != 'All' && posting.jobType != jobType) {
        continue;
      }
      listings.add(
        listingFromJson(row, shop: shops[posting.businessId]),
      );
    }
    return _page(listings, page);
  }

  @override
  Future<List<JobPosting>> forBusiness(
    String businessId, {
    PageQuery page = const PageQuery(),
  }) async {
    if (businessId.isEmpty) return const [];
    final rows = await _jobRows();
    final jobs = [
      for (final row in rows) postingFromJson(row),
    ].where((job) => job.businessId == businessId).toList();
    return _page(jobs, page);
  }

  @override
  Future<JobPosting> insert(
    JobPostingDraft draft, {
    required String businessId,
    required String posterId,
  }) async {
    final data = await _client.post('/api/v1/jobs', {
      'businessId': businessId,
      'title': draft.title,
      'description': draft.description,
      'jobType': draft.jobType,
      if (draft.salaryRange != null) 'salaryRange': draft.salaryRange,
      if (draft.locationText != null) 'locationText': draft.locationText,
    });
    final job = postingFromJson(Map<String, dynamic>.from(data as Map));
    if (job.posterId != null && job.posterId != posterId) {
      throw Exception('Unable to post this job. Please try again.');
    }
    return job;
  }

  @override
  Future<JobApplication> apply(JobApplicationDraft draft) async {
    try {
      final data = await _client.post(
        '/api/v1/jobs/${draft.jobId}/apply',
        {'experienceSummary': draft.experienceSummary},
      );
      return applicationFromJson(Map<String, dynamic>.from(data as Map));
    } on JavaApiException catch (error) {
      if (error.code == 'ALREADY_APPLIED') {
        throw Exception('You have already applied for this job');
      }
      rethrow;
    }
  }

  @override
  Future<List<JobApplicant>> applicants(String jobId) async {
    if (jobId.isEmpty) return const [];
    final data = await _client.get('/api/v1/jobs/$jobId/applications');
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => applicantFromJson(Map<String, dynamic>.from(row)))
        .toList();
  }
}
