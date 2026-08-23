import 'package:degloor_one/core/api/api_client.dart';

class DeliveryApi {
  DeliveryApi._();

  static final _http = JavaApiClient.instance;

  static Future<Map<String, dynamic>> myOrders() async {
    return Map<String, dynamic>.from(await _http.get('/api/v1/delivery/my-orders') as Map);
  }

  static Future<void> accept(String orderId) =>
      _http.post('/api/v1/delivery/orders/$orderId/accept');

  static Future<void> pickup(String orderId) =>
      _http.post('/api/v1/delivery/orders/$orderId/pickup');

  static Future<void> pickupAssignment(String assignmentId) =>
      _http.post('/api/v1/delivery/assignments/$assignmentId/pickup');

  static Future<void> verifyOtp({required String orderId, required String otp}) {
    return _http.post('/api/v1/delivery/orders/$orderId/otp/verify', {'otp': otp});
  }

  static Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) {
    return _http.post('/api/v1/delivery/location', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}
