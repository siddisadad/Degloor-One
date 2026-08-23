/// Normalize a PostgREST embedded join (`users(...)`, `businesses(...)`).
Map<String, dynamic>? asJoinMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is List && value.isNotEmpty) return asJoinMap(value.first);
  return null;
}

String? _text(dynamic value) {
  if (value == null) return null;
  final text = '$value'.trim();
  return text.isEmpty ? null : text;
}

DateTime? _date(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class JoinedUser {
  const JoinedUser({
    this.fullName,
    this.avatarUrl,
    this.phoneNumber,
  });

  final String? fullName;
  final String? avatarUrl;
  final String? phoneNumber;

  static JoinedUser? fromJoin(dynamic value) {
    final map = asJoinMap(value);
    if (map == null || map.isEmpty) return null;
    return JoinedUser(
      fullName: _text(map['full_name']),
      avatarUrl: _text(map['avatar_url']),
      phoneNumber: _text(map['phone_number']),
    );
  }

  String displayName({String fallback = 'Unknown'}) {
    return fullName ?? fallback;
  }
}

class JoinedShop {
  const JoinedShop({
    this.name,
    this.location,
    this.addressText,
  });

  final String? name;
  final String? location;
  final String? addressText;

  static JoinedShop? fromJoin(dynamic value) {
    final map = asJoinMap(value);
    if (map == null || map.isEmpty) return null;
    return JoinedShop(
      name: _text(map['name']),
      location: _text(map['location']),
      addressText: _text(map['address_text']),
    );
  }

  String get displayName => name ?? 'Employer';

  String get displayLocation => addressText ?? location ?? 'Degloor';
}

class JoinedCategory {
  const JoinedCategory({this.name});

  final String? name;

  static JoinedCategory? fromJoin(dynamic value) {
    final map = asJoinMap(value);
    if (map == null || map.isEmpty) return null;
    return JoinedCategory(name: _text(map['name']));
  }

  String get displayName => name ?? 'General';
}

/// Active job listing with an optional shop join.
class JobListing {
  const JobListing({
    required this.id,
    required this.title,
    required this.jobType,
    this.salaryRange,
    this.shop,
  });

  final String id;
  final String title;
  final String jobType;
  final String? salaryRange;
  final JoinedShop? shop;

  factory JobListing.fromJoin(Map<String, dynamic> data) {
    return JobListing(
      id: '${data['id'] ?? ''}',
      title: _text(data['title']) ?? 'Job Title',
      jobType: _text(data['job_type']) ?? 'Type',
      salaryRange: _text(data['salary_range']),
      shop: JoinedShop.fromJoin(data['businesses']),
    );
  }
}

/// Job application with an optional applicant join.
class JobApplicant {
  const JobApplicant({
    required this.id,
    required this.status,
    this.experienceSummary,
    this.user,
  });

  final String id;
  final String status;
  final String? experienceSummary;
  final JoinedUser? user;

  factory JobApplicant.fromJoin(Map<String, dynamic> data) {
    return JobApplicant(
      id: '${data['id'] ?? ''}',
      status: _text(data['status']) ?? 'applied',
      experienceSummary: _text(data['experience_summary']),
      user: JoinedUser.fromJoin(data['users']),
    );
  }
}

/// Service provider with user and category joins.
class ServiceProviderCard {
  const ServiceProviderCard({
    required this.id,
    this.userId,
    this.categoryId,
    this.bio,
    this.hourlyRate,
    this.experienceYears,
    this.isVerified = false,
    this.user,
    this.category,
  });

  final String id;
  final String? userId;
  final String? categoryId;
  final String? bio;
  final double? hourlyRate;
  final int? experienceYears;
  final bool isVerified;
  final JoinedUser? user;
  final JoinedCategory? category;

  factory ServiceProviderCard.fromJoin(Map<String, dynamic> data) {
    return ServiceProviderCard(
      id: '${data['id'] ?? ''}',
      userId: _text(data['user_id']),
      categoryId: _text(data['category_id']),
      bio: _text(data['bio']),
      hourlyRate: (data['hourly_rate'] as num?)?.toDouble(),
      experienceYears: (data['experience_years'] as num?)?.toInt(),
      isVerified: data['is_verified'] == true,
      user: JoinedUser.fromJoin(data['users']),
      category: JoinedCategory.fromJoin(data['service_categories']),
    );
  }

  String get displayName => user?.displayName(fallback: 'Unknown Provider') ??
      'Unknown Provider';

  String get categoryName => category?.displayName ?? 'General';
}

/// Shop review with an optional reviewer join.
class ShopReview {
  const ShopReview({
    required this.id,
    required this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.user,
  });

  final String id;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final JoinedUser? user;

  factory ShopReview.fromJoin(Map<String, dynamic> data) {
    return ShopReview(
      id: '${data['id'] ?? ''}',
      userId: '${data['user_id'] ?? ''}',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: _text(data['comment']),
      createdAt: _date(data['created_at']),
      user: JoinedUser.fromJoin(data['users']),
    );
  }

  String get authorName => user?.displayName(fallback: 'Anonymous') ?? 'Anonymous';

  String get initials {
    final parts = authorName.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }
}
