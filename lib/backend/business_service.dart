import 'dart:typed_data';

import 'package:degloor_one/backend/repositories/business_repository.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/catalog_product_draft.dart';
import 'package:degloor_one/shared/catalog_product_stock.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/product_category_draft.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_hours.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class ProfileCompleteness {
  const ProfileCompleteness({
    required this.ratio,
    required this.hint,
  });

  static const empty = ProfileCompleteness(ratio: 0, hint: '');

  final double ratio;
  final String hint;

  int get percent => (ratio * 100).toInt();
}

class BusinessService {
  BusinessService({BusinessRepository? repository})
      : _repository = repository ?? BusinessRepository();

  final BusinessRepository _repository;

  static final instance = BusinessService();

  static ProfileCompleteness completeness(Shop? shop) {
    if (shop == null) return ProfileCompleteness.empty;
    var score = 0;
    if (shop.name.trim().isNotEmpty) score += 10;
    if ((shop.description ?? '').trim().isNotEmpty) score += 15;
    if ((shop.categoryId ?? '').isNotEmpty) score += 10;
    if ((shop.whatsappNumber ?? '').trim().isNotEmpty) score += 10;
    if ((shop.addressText ?? '').trim().isNotEmpty) score += 15;
    if ((shop.latitude ?? 0) != 0 && (shop.longitude ?? 0) != 0) score += 20;
    if ((shop.imageUrl ?? '').trim().isNotEmpty) score += 20;

    final hint = (shop.imageUrl ?? '').isEmpty
        ? 'Add business photos to reach 100%'
        : (shop.description ?? '').isEmpty
            ? 'Describe what you provide to help customers find you'
            : (shop.addressText ?? '').isEmpty
                ? 'Add your shop address for better visibility'
                : (shop.latitude ?? 0) == 0
                    ? 'Pin your location on the map for accurate delivery'
                    : 'Your profile looks great!';
    return ProfileCompleteness(ratio: score / 100, hint: hint);
  }

  static const _signInMessage = 'Please sign in to manage your shop';
  static const _missingShopMessage = 'No shop found for this account';
  static const _missingProductMessage = 'Product not found';

  Future<List<Shop>> ownedBy(String userId) async {
    if (userId.isEmpty) return const [];
    final rows = await _repository.ownedBy(userId);
    return rows.map(Shop.fromRow).toList();
  }

  Future<Shop> requireOwned(String userId) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    final shops = await _repository.ownedBy(userId);
    if (shops.isEmpty) {
      throw Exception(_missingShopMessage);
    }
    return Shop.fromRow(shops.first);
  }

  Future<Shop> requireOwnedBusiness({
    required String userId,
    required String businessId,
  }) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    final shop = await _repository.byId(businessId);
    if (shop == null || shop.ownerId != userId) {
      throw Exception(_missingShopMessage);
    }
    return Shop.fromRow(shop);
  }

  Future<Shop> register({
    required String userId,
    required String name,
    required String ownerName,
    required String phone,
    required String categoryId,
    required double latitude,
    required double longitude,
    String description = '',
    String? whatsappNumber,
    String addressText = '',
    double discoveryRadius = 5,
  }) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    final trimmedName = name.trim();
    final trimmedOwner = ownerName.trim();
    final trimmedPhone = phone.trim();
    if (trimmedName.isEmpty ||
        trimmedOwner.isEmpty ||
        trimmedPhone.isEmpty ||
        categoryId.isEmpty) {
      throw Exception('Please fill all required fields');
    }
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw Exception('Please pick a location on the map');
    }

    final row = await _repository.insertBusiness({
      'owner_id': userId,
      'name': trimmedName,
      'owner_name': trimmedOwner,
      'description': description.trim(),
      'phone_number': trimmedPhone,
      'whatsapp_number': (whatsappNumber ?? trimmedPhone).trim(),
      'address_text': addressText.trim(),
      'category_id': categoryId,
      'latitude': latitude,
      'longitude': longitude,
      'discovery_radius': discoveryRadius,
      'is_verified': false,
    });

    // Live RLS blocks client role changes. Showcase still needs the owner role
    // so the dashboard route works after local registration.
    if (kUseShowcaseData) {
      ShowcaseCatalog.update(
        'users',
        {'role': 'business_owner'},
        ShowcaseQuery()..eq('id', userId),
      );
    }
    return Shop.fromRow(row);
  }

  Future<void> updateProfile({
    required String userId,
    required String businessId,
    required String name,
    String? ownerName,
    String? description,
    String? phoneNumber,
    String? whatsappNumber,
    String? addressText,
    double? discoveryRadius,
    String? imageUrl,
  }) async {
    await requireOwnedBusiness(userId: userId, businessId: businessId);
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Business name is required');
    }
    await _repository.updateBusiness(
      businessId: businessId,
      ownerId: userId,
      data: {
        'name': trimmedName,
        'owner_name': ownerName?.trim(),
        'description': description?.trim(),
        'phone_number': phoneNumber?.trim(),
        'whatsapp_number': whatsappNumber?.trim(),
        'address_text': addressText?.trim(),
        if (discoveryRadius != null) 'discovery_radius': discoveryRadius,
        'image_url': imageUrl,
      },
    );
  }

  Future<List<CatalogProduct>> products(String userId) async {
    final shop = await requireOwned(userId);
    final rows = await _repository.productsFor(shop.id);
    return rows.map(CatalogProduct.fromRow).toList();
  }

  Future<List<ProductCategory>> productCategories(String userId) async {
    final shop = await requireOwned(userId);
    final rows = await _repository.productCategoriesFor(shop.id);
    return rows.map(ProductCategory.fromRow).toList();
  }

  Future<CatalogProduct> addProduct({
    required String userId,
    required CatalogProductDraft draft,
  }) async {
    final shop = await requireOwned(userId);
    final trimmedName = draft.name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Please enter a product name');
    }
    if (draft.price < 0) {
      throw Exception('Please enter a valid price');
    }
    if (draft.stock.quantity < 0) {
      throw Exception('Please enter a valid stock quantity');
    }

    String? categoryId;
    final trimmedCategory = draft.categoryName.trim();
    if (trimmedCategory.isNotEmpty) {
      final existing = await _repository.productCategoriesFor(shop.id);
      for (final category in existing) {
        if (category.name.toLowerCase() == trimmedCategory.toLowerCase()) {
          categoryId = category.id;
          break;
        }
      }
      if (categoryId == null) {
        final created = await _repository.insertProductCategory(
          ProductCategoryDraft(
            businessId: shop.id,
            name: trimmedCategory,
          ),
        );
        categoryId = created.id;
      }
    }

    return _repository.insertProduct(
      draft: draft,
      businessId: shop.id,
      categoryId: categoryId,
    );
  }

  Future<void> updateProduct({
    required String userId,
    required String productId,
    required CatalogProductDraft draft,
  }) async {
    final shop = await requireOwned(userId);
    final existing = await _repository.productForBusiness(
      businessId: shop.id,
      productId: productId,
    );
    if (existing == null) {
      throw Exception(_missingProductMessage);
    }
    if (draft.name.trim().isEmpty) {
      throw Exception('Please enter a product name');
    }
    if (draft.price < 0) {
      throw Exception('Please enter a valid price');
    }
    await _repository.updateProduct(
      productId: productId,
      businessId: shop.id,
      draft: draft,
    );
  }

  Future<void> updateStock({
    required String userId,
    required String productId,
    required CatalogProductStock stock,
  }) async {
    if (stock.quantity < 0) {
      throw Exception('Please enter a valid stock quantity');
    }
    final shop = await requireOwned(userId);
    final existing = await _repository.productForBusiness(
      businessId: shop.id,
      productId: productId,
    );
    if (existing == null) {
      throw Exception(_missingProductMessage);
    }
    await _repository.updateStock(
      productId: productId,
      businessId: shop.id,
      stock: stock,
    );
  }

  Future<void> deleteProduct({
    required String userId,
    required String productId,
  }) async {
    final shop = await requireOwned(userId);
    final existing = await _repository.productForBusiness(
      businessId: shop.id,
      productId: productId,
    );
    if (existing == null) {
      throw Exception(_missingProductMessage);
    }
    await _repository.deleteProduct(
      productId: productId,
      businessId: shop.id,
    );
  }

  Future<List<ShopHours>> hours(String userId) async {
    final shop = await requireOwned(userId);
    final hours = (await _repository.hoursFor(shop.id))
        .map(ShopHours.fromRow)
        .toList();
    final existingDays = hours.map((row) => row.dayOfWeek).toSet();
    for (var day = 0; day < 7; day++) {
      if (existingDays.contains(day)) continue;
      hours.add(
        ShopHours(
          businessId: shop.id,
          dayOfWeek: day,
          openTime: DateTime(1970, 1, 1, 9),
          closeTime: DateTime(1970, 1, 1, 18),
          createdAt: DateTime.now(),
        ),
      );
    }
    hours.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    return hours;
  }

  Future<void> saveHours({
    required String userId,
    required List<ShopHours> hours,
  }) async {
    final shop = await requireOwned(userId);
    await _repository.upsertHours(hours, businessId: shop.id);
  }

  Future<String> uploadPublicImage({
    required String folder,
    required String businessId,
    required List<int> bytes,
    String extension = 'jpg',
  }) async {
    if (bytes.isEmpty) {
      throw Exception('Please choose an image');
    }
    final path =
        '$folder/$businessId/${DateTime.now().millisecondsSinceEpoch}.$extension';
    if (kUseShowcaseData) {
      return 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=80';
    }
    try {
      await SupaFlow.client.storage
          .from('product-images')
          .uploadBinary(path, Uint8List.fromList(bytes));
      return SupaFlow.client.storage.from('product-images').getPublicUrl(path);
    } catch (e) {
      AppLogger.error('Error uploading shop image', e);
      throw Exception('Unable to upload the image. Please try again.');
    }
  }

  static String timeLabel(DateTime? time) {
    if (time != null) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return 'Select';
  }

  static String timeSql(DateTime? time) => ShopHours.sqlTime(time);
}
