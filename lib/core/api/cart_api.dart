import 'package:degloor_one/core/api/api_client.dart';

class CartApi {
  CartApi._();

  static final _http = JavaApiClient.instance;

  static Future<Map<String, dynamic>> get() async {
    return Map<String, dynamic>.from(await _http.get('/api/v1/cart') as Map);
  }

  static Future<Map<String, dynamic>> addItem({
    required String productId,
    int quantity = 1,
    bool replaceOtherBusiness = false,
  }) async {
    return Map<String, dynamic>.from(await _http.post('/api/v1/cart/items', {
      'productId': productId,
      'quantity': quantity,
      'replaceOtherBusiness': replaceOtherBusiness,
    }) as Map);
  }

  static Future<Map<String, dynamic>> updateItem({
    required String productId,
    required int quantity,
  }) async {
    return Map<String, dynamic>.from(await _http.put(
      '/api/v1/cart/items/$productId',
      {'quantity': quantity},
    ) as Map);
  }

  static Future<void> removeItem(String productId) {
    return _http.delete('/api/v1/cart/items/$productId');
  }

  static Future<void> clear() => _http.delete('/api/v1/cart');
}
