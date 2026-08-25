import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/repositories/shop_repository.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_draft.dart';
import 'package:degloor_one/shared/shop_hours.dart';
import 'package:meta/meta.dart';

/// Shop access through the Java API. Table rows stay on the server.
class JavaShopRepository implements ShopRepository {
  JavaShopRepository({JavaApiClient? client})
      : _client = client ?? JavaApiClient.instance;

  final JavaApiClient _client;

  static Shop fromJson(Map<String, dynamic> json) => Shop.fromJson(json);

  static List<ShopHours> hoursFromJson(Map<String, dynamic> json) {
    return Shop.fromJson(json).hours;
  }

  static List<Map<String, dynamic>> pageItems(dynamic data) {
    final raw = data is List
        ? data
        : data is Map
            ? data['items'] ?? data['content']
            : const [];
    final rows = raw is List ? raw : const [];
    return [
      for (final row in rows.whereType<Map>()) Map<String, dynamic>.from(row),
    ];
  }

  Map<String, dynamic> _body(ShopDraft draft) => requestBody(draft);

  /// Java create/update payload. Photos stay on the request, not the widget.
  @visibleForTesting
  static Map<String, dynamic> requestBody(ShopDraft draft) {
    final photoUrls = draft.attachedPhotos;
    final cover = (draft.imageUrl ?? '').trim().isNotEmpty
        ? draft.imageUrl!.trim()
        : (photoUrls.isEmpty ? null : photoUrls.first);
    return {
      'name': draft.name,
      if (draft.ownerName != null) 'ownerName': draft.ownerName,
      if (draft.description != null) 'description': draft.description,
      if (draft.categoryId != null) 'categoryId': draft.categoryId,
      if (draft.addressText != null) 'addressText': draft.addressText,
      if (draft.whatsappNumber != null) 'whatsappNumber': draft.whatsappNumber,
      if (draft.phoneNumber != null) 'phoneNumber': draft.phoneNumber,
      if (draft.latitude != null) 'latitude': draft.latitude,
      if (draft.longitude != null) 'longitude': draft.longitude,
      if (draft.discoveryRadius != null) 'discoveryRadius': draft.discoveryRadius,
      if (cover != null) 'imageUrl': cover,
      if (photoUrls.isNotEmpty) 'photos': photoUrls,
    };
  }

  Future<Shop?> _byIdOrNull(String businessId) async {
    try {
      final data = await _client.get('/api/v1/businesses/$businessId');
      return fromJson(Map<String, dynamic>.from(data as Map));
    } on JavaApiException catch (error) {
      if (error.code == 'BUSINESS_NOT_FOUND' || error.code.contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<Shop?> byId(String businessId) async {
    if (businessId.isEmpty) return null;
    return _byIdOrNull(businessId);
  }

  @override
  Future<List<Shop>> ownedBy(String userId) async {
    if (userId.isEmpty) return const [];
    final data = await _client.get('/api/v1/businesses/mine');
    final rows = data is List ? data : const [];
    return rows
        .whereType<Map>()
        .map((row) => fromJson(Map<String, dynamic>.from(row)))
        .where((shop) => shop.ownerId == userId)
        .toList();
  }

  @override
  Future<Shop> insert(
    ShopDraft draft, {
    required String ownerId,
  }) async {
    final data = await _client.post('/api/v1/businesses', _body(draft));
    final shop = fromJson(Map<String, dynamic>.from(data as Map));
    if (shop.ownerId != null && shop.ownerId != ownerId) {
      throw Exception('Unable to create your shop. Please try again.');
    }
    return shop;
  }

  @override
  Future<void> update({
    required String businessId,
    required String ownerId,
    required ShopDraft draft,
  }) async {
    await _client.put('/api/v1/businesses/$businessId', _body(draft));
  }

  @override
  Future<void> delete(String businessId, {required String ownerId}) async {
    await _client.delete('/api/v1/businesses/$businessId');
  }
}
