/// Fields an owner submits when posting a job.
/// Id, createdAt, and the shop join stay off this type except the
/// stored active insert default.
class JobPostingDraft {
  const JobPostingDraft({
    required this.title,
    required this.description,
    required this.jobType,
    this.salaryRange,
    this.locationText,
  });

  final String title;
  final String description;
  final String jobType;
  final String? salaryRange;
  final String? locationText;

  /// Parse the post-job form. Title stays off the widget.
  factory JobPostingDraft.fromForm({
    required String title,
    required String description,
    required String jobType,
    String? salaryRange,
    String? locationText,
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw Exception('Job title is required');
    }
    return JobPostingDraft(
      title: trimmed,
      description: description.trim(),
      jobType: jobType,
      salaryRange: salaryRange?.trim(),
      locationText: locationText,
    );
  }

  /// Table insert only. Never includes id or created_at.
  /// [businessId] is the owned shop; [posterId] is the signed-in owner.
  /// New posts stay active, the same stored default as before.
  Map<String, dynamic> toInsertJson({
    required String businessId,
    required String posterId,
  }) {
    return {
      'business_id': businessId,
      'poster_id': posterId,
      'title': title,
      'description': description,
      'salary_range': salaryRange,
      'job_type': jobType,
      'location_text': locationText,
      'is_active': true,
    };
  }
}
