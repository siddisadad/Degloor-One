/// Fields an owner submits when creating a catalogue category.
/// Id and createdAt stay off this type.
class ProductCategoryDraft {
  const ProductCategoryDraft({
    required this.businessId,
    required this.name,
  });

  final String businessId;
  final String name;

  /// Table insert only. Never includes id or created_at.
  Map<String, dynamic> toInsertJson() {
    return {
      'business_id': businessId,
      'name': name,
    };
  }
}
