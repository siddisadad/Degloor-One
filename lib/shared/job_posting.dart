/// Shop-owned job. Screens use this instead of a table row.
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

  /// Java `JobResponse`.
  factory JobPosting.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return JobPosting(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      description: '${json['description'] ?? ''}',
      jobType: '${json['jobType'] ?? ''}',
      isActive: json['active'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      businessId: json['businessId'] == null ? null : '${json['businessId']}',
      posterId: json['posterId'] == null ? null : '${json['posterId']}',
      category: json['category'] as String?,
      salaryRange: json['salaryRange'] as String?,
      locationText: json['locationText'] as String?,
    );
  }
}
