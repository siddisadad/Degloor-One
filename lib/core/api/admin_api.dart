import 'package:degloor_one/core/api/api_client.dart';

class AdminApi {
  AdminApi._();

  static final _http = JavaApiClient.instance;

  static Future<Map<String, dynamic>> businesses({
    int page = 0,
    int size = 50,
  }) async {
    return Map<String, dynamic>.from(
      await _http.get('/api/v1/admin/businesses', query: {
        'page': '$page',
        'size': '$size',
      }) as Map,
    );
  }

  static Future<Map<String, dynamic>> complaints({
    int page = 0,
    int size = 50,
  }) async {
    return Map<String, dynamic>.from(
      await _http.get('/api/v1/admin/complaints', query: {
        'page': '$page',
        'size': '$size',
      }) as Map,
    );
  }

  static Future<List<Map<String, dynamic>>> categories() async {
    final rows = await _http.get('/api/v1/categories');
    final list = rows is List ? rows : const [];
    return [
      for (final row in list.whereType<Map>()) Map<String, dynamic>.from(row),
    ];
  }
}
