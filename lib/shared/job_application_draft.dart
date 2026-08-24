/// Fields a customer submits when applying to a job.
/// Id and createdAt stay off this type. Status is the stored
/// applied value, not a client-invented state machine.
class JobApplicationDraft {
  const JobApplicationDraft({
    required this.jobId,
    required this.applicantId,
    required this.experienceSummary,
    this.status = applied,
  });

  static const applied = 'applied';

  final String jobId;
  final String applicantId;
  final String experienceSummary;
  final String status;

  /// Parse the apply form. Experience stays off the widget.
  factory JobApplicationDraft.fromForm({
    required String jobId,
    required String applicantId,
    required String experienceSummary,
  }) {
    final summary = experienceSummary.trim();
    if (summary.isEmpty) {
      throw Exception('Please enter your experience summary');
    }
    return JobApplicationDraft(
      jobId: jobId,
      applicantId: applicantId,
      experienceSummary: summary,
    );
  }

  /// Table insert only. Never includes id or created_at.
  Map<String, dynamic> toInsertJson() {
    return {
      'job_id': jobId,
      'applicant_id': applicantId,
      'experience_summary': experienceSummary,
      'status': status,
    };
  }
}
