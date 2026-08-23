import 'package:degloor_one/core/api/api_client.dart';

class ProductApi {
  ProductApi._();

  static final _http = JavaApiClient.instance;

  static Future<Map<String, dynamic>> search({
    String? q,
    String? businessId,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? available,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'size': '$size',
      if (q != null && q.isNotEmpty) 'q': q,
      if (businessId != null) 'businessId': businessId,
      if (categoryId != null) 'categoryId': categoryId,
      if (minPrice != null) 'minPrice': '$minPrice',
      if (maxPrice != null) 'maxPrice': '$maxPrice',
      if (available != null) 'available': '$available',
      if (sort != null) 'sort': sort,
    };
    return Map<String, dynamic>.from(await _http.get('/api/v1/products', query: query) as Map);
  }

  static Future<Map<String, dynamic>> byId(String id) async {
    return Map<String, dynamic>.from(await _http.get('/api/v1/products/$id') as Map);
  }

  static Future<List<dynamic>> forBusiness(String businessId) async {
    return List<dynamic>.from(await _http.get('/api/v1/businesses/$businessId/products') as List);
  }
}
