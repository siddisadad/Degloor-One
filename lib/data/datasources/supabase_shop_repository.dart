import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/data/datasources/supabase_shop_maps.dart';
import 'package:degloor_one/data/repositories/shop_repository.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_draft.dart';

/// Showcase or live table access for `public.businesses`.
class SupabaseShopRepository implements ShopRepository {
  Shop _toShop(BusinessesRow row) => shopFromRow(row);

  @override
  Future<Shop?> byId(String businessId) async {
    if (businessId.isEmpty) return null;
    final rows = await BusinessesTable().queryRows(
      queryFn: (q) => q.eq('id', businessId),
      limit: 1,
    );
    return rows.isEmpty ? null : _toShop(rows.first);
  }

  @override
  Future<List<Shop>> ownedBy(String userId) async {
    if (userId.isEmpty) return const [];
    final rows = await BusinessesTable().queryRows(
      queryFn: (q) => q.eq('owner_id', userId),
    );
    return rows.map(_toShop).toList();
  }

  @override
  Future<Shop> insert(
    ShopDraft draft, {
    required String ownerId,
  }) async {
    final row = await BusinessesTable().insert(
      draft.toInsertJson(ownerId: ownerId),
    );
    return _toShop(row);
  }

  @override
  Future<void> update({
    required String businessId,
    required String ownerId,
    required ShopDraft draft,
  }) async {
    await BusinessesTable().update(
      data: draft.toUpdateJson(),
      matchingRows: (q) => q.eq('id', businessId).eq('owner_id', ownerId),
    );
  }
}
