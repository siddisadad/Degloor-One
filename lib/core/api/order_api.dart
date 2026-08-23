import 'package:degloor_one/core/api/api_client.dart';

class OrderApi {
  OrderApi._();

  static final _http = JavaApiClient.instance;

  static Future<Map<String, dynamic>> checkout({
    required String addressId,
    String paymentMethod = 'COD',
  }) async {
    return Map<String, dynamic>.from(await _http.post('/api/v1/orders', {
      'addressId': addressId,
      'paymentMethod': paymentMethod,
    }) as Map);
  }

  static Future<Map<String, dynamic>> list({int page = 0, int size = 20}) async {
    return Map<String, dynamic>.from(await _http.get('/api/v1/orders', query: {
      'page': '$page',
      'size': '$size',
    }) as Map);
  }

  static Future<Map<String, dynamic>> byId(String id) async {
    return Map<String, dynamic>.from(await _http.get('/api/v1/orders/$id') as Map);
  }

  static Future<Map<String, dynamic>> cancel(String id, {String? reason}) async {
    return Map<String, dynamic>.from(await _http.post(
      '/api/v1/orders/$id/cancel',
      {if (reason != null) 'reason': reason},
    ) as Map);
  }

  static Future<Map<String, dynamic>> ownerStatus(String id, String status) async {
    return Map<String, dynamic>.from(
        await _http.post('/api/v1/orders/$id/status', {'status': status}) as Map);
  }

  static Future<String?> deliveryOtp(String id) async {
    final data = await _http.get('/api/v1/orders/$id/delivery-otp');
    return (data as Map)['otp'] as String?;
  }
}
