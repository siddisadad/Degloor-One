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

String _id(dynamic value) {
  if (value is String || value is num) return '$value'.trim();
  return '';
}

double? _double(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? _int(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
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
    final user = JoinedUser(
      fullName: _text(map['full_name'] ?? map['fullName']),
      avatarUrl: _text(map['avatar_url'] ?? map['avatarUrl']),
      phoneNumber: _text(map['phone_number'] ?? map['phoneNumber']),
    );
    if (user.fullName == null &&
        user.avatarUrl == null &&
        user.phoneNumber == null) {
      return null;
    }
    return user;
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

  /// Java `ApplicationResponse`.
  factory JobApplicant.fromJson(Map<String, dynamic> json) {
    return JobApplicant(
      id: '${json['id'] ?? ''}',
      status: _text(json['status']) ?? 'applied',
      experienceSummary: _text(json['experienceSummary']),
      user: JoinedUser.fromJoin(json['user'] ?? json['users']) ??
          JoinedUser.fromJoin(json),
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
      id: _id(data['id']),
      userId: _text(data['user_id']),
      categoryId: _text(data['category_id']),
      bio: _text(data['bio']),
      hourlyRate: _double(data['hourly_rate']),
      experienceYears: _int(data['experience_years']),
      isVerified: data['is_verified'] == true,
      user: JoinedUser.fromJoin(data['users']),
      category: JoinedCategory.fromJoin(data['service_categories']),
    );
  }

  /// Java `ProviderResponse`. User name joins stay on the table path.
  factory ServiceProviderCard.fromJson(
    Map<String, dynamic> json, {
    JoinedCategory? category,
  }) {
    return ServiceProviderCard(
      id: _id(json['id']),
      userId: _text(json['userId'] ?? json['user_id']),
      categoryId: _text(json['categoryId'] ?? json['category_id']),
      bio: _text(json['bio']),
      hourlyRate: _double(json['hourlyRate'] ?? json['hourly_rate']),
      experienceYears: _int(json['experienceYears'] ?? json['experience_years']),
      isVerified: json['verified'] == true || json['isVerified'] == true,
      category: category,
    );
  }

  String get displayName => user?.displayName(fallback: 'Unknown Provider') ??
      'Unknown Provider';

  String get categoryName => category?.displayName ?? 'General';

  /// Joined avatar URL, or null when the provider has no photo.
  String? get photoUrl {
    final url = user?.avatarUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return url;
  }

  /// Photo URL for widgets that still require a string.
  String avatarImageUrl({int width = 100, int height = 100}) {
    return photoUrl ?? '';
  }

  String get hourlyRateLabel {
    final rate = hourlyRate;
    if (rate == null) return 'Rate on request';
    final rounded =
        rate % 1 == 0 ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2);
    return '₹$rounded/hr';
  }
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

  factory ShopReview.fromJson(Map<String, dynamic> json) {
    return ShopReview(
      id: '${json['id'] ?? ''}',
      userId: '${json['userId'] ?? json['user_id'] ?? ''}',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: _text(json['comment']),
      createdAt: _date(json['createdAt'] ?? json['created_at']),
      user: JoinedUser.fromJoin(json['users'] ?? json['user']),
    );
  }

  String get authorName => user?.displayName(fallback: 'Anonymous') ?? 'Anonymous';

  String get initials {
    final parts = authorName.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }
}
