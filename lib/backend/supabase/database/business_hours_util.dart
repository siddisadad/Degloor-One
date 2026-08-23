import 'package:degloor_one/backend/shop_service.dart';

/// Kept for leftover callers. Prefer [ShopService.isOpenNow].
Future<bool> getBusinessOpenStatus(String businessId) {
  return ShopService.instance.isOpenNow(businessId);
}

/// Kept for leftover callers. Prefer [ShopService.isOpenNowBatch].
Future<Map<String, bool>> getMultipleBusinessesOpenStatus(
    List<String> businessIds) {
  return ShopService.instance.isOpenNowBatch(businessIds);
}
