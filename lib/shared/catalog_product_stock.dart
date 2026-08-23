/// One-field owner stock write.
/// Id, business id, and createdAt stay off this type.
class CatalogProductStock {
  const CatalogProductStock(this.quantity);

  final int quantity;

  /// Parse owner form text. Quantity stays off the widget.
  factory CatalogProductStock.parse(String text) {
    final quantity = int.tryParse(text.trim());
    if (quantity == null) {
      throw Exception('Please enter a valid stock quantity');
    }
    return CatalogProductStock(quantity);
  }

  /// Table update only. Never includes id, business_id, or created_at.
  Map<String, dynamic> toUpdateJson() {
    if (quantity < 0) {
      throw Exception('Please enter a valid stock quantity');
    }
    return {'stock_quantity': quantity};
  }
}
