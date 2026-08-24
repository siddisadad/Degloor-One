import 'package:degloor_one/backend/supabase/database/tables/job_applications_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/jobs_table.dart';
import 'package:degloor_one/shared/job_application.dart';
import 'package:degloor_one/shared/job_posting.dart';

JobPosting jobPostingFromRow(JobsRow row) {
  return JobPosting(
    id: row.id,
    title: row.title,
    description: row.description,
    jobType: row.jobType,
    isActive: row.isActive,
    createdAt: row.createdAt,
    businessId: row.businessId,
    posterId: row.posterId,
    category: row.category,
    salaryRange: row.salaryRange,
    locationText: row.locationText,
  );
}

JobApplication jobApplicationFromRow(JobApplicationsRow row) {
  return JobApplication(
    id: row.id,
    jobId: row.jobId,
    applicantId: row.applicantId,
    status: row.status,
    createdAt: row.createdAt,
    experienceSummary: row.experienceSummary,
  );
}
