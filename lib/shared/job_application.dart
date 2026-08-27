import 'package:degloor_one/shared/job_application_draft.dart';

/// Application without the applicant join. Screens use this instead of
/// a table row. Owner lists stay on [JobApplicant].
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

  /// Java `ApplicationResponse`.
  factory JobApplication.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return JobApplication(
      id: '${json['id'] ?? ''}',
      jobId: '${json['jobId'] ?? ''}',
      applicantId: '${json['applicantId'] ?? ''}',
      status: '${json['status'] ?? JobApplicationDraft.applied}',
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      experienceSummary: json['experienceSummary'] as String?,
    );
  }
}
