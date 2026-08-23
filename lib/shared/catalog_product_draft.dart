/// Fields an owner submits when adding or editing a catalogue product.
/// Id, createdAt, and checkout price authority stay off this type.
class CatalogProductDraft {
  const CatalogProductDraft({
    required this.name,
    required this.price,
    this.categoryName = '',
    this.imageUrl,
    this.stockQuantity = 0,
    this.trackInventory = false,
  });

  final String name;
  final double price;
  final String categoryName;
  final String? imageUrl;
  final int stockQuantity;
  final bool trackInventory;

  /// Parse owner form text. Price and stock stay off the widget.
  factory CatalogProductDraft.fromForm({
    required String name,
    required String priceText,
    String categoryName = '',
    String? imageUrl,
    String stockText = '',
    bool trackInventory = false,
  }) {
    final price = double.tryParse(priceText.trim());
    if (price == null) {
      throw Exception('Please enter a valid price');
    }
    final trimmedStock = stockText.trim();
    final stock = trimmedStock.isEmpty ? 0 : int.tryParse(trimmedStock);
    if (stock == null) {
      throw Exception('Please enter a valid stock quantity');
    }
    return CatalogProductDraft(
      name: name,
      price: price,
      categoryName: categoryName,
      imageUrl: imageUrl,
      stockQuantity: stock,
      trackInventory: trackInventory,
    );
  }

  /// Table insert only. Never includes id or created_at.
  /// [businessId] is the owned shop; category id is resolved by the service.
  Map<String, dynamic> toInsertJson({
    required String businessId,
    String? categoryId,
  }) {
    return {
      'business_id': businessId,
      'category_id': categoryId,
      'name': name.trim(),
      'price': price,
      'image_url': imageUrl,
      'is_available': true,
      'stock_quantity': stockQuantity < 0 ? 0 : stockQuantity,
      'track_inventory': trackInventory,
    };
  }

  /// Owner edit fields only. Never includes id, business_id, or created_at.
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name.trim(),
      'price': price,
      'stock_quantity': stockQuantity < 0 ? 0 : stockQuantity,
      'track_inventory': trackInventory,
      'image_url': imageUrl,
    };
  }
}
