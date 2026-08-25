/// Fields an owner submits when registering or editing a shop.
/// Id, createdAt, rating, and verification stay off this type
/// except the stored unverified insert default.
class ShopDraft {
  const ShopDraft({
    required this.name,
    this.ownerName,
    this.description,
    this.phoneNumber,
    this.whatsappNumber,
    this.addressText,
    this.categoryId,
    this.latitude,
    this.longitude,
    this.discoveryRadius,
    this.imageUrl,
    this.photos,
  });

  final String name;
  final String? ownerName;
  final String? description;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? addressText;
  final String? categoryId;
  final double? latitude;
  final double? longitude;
  final double? discoveryRadius;
  final String? imageUrl;
  final List<String>? photos;

  /// Parse the registration form. Required fields and map coords stay
  /// off the widget.
  factory ShopDraft.fromRegister({
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
    String? imageUrl,
    List<String>? photos,
  }) {
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
    final trimmedImage = imageUrl?.trim();
    final trimmedPhotos = [
      for (final url in photos ?? const <String>[])
        if (url.trim().isNotEmpty) url.trim(),
    ];
    return ShopDraft(
      name: trimmedName,
      ownerName: trimmedOwner,
      description: description.trim(),
      phoneNumber: trimmedPhone,
      whatsappNumber: (whatsappNumber ?? trimmedPhone).trim(),
      addressText: addressText.trim(),
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      discoveryRadius: discoveryRadius,
      imageUrl: (trimmedImage == null || trimmedImage.isEmpty)
          ? null
          : trimmedImage,
      photos: trimmedPhotos.isEmpty ? null : trimmedPhotos,
    );
  }

  /// Parse the profile form. Name stays off the widget.
  factory ShopDraft.fromProfile({
    required String name,
    String? ownerName,
    String? description,
    String? phoneNumber,
    String? whatsappNumber,
    String? addressText,
    double? discoveryRadius,
    String? imageUrl,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Business name is required');
    }
    return ShopDraft(
      name: trimmedName,
      ownerName: ownerName?.trim(),
      description: description?.trim(),
      phoneNumber: phoneNumber?.trim(),
      whatsappNumber: whatsappNumber?.trim(),
      addressText: addressText?.trim(),
      discoveryRadius: discoveryRadius,
      imageUrl: imageUrl,
    );
  }

  /// Storefront first, then any extra interior / document URLs.
  List<String> get attachedPhotos {
    final urls = <String>[];
    void add(String? url) {
      final trimmed = (url ?? '').trim();
      if (trimmed.isEmpty || urls.contains(trimmed)) return;
      urls.add(trimmed);
    }

    add(imageUrl);
    for (final url in photos ?? const <String>[]) {
      add(url);
    }
    return urls;
  }

  /// Table insert only. Never includes id or created_at.
  /// [ownerId] is the signed-in owner. New shops stay unverified,
  /// the same stored default as before.
  Map<String, dynamic> toInsertJson({required String ownerId}) {
    final photoUrls = attachedPhotos;
    final cover = (imageUrl ?? '').trim().isNotEmpty
        ? imageUrl!.trim()
        : (photoUrls.isEmpty ? null : photoUrls.first);
    return {
      'owner_id': ownerId,
      'name': name,
      'owner_name': ownerName,
      'description': description ?? '',
      'phone_number': phoneNumber,
      'whatsapp_number': whatsappNumber,
      'address_text': addressText ?? '',
      'category_id': categoryId,
      'latitude': latitude,
      'longitude': longitude,
      'discovery_radius': discoveryRadius ?? 5,
      'is_verified': false,
      'source': 'owner',
      if (cover != null) 'image_url': cover,
    };
  }

  /// Owner profile fields only. Never includes id, owner_id,
  /// category_id, coordinates, created_at, or is_verified.
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'owner_name': ownerName,
      'description': description,
      'phone_number': phoneNumber,
      'whatsapp_number': whatsappNumber,
      'address_text': addressText,
      if (discoveryRadius != null) 'discovery_radius': discoveryRadius,
      'image_url': imageUrl,
    };
  }
}
