import 'package:degloor_one/backend/job_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/shared/job_application_draft.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('listActive filters by jobType in showcase mode', () async {
    final all = await JobService.instance.listActive(page: const PageQuery(limit: 50));
    final fullTime = await JobService.instance.listActive(
      jobType: 'Full-time',
      page: const PageQuery(limit: 50),
    );

    expect(all.items.length, greaterThan(fullTime.items.length));
    expect(fullTime.items.every((j) => j.jobType == 'Full-time'), isTrue);
  });

  test('apply validates experience summary length', () async {
    final shortDraft = JobApplicationDraft.fromForm(
      jobId: 'job-1',
      applicantId: 'user-1',
      experienceSummary: 'Too short',
    );

    await expectLater(
      JobService.instance.apply(shortDraft),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('detailed'))),
    );

    final validDraft = JobApplicationDraft.fromForm(
      jobId: 'job-1',
      applicantId: 'user-1',
      experienceSummary: 'I have more than ten characters of experience.',
    );

    // Should not throw validation error (might throw other errors if setup is incomplete, 
    // but we are testing the service layer validation here)
    try {
      await JobService.instance.apply(validDraft);
    } on Exception catch (e) {
      expect(e.toString(), isNot(contains('detailed')));
    }
  });

  test('updateApplicantStatus updates showcase data', () async {
    const appId = 'ja-1'; // Seeded application ID
    
    await JobService.instance.updateApplicantStatus(
      applicationId: appId,
      status: 'shortlisted',
    );

    final apps = ShowcaseCatalog.query('job_applications', ShowcaseQuery()..eq('id', appId));
    expect(apps.single['status'], 'shortlisted');
  });
}
