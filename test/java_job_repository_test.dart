import 'package:degloor_one/data/datasources/java_job_repository.dart';
import 'package:degloor_one/shared/job_application.dart';
import 'package:degloor_one/shared/job_posting.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Java job JSON maps to JobPosting', () {
    final job = JobPosting.fromJson({
      'id': 'job-counter',
      'businessId': 'biz-patil',
      'posterId': 'user-1',
      'title': 'Counter helper',
      'description': 'Bill customers at the kirana.',
      'category': 'retail',
      'jobType': 'Full-time',
      'salaryRange': '₹12,000/mo',
      'locationText': 'Degloor bus stand',
      'active': true,
      'createdAt': '2026-08-24T10:00:00Z',
    });
    expect(job, isA<JobPosting>());
    expect(job.id, 'job-counter');
    expect(job.businessId, 'biz-patil');
    expect(job.posterId, 'user-1');
    expect(job.title, 'Counter helper');
    expect(job.jobType, 'Full-time');
    expect(job.salaryRange, '₹12,000/mo');
    expect(job.isActive, isTrue);
    expect(job.createdAt.toUtc().year, 2026);
  });

  test('Java job JSON falls back when createdAt and flags are omitted', () {
    final job = JobPosting.fromJson({
      'id': 'job-night',
      'title': 'Night stocker',
      'description': 'Restock after closing.',
      'jobType': 'Part-time',
      'isActive': false,
    });
    expect(job.id, 'job-night');
    expect(job.isActive, isFalse);
    expect(job.createdAt.millisecondsSinceEpoch, 0);
  });

  test('Java application JSON maps to JobApplication', () {
    final application = JobApplication.fromJson({
      'id': 'app-1',
      'jobId': 'job-counter',
      'applicantId': 'customer-2',
      'experienceSummary': 'Stocked a kirana for 6 months.',
      'status': 'applied',
    });
    expect(application, isA<JobApplication>());
    expect(application.id, 'app-1');
    expect(application.jobId, 'job-counter');
    expect(application.applicantId, 'customer-2');
    expect(application.status, 'applied');
    expect(application.createdAt.millisecondsSinceEpoch, 0);
  });

  test('Java listing JSON attaches a shop join when provided', () {
    final listing = JavaJobRepository.listingFromJson(
      {
        'id': 'job-counter',
        'title': 'Counter helper',
        'jobType': 'Full-time',
        'salaryRange': '₹12,000/mo',
        'locationText': 'Near bus stand',
      },
      shop: const JoinedShop(
        name: 'Patil Kirana',
        addressText: 'Near bus stand, Degloor',
      ),
    );
    expect(listing.id, 'job-counter');
    expect(listing.shop?.displayName, 'Patil Kirana');
    expect(listing.shop?.displayLocation, 'Near bus stand, Degloor');
  });
}
