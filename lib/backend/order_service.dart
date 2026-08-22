import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class OrderService {
  /// Local checkout used when the FlutterFlow host is down.
  static Map<String, dynamic> placeShowcaseOrder({
    required String userId,
    required String businessId,
    required String cartId,
    required String addressId,
    required double totalAmount,
    required double deliveryFee,
    required List<Map<String, dynamic>> items,
    String paymentMethod = 'COD',
    String deliveryOtp = '7392',
  }) {
    final order = ShowcaseCatalog.insert('orders', {
      'user_id': userId,
      'business_id': businessId,
      'total_amount': totalAmount,
      'status': OrderLifecycle.pending,
      'payment_status': OrderLifecycle.unpaid,
      'delivery_address_id': addressId,
      'delivery_fee': deliveryFee,
      'payment_method': paymentMethod,
      'delivery_otp': deliveryOtp,
    });
    for (final item in items) {
      ShowcaseCatalog.insert('order_items', {
        'order_id': order['id'],
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price_at_purchase': item['price'],
      });
    }
    ShowcaseCatalog.insert('order_status_history', {
      'order_id': order['id'],
      'status': OrderLifecycle.pending,
      'notes': 'Order placed from showcase cart',
    });
    ShowcaseCatalog.delete(
      'cart_items',
      ShowcaseQuery()..eq('cart_id', cartId),
    );
    ShowcaseCatalog.delete(
      'carts',
      ShowcaseQuery()..eq('id', cartId),
    );
    return order;
  }
}
