import 'package:degloor_one/backend/supabase/database/tables/jobs_table.dart';

/// Shop-owned job. Screens use this instead of [JobsRow].
/// Marketplace cards stay on [JobListing].
class JobPosting {
  const JobPosting({
    required this.id,
    required this.title,
    required this.description,
    required this.jobType,
    required this.isActive,
    required this.createdAt,
    this.businessId,
    this.posterId,
    this.category,
    this.salaryRange,
    this.locationText,
  });

  final String id;
  final String title;
  final String description;
  final String jobType;
  final bool isActive;
  final DateTime createdAt;
  final String? businessId;
  final String? posterId;
  final String? category;
  final String? salaryRange;
  final String? locationText;

  factory JobPosting.fromRow(JobsRow row) {
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
}
