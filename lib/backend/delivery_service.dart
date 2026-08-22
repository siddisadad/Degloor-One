import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class DeliveryService {
  static Future<void> acceptOrder(String orderId) {
    return _rpc('accept_delivery_order', {'p_order_id': orderId});
  }

  static Future<void> confirmPickup(String assignmentId) {
    return _rpc('confirm_delivery_pickup', {'p_assignment_id': assignmentId});
  }

  static Future<void> confirmDeliveryWithOtp({
    required String orderId,
    required String otp,
  }) {
    return _rpc('confirm_delivery_with_otp', {
      'p_order_id': orderId,
      'p_otp': otp,
    });
  }

  static Future<String?> fetchMyDeliveryOtp(String orderId) async {
    if (kUseShowcaseData) {
      final orders = ShowcaseCatalog.query(
        'orders',
        ShowcaseQuery()..eq('id', orderId),
      );
      return orders.isEmpty ? null : orders.first['delivery_otp'] as String?;
    }
    final result = await SupaFlow.client.rpc(
      'get_my_delivery_otp',
      params: {'p_order_id': orderId},
    );
    return result as String?;
  }

  static String messageFor(Object error) {
    if (error is PostgrestException && error.message.isNotEmpty) {
      return error.message;
    }
    final raw = error.toString();
    final match = RegExp(r'(?:Exception:|ERROR:)\s*(.+)').firstMatch(raw);
    return match?.group(1)?.trim() ?? 'Something went wrong. Please try again.';
  }

  static Future<void> _rpc(String name, Map<String, dynamic> params) async {
    if (kUseShowcaseData) {
      return;
    }
    await SupaFlow.client.rpc(name, params: params);
  }
}
