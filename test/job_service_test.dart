import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/job_service.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/job_application.dart';
import 'package:degloor_one/shared/job_posting.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  setUp(ShowcaseCatalog.reset);

  test('active jobs paginate and include the shop name', () async {
    expect(kUseShowcaseData, isTrue);
    final first = await JobService.instance.listActive(
      page: const PageQuery(limit: 1),
    );
    expect(first.items, hasLength(1));
    expect(first.hasMore, isTrue);
    expect(first.items.first.shop?.name, isNotEmpty);

    final second = await JobService.instance.listActive(
      page: const PageQuery(limit: 1, offset: 1),
    );
    expect(second.items, hasLength(1));
    expect(second.items.first.id, isNot(first.items.first.id));
  });

  test('job type filter and search use the catalog', () async {
    final fullTime = await JobService.instance.listActive(jobType: 'Full-time');
    expect(fullTime.items, isNotEmpty);
    expect(
      fullTime.items.every((job) => job.jobType == 'Full-time'),
      isTrue,
    );

    final search = await JobService.instance.listActive(search: 'counter');
    expect(search.items, hasLength(1));
    expect(search.items.single.id, 'job-counter');
  });

  test('owners can post a job and applicants can apply once', () async {
    final posted = await JobService.instance.post(
      businessId: ShowcaseCatalog.bizPatil,
      posterId: GuestAuthUser.guestUid,
      title: 'Night stocker',
      description: 'Restock shelves after closing.',
      jobType: 'Part-time',
      salaryRange: '₹400/night',
    );
    expect(posted, isA<JobPosting>());
    expect(posted, isNot(isA<JobsRow>()));
    expect(posted.title, 'Night stocker');
    expect(posted.isActive, isTrue);

    final owned = await JobService.instance.forBusiness(ShowcaseCatalog.bizPatil);
    expect(owned.items, everyElement(isA<JobPosting>()));
    expect(owned.items, isNot(anyElement(isA<JobsRow>())));
    expect(owned.items.map((job) => job.id), contains(posted.id));

    final application = await JobService.instance.apply(
      jobId: posted.id,
      applicantId: ShowcaseCatalog.customer2,
      experienceSummary: 'Stocked a kirana for 6 months.',
    );
    expect(application, isA<JobApplication>());
    expect(application, isNot(isA<JobApplicationsRow>()));
    expect(application.status, 'applied');

    await expectLater(
      JobService.instance.apply(
        jobId: posted.id,
        applicantId: ShowcaseCatalog.customer2,
        experienceSummary: 'Applying again',
      ),
      throwsA(isA<Exception>()),
    );

    final applicants = await JobService.instance.applicants(posted.id);
    expect(applicants, hasLength(1));
    expect(applicants.first.user?.fullName, isNotEmpty);

    expect(
      ShowcaseCatalog.query(
        'jobs',
        ShowcaseQuery()..eq('id', posted.id),
      ),
      hasLength(1),
    );
  });

  test('posting a job is scoped to the shop owner', () async {
    await expectLater(
      JobService.instance.post(
        businessId: ShowcaseCatalog.bizPatil,
        posterId: ShowcaseCatalog.customer2,
        title: 'Night stocker',
        description: 'Should not write',
        jobType: 'Part-time',
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('No shop found'),
        ),
      ),
    );
  });
}
