/// One-field default-address write.
/// Id, user id, and createdAt stay off this type.
class AddressDefaultFlag {
  const AddressDefaultFlag(this.isDefault);

  final bool isDefault;

  /// Table update only. Never includes id, user_id, or created_at.
  Map<String, dynamic> toUpdateJson() {
    return {'is_default': isDefault};
  }
}
