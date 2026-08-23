import 'package:degloor_one/backend/supabase/database/tables/job_applications_table.dart';

/// Application without the applicant join. Screens use this instead of
/// [JobApplicationsRow]. Owner lists stay on [JobApplicant].
class JobApplication {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.status,
    required this.createdAt,
    this.experienceSummary,
  });

  final String id;
  final String jobId;
  final String applicantId;
  final String status;
  final DateTime createdAt;
  final String? experienceSummary;

  factory JobApplication.fromRow(JobApplicationsRow row) {
    return JobApplication(
      id: row.id,
      jobId: row.jobId,
      applicantId: row.applicantId,
      status: row.status,
      createdAt: row.createdAt,
      experienceSummary: row.experienceSummary,
    );
  }
}
