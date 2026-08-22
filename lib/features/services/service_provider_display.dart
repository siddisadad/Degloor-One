/// Display helpers for PostgREST `service_providers` rows that embed
/// `users` and `service_categories`. Those joins are null when the FK is
/// missing or the related row was deleted.
class ServiceProviderDisplay {
  static const fallbackAvatarUrl =
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&h=100&q=80';

  static Map<String, dynamic>? asJoinMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String name(dynamic user) {
    final fullName = asJoinMap(user)?['full_name'];
    if (fullName is String && fullName.trim().isNotEmpty) {
      return fullName.trim();
    }
    return 'Unknown Provider';
  }

  static String avatarUrl(dynamic user) {
    final url = asJoinMap(user)?['avatar_url'];
    if (url is String && url.trim().isNotEmpty) {
      return url.trim();
    }
    return fallbackAvatarUrl;
  }

  static String categoryName(dynamic category) {
    final name = asJoinMap(category)?['name'];
    if (name is String && name.trim().isNotEmpty) {
      return name.trim();
    }
    return 'General';
  }

  static String hourlyRateLabel(dynamic rate) {
    if (rate is num) {
      final rounded = rate % 1 == 0 ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2);
      return '₹$rounded/hr';
    }
    return 'Rate on request';
  }
}
