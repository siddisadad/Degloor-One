/// Fields a customer submits when saving an address.
/// Id and createdAt stay off this type.
class AddressDraft {
  const AddressDraft({
    required this.userId,
    required this.title,
    required this.addressText,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  final String userId;
  final String title;
  final String addressText;
  final double latitude;
  final double longitude;
  final bool isDefault;

  /// Parse the add-address form. Title, details, and map coords stay
  /// off the widget.
  factory AddressDraft.fromForm({
    required String userId,
    required String title,
    required String addressText,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) {
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw Exception('Please pick a location on the map');
    }
    final trimmedTitle = title.trim();
    final trimmedAddress = addressText.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception('Please enter a title');
    }
    if (trimmedAddress.isEmpty) {
      throw Exception('Please enter address details');
    }
    return AddressDraft(
      userId: userId,
      title: trimmedTitle,
      addressText: trimmedAddress,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
  }

  /// Table insert only. Never includes id or created_at.
  /// [isDefault] overrides the form flag when the first saved row
  /// must become the default.
  Map<String, dynamic> toInsertJson({bool? isDefault}) {
    return {
      'user_id': userId,
      'title': title,
      'address_text': addressText,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault ?? this.isDefault,
    };
  }
}
