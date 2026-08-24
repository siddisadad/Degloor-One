/// Saved customer address. Screens use this instead of table rows.
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.userId,
    this.title,
    this.addressText,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String? title;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime? createdAt;
}
