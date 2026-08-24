import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_draft.dart';

/// Data access for Degloor shops. Customer screens go through [ShopService];
/// owners go through [BusinessService]. Concrete implementations map table
/// rows or API JSON. Hours, catalogue, and reviews stay on leftover repos
/// until their slices.
abstract class ShopRepository {
  Future<Shop?> byId(String businessId);

  Future<List<Shop>> ownedBy(String userId);

  Future<Shop> insert(
    ShopDraft draft, {
    required String ownerId,
  });

  Future<void> update({
    required String businessId,
    required String ownerId,
    required ShopDraft draft,
  });
}
