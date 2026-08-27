import 'dart:typed_data';

import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/data/repositories/catalog_repository.dart';
import 'package:degloor_one/data/repositories/shop_repository.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/catalog_product_draft.dart';
import 'package:degloor_one/shared/catalog_product_stock.dart';
import 'package:degloor_one/shared/product_category.dart';
import 'package:degloor_one/shared/product_category_draft.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_draft.dart';
import 'package:degloor_one/shared/shop_hours.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:degloor_one/shared/user_role.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';

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
  BusinessService({
    required ShopRepository shops,
    required CatalogRepository catalog,
  })  : _shops = shops,
        _catalog = catalog;

  final ShopRepository _shops;
  final CatalogRepository _catalog;

  static BusinessService? _instance;

  static BusinessService get instance {
    final bound = _instance;
    if (bound == null) {
      throw StateError('BusinessService is not bound.');
    }
    return bound;
  }

  /// Called from the composition root with concrete repositories.
  static void bind(
    ShopRepository shops, {
    required CatalogRepository catalog,
  }) {
    _instance = BusinessService(shops: shops, catalog: catalog);
  }

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
    return _shops.ownedBy(userId);
  }

  Future<Shop> requireOwned(String userId) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    final shops = await _shops.ownedBy(userId);
    if (shops.isEmpty) {
      throw Exception(_missingShopMessage);
    }
    return shops.first;
  }

  Future<Shop> requireOwnedBusiness({
    required String userId,
    required String businessId,
  }) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    final shop = await _shops.byId(businessId);
    if (shop == null || shop.ownerId != userId) {
      throw Exception(_missingShopMessage);
    }
    return shop;
  }

  Future<Shop> register({
    required String userId,
    required ShopDraft draft,
  }) async {
    if (userId.isEmpty) {
      throw Exception(_signInMessage);
    }
    if (draft.latitude == null || draft.longitude == null) {
      throw Exception('Please pick a location on the map');
    }
    final normalized = ShopDraft.fromRegister(
      name: draft.name,
      ownerName: draft.ownerName ?? '',
      phone: draft.phoneNumber ?? '',
      categoryId: draft.categoryId ?? '',
      cityId: draft.cityId,
      latitude: draft.latitude!,
      longitude: draft.longitude!,
      description: draft.description ?? '',
      subcategory: draft.subcategory,
      whatsappNumber: draft.whatsappNumber,
      addressText: draft.addressText ?? '',
      discoveryRadius: draft.discoveryRadius ?? 5,
      imageUrl: draft.imageUrl,
      photos: draft.photos,
    );

    final shop = await _shops.insert(
      normalized,
      ownerId: userId,
    );

    // Java promotes customer → business_owner on POST /api/v1/businesses.
    // Local leftover writes the owner role so Profile can tell shops from
    // customers when live `users` is empty.
    ShowcaseCatalog.update(
      'users',
      UserRole.businessOwner.toUpdateJson(),
      ShowcaseQuery()..eq('id', userId),
    );
    promoteGuestRole(UserRole.businessOwner);
    return shop;
  }

  Future<void> updateProfile({
    required String userId,
    required String businessId,
    required ShopDraft draft,
  }) async {
    await requireOwnedBusiness(userId: userId, businessId: businessId);
    final normalized = ShopDraft.fromProfile(
      name: draft.name,
      ownerName: draft.ownerName,
      description: draft.description,
      phoneNumber: draft.phoneNumber,
      whatsappNumber: draft.whatsappNumber,
      addressText: draft.addressText,
      discoveryRadius: draft.discoveryRadius,
      imageUrl: draft.imageUrl,
      cityId: draft.cityId,
    );
    await _shops.update(
      businessId: businessId,
      ownerId: userId,
      draft: normalized,
    );
  }

  Future<void> deleteBusiness({
    required String userId,
    required String businessId,
  }) async {
    await requireOwnedBusiness(userId: userId, businessId: businessId);
    await _shops.delete(businessId, ownerId: userId);
    await authManager.refreshUser();
  }

  Future<void> contactSupportForVerification(Shop shop) async {
    final message = 'Hello DEGLOOR ONE Team,\n\n'
        'I would like to verify my business:\n'
        'Name: ${shop.name}\n'
        'ID: ${shop.id}\n'
        'Please let me know the next steps.';
    await WhatsAppService.launchWhatsApp(
      phoneNumber: '+919876543210',
      message: message,
    );
  }

  Future<List<CatalogProduct>> products(String userId) async {
    final shop = await requireOwned(userId);
    return _catalog.productsFor(shop.id);
  }

  Future<List<ProductCategory>> productCategories(String userId) async {
    final shop = await requireOwned(userId);
    return _catalog.productCategoriesFor(shop.id);
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
      final existing = await _catalog.productCategoriesFor(shop.id);
      for (final category in existing) {
        if (category.name.toLowerCase() == trimmedCategory.toLowerCase()) {
          categoryId = category.id;
          break;
        }
      }
      if (categoryId == null) {
        final created = await _catalog.insertProductCategory(
          ProductCategoryDraft(
            businessId: shop.id,
            name: trimmedCategory,
          ),
        );
        categoryId = created.id;
      }
    }

    return _catalog.insertProduct(
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
    final existing = await _catalog.productForBusiness(
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
    await _catalog.updateProduct(
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
    final existing = await _catalog.productForBusiness(
      businessId: shop.id,
      productId: productId,
    );
    if (existing == null) {
      throw Exception(_missingProductMessage);
    }
    await _catalog.updateStock(
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
    final existing = await _catalog.productForBusiness(
      businessId: shop.id,
      productId: productId,
    );
    if (existing == null) {
      throw Exception(_missingProductMessage);
    }
    await _catalog.deleteProduct(
      productId: productId,
      businessId: shop.id,
    );
  }

  Future<List<ShopHours>> hours(String userId) async {
    final shop = await requireOwned(userId);
    final hours = await _catalog.hoursFor(shop.id);
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
    await _catalog.upsertHours(hours, businessId: shop.id);
  }

  /// Guest mode and the FlutterFlow host have no writable `product-images`
  /// bucket. A live GoTrue probe turns [kUseShowcaseData] off so table reads
  /// can run, but storage still 400s and the UI shows "Unable to upload the
  /// image". Keep a local public URL in those cases.
  static bool get usesLocalPublicImage =>
      kUseShowcaseData || kBypassAuth || kUsesDeadFlutterFlowHost;

  static String localPublicImageUrl(String path) {
    return 'https://images.unsplash.com/photo-1542838132-92c53300491e'
        '?auto=format&fit=crop&w=400&q=80&path=$path';
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
        '$folder/$businessId/${DateTime.now().microsecondsSinceEpoch}.$extension';
    if (usesLocalPublicImage) {
      return localPublicImageUrl(path);
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
