import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/data/repositories/shop_repository.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_draft.dart';

/// Shop access through the Java API. Table rows stay on the server.
/// Nested hours on [BusinessResponse] stay unread until the hours slice.
class JavaShopRepository implements ShopRepository {
  JavaShopRepository({JavaApiClient? client})
      : _client = client ?? JavaApiClient.instance;

  final JavaApiClient _client;

  static Shop fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return Shop(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      cityId: json['cityId'] as String?,
      addressText: json['addressText'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      isOpen: json['open'] as bool? ?? json['isOpen'] as bool?,
      isVerified: json['verified'] as bool? ?? json['isVerified'] as bool?,
      imageUrl: json['imageUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> _body(ShopDraft draft) {
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
      if (draft.imageUrl != null) 'imageUrl': draft.imageUrl,
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
}
