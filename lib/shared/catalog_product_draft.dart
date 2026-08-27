import 'package:degloor_one/shared/catalog_product_stock.dart';

/// Fields an owner submits when adding or editing a catalogue product.
/// Id, createdAt, and checkout price authority stay off this type.
class CatalogProductDraft {
  const CatalogProductDraft({
    required this.name,
    required this.price,
    this.categoryName = '',
    this.imageUrl,
    this.stock = const CatalogProductStock(0),
    this.trackInventory = false,
  });

  final String name;
  final double price;
  final String categoryName;
  final String? imageUrl;
  final CatalogProductStock stock;
  final bool trackInventory;

  int get stockQuantity => stock.quantity;

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
    return CatalogProductDraft(
      name: name,
      price: price,
      categoryName: categoryName,
      imageUrl: imageUrl,
      stock: CatalogProductStock.parse(stockText),
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
      ...stock.toUpdateJson(),
      'track_inventory': trackInventory,
    };
  }

  /// Owner edit fields only. Never includes id, business_id, or created_at.
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name.trim(),
      'price': price,
      ...stock.toUpdateJson(),
      'track_inventory': trackInventory,
      'image_url': imageUrl,
    };
  }
}
