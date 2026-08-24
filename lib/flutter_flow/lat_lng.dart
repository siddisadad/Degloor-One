import 'dart:math';

class LatLng {
  const LatLng(this.latitude, this.longitude);
  final double latitude;
  final double longitude;

  /// Great-circle distance in kilometers. Live search RPCs do not return
  /// `distance_km`, so listing cards compute it from the query origin.
  static double distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earth = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * earth * asin(min(1, sqrt(a)));
  }

  static double _rad(double deg) => deg * pi / 180;

  @override
  String toString() => 'LatLng(lat: $latitude, lng: $longitude)';

  String serialize() => '$latitude,$longitude';

  @override
  int get hashCode => latitude.hashCode + longitude.hashCode;

  @override
  bool operator ==(other) =>
      other is LatLng &&
      latitude == other.latitude &&
      longitude == other.longitude;
}
