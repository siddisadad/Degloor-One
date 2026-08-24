import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/page_query.dart';

/// Data access for riders. Widgets should go through [DeliveryService].
/// Table-backed implementation; Java leftover reads live on [DeliveryService].
class DeliveryRepository {
  Future<DeliveryPartnersRow?> partnerForUser(String userId) async {
    if (userId.isEmpty) return null;
    final rows = await DeliveryPartnersTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<DeliveryPartnersRow> registerPartner(String userId) {
    return DeliveryPartnersTable().insert({
      'user_id': userId,
      'is_available': false,
      'is_verified': false,
    });
  }

  Future<void> setAvailability({
    required String partnerId,
    required bool available,
  }) async {
    if (partnerId.isEmpty) return;
    await DeliveryPartnersTable().update(
      data: {'is_available': available},
      matchingRows: (src) => src.eq('id', partnerId),
    );
  }

  Future<DeliveryAssignmentsRow?> activeForPartner(String partnerId) async {
    if (partnerId.isEmpty) return null;
    final rows = await DeliveryAssignmentsTable().queryRows(
      queryFn: (q) =>
          q.eq('delivery_partner_id', partnerId).neq('status', 'delivered'),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<OrdersRow>> readyOrders({
    PageQuery page = const PageQuery(),
  }) {
    return OrdersTable().queryRows(
      queryFn: (q) => q
          .eq('status', OrderLifecycle.ready)
          .order('created_at', ascending: false),
      limit: page.limit,
      offset: page.offset,
    );
  }

  Future<DeliveryAssignmentsRow?> activeAssignment(String orderId) async {
    if (orderId.isEmpty) return null;
    final rows = await DeliveryAssignmentsTable().queryRows(
      queryFn: (q) => q.eq('order_id', orderId).neq('status', 'delivered'),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Stream<List<DeliveryPartnersRow>> watchPartner(String partnerId) {
    return DeliveryPartnersTable().stream(
      primaryKey: 'id',
      queryFn: (q) => q.eq('id', partnerId),
    );
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? partnerId,
    String? userId,
  }) {
    return DeliveryPartnersTable().update(
      data: {
        'current_latitude': latitude,
        'current_longitude': longitude,
      },
      matchingRows: (q) {
        if (partnerId != null && partnerId.isNotEmpty) {
          return q.eq('id', partnerId);
        }
        return q.eq('user_id', userId);
      },
    );
  }
}
