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

  static Future<Map<String, dynamic>> provider(String id) async {
    return Map<String, dynamic>.from(
      await _http.get('/api/v1/services/providers/$id') as Map,
    );
  }

  static Future<List<Map<String, dynamic>>> inbox() async {
    return _rows(await _http.get('/api/v1/services/requests/inbox'));
  }
}
