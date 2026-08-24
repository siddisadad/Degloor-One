import 'package:degloor_one/backend/supabase/database/tables/carts_table.dart';
import 'package:degloor_one/shared/shopping_cart.dart';

ShoppingCart shoppingCartFromRow(CartsRow row) {
  return ShoppingCart(
    id: row.id,
    userId: row.userId,
    businessId: row.businessId,
    createdAt: row.createdAt,
  );
}
