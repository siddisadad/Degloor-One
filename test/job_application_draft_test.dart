import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/job_application_draft.dart';

void main() {
  test('application drafts only serialize submit fields', () {
    final draft = JobApplicationDraft.fromForm(
      jobId: 'job-1',
      applicantId: 'user-1',
      experienceSummary: 'Stocked a kirana for 6 months.',
    );
    expect(draft.toInsertJson(), {
      'job_id': 'job-1',
      'applicant_id': 'user-1',
      'experience_summary': 'Stocked a kirana for 6 months.',
      'status': JobApplicationDraft.applied,
    });
    expect(
      draft.toInsertJson().keys,
      ['job_id', 'applicant_id', 'experience_summary', 'status'],
    );
    expect(draft.toInsertJson().containsKey('id'), isFalse);
    expect(draft.toInsertJson().containsKey('created_at'), isFalse);
  });

  test('fromForm trims experience and rejects an empty summary', () {
    expect(
      JobApplicationDraft.fromForm(
        jobId: 'job-1',
        applicantId: 'user-1',
        experienceSummary: '  Helped at the counter.  ',
      ).experienceSummary,
      'Helped at the counter.',
    );
    expect(
      () => JobApplicationDraft.fromForm(
        jobId: 'job-1',
        applicantId: 'user-1',
        experienceSummary: '   ',
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('experience summary'),
        ),
      ),
    );
  });
}
