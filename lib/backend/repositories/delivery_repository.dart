import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:degloor_one/shared/page_query.dart';

/// Data access for riders. Widgets should go through [DeliveryService].
class DeliveryRepository {
  Future<DeliveryPartnersRow?> partnerForUser(String userId) async {
    if (userId.isEmpty) return null;
    final rows = await DeliveryPartnersTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId),
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<DeliveryPartnersRow> registerPartner(String userId) async {
    final existing = await partnerForUser(userId);
    if (existing != null) return existing;
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
      queryFn: (q) => q
          .eq('delivery_partner_id', partnerId)
          .neq('status', 'delivered')
          .order('created_at', ascending: false),
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
}
