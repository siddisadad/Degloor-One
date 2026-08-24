/// Provider account without the user/category join. Screens use this
/// instead of a table row. Marketplace cards stay on [ServiceProviderCard].
class ServiceProviderProfile {
  const ServiceProviderProfile({
    required this.id,
    required this.isVerified,
    required this.createdAt,
    this.userId,
    this.categoryId,
    this.bio,
    this.hourlyRate,
    this.experienceYears,
  });

  final String id;
  final bool isVerified;
  final DateTime createdAt;
  final String? userId;
  final String? categoryId;
  final String? bio;
  final double? hourlyRate;
  final int? experienceYears;

  /// Java `ProviderResponse`.
  factory ServiceProviderProfile.fromJson(Map<String, dynamic> json) {
    return ServiceProviderProfile(
      id: '${json['id'] ?? ''}',
      isVerified:
          json['verified'] as bool? ?? json['isVerified'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      userId: json['userId'] == null ? null : '${json['userId']}',
      categoryId: json['categoryId'] == null ? null : '${json['categoryId']}',
      bio: json['bio'] as String?,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      experienceYears: (json['experienceYears'] as num?)?.toInt(),
    );
  }
}
