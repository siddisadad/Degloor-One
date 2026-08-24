import 'package:degloor_one/core/api/api_client.dart';

class MarketplaceApi {
  MarketplaceApi._();

  static final _http = JavaApiClient.instance;

  static List<Map<String, dynamic>> _rows(dynamic data) {
    final rows = data is List ? data : const [];
    return [
      for (final row in rows.whereType<Map>()) Map<String, dynamic>.from(row),
    ];
  }

  static Future<List<Map<String, dynamic>>> categories() async {
    return _rows(await _http.get('/api/v1/services/categories'));
  }

  static Future<List<Map<String, dynamic>>> providers({String? categoryId}) async {
    return _rows(await _http.get('/api/v1/services/providers', query: {
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
    }));
  }

  static Future<Map<String, dynamic>> register({
    required String categoryId,
    required String bio,
    required double hourlyRate,
    required int experienceYears,
  }) async {
    return Map<String, dynamic>.from(await _http.post('/api/v1/services/providers', {
      'categoryId': categoryId,
      'bio': bio,
      'hourlyRate': hourlyRate,
      'experienceYears': experienceYears,
    }) as Map);
  }

  static Future<Map<String, dynamic>> createRequest({
    required String providerId,
    required String description,
    required DateTime scheduledAt,
  }) async {
    return Map<String, dynamic>.from(await _http.post('/api/v1/services/requests', {
      'providerId': providerId,
      'description': description,
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    }) as Map);
  }

  static Future<Map<String, dynamic>> updateStatus({
    required String requestId,
    required String status,
  }) async {
    return Map<String, dynamic>.from(await _http.post(
      '/api/v1/services/requests/$requestId/status',
      {'status': status},
    ) as Map);
  }
}
