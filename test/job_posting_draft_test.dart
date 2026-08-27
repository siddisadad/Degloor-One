import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/job_posting_draft.dart';

void main() {
  test('job posting drafts only serialize insert fields', () {
    final draft = JobPostingDraft.fromForm(
      title: 'Night stocker',
      description: 'Restock shelves after closing.',
      jobType: 'Part-time',
      salaryRange: '₹400/night',
    );
    expect(
      draft.toInsertJson(businessId: 'biz-1', posterId: 'user-1'),
      {
        'business_id': 'biz-1',
        'poster_id': 'user-1',
        'title': 'Night stocker',
        'description': 'Restock shelves after closing.',
        'salary_range': '₹400/night',
        'job_type': 'Part-time',
        'location_text': null,
        'is_active': true,
      },
    );
    expect(
      draft.toInsertJson(businessId: 'biz-1', posterId: 'user-1').keys,
      isNot(contains('id')),
    );
    expect(
      draft.toInsertJson(businessId: 'biz-1', posterId: 'user-1').containsKey(
        'created_at',
      ),
      isFalse,
    );
  });

  test('fromForm trims the title and rejects an empty one', () {
    expect(
      JobPostingDraft.fromForm(
        title: '  Counter assistant  ',
        description: '  Help at the counter.  ',
        jobType: 'Full-time',
      ).title,
      'Counter assistant',
    );
    expect(
      () => JobPostingDraft.fromForm(
        title: '   ',
        description: 'Help at the counter.',
        jobType: 'Full-time',
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Job title'),
        ),
      ),
    );
  });
}
