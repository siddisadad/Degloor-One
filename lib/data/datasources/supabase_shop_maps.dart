import 'package:degloor_one/backend/supabase/database/tables/business_analytics_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/business_categories_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/business_hours_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/complaints_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/product_categories_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/products_table.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/shared/shop_event.dart';
import 'package:degloor_one/shared/shop_hours.dart';

ShopHours shopHoursFromRow(BusinessHoursRow row) {
  final rawId = row.data['id'];
  return ShopHours(
    id: rawId == null || '$rawId'.isEmpty ? null : '$rawId',
    businessId: row.businessId,
    dayOfWeek: row.dayOfWeek,
    openTime: row.openTime?.time,
    closeTime: row.closeTime?.time,
    isClosed: row.isClosed,
    createdAt: row.createdAt,
  );
}

CatalogProduct catalogProductFromRow(ProductsRow row) {
  return CatalogProduct(
    id: row.id,
    businessId: row.businessId,
    name: row.name,
    createdAt: row.createdAt,
    categoryId: row.categoryId,
    description: row.description,
    price: row.price,
    imageUrl: row.imageUrl,
    isAvailable: row.isAvailable,
    stockQuantity: row.stockQuantity,
    trackInventory: row.trackInventory,
    distanceKm: row.distanceKm,
  );
}

ShopCategory shopCategoryFromRow(BusinessCategoriesRow row) {
  final rawCreated = row.data['created_at'];
  DateTime? createdAt;
  if (rawCreated is DateTime) {
    createdAt = rawCreated;
  } else if (rawCreated != null) {
    createdAt = DateTime.tryParse('$rawCreated');
  }
  return ShopCategory(
    id: row.id,
    name: row.name,
    iconName: row.iconName,
    displayOrder: row.displayOrder,
    createdAt: createdAt,
  );
}

ProductCategory productCategoryFromRow(ProductCategoriesRow row) {
  return ProductCategory(
    id: row.id,
    businessId: row.businessId,
    name: row.name,
    createdAt: row.createdAt,
  );
}

ListingComplaint listingComplaintFromRow(ComplaintsRow row) {
  return ListingComplaint(
    id: row.id,
    userId: row.userId,
    subject: row.subject,
    description: row.description,
    status: row.status,
    createdAt: row.createdAt,
    orderId: row.orderId,
    businessId: row.businessId,
  );
}

ShopEvent shopEventFromRow(BusinessAnalyticsRow row) {
  final raw = row.metadata;
  return ShopEvent(
    id: row.id,
    businessId: row.businessId,
    eventType: row.eventType,
    createdAt: row.createdAt,
    userId: row.userId,
    metadata: raw is Map<String, dynamic> ? raw : null,
  );
}
