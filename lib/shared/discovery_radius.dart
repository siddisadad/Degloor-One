/// Allowed customer discovery distances after dropping 2 km and 25 km.
const kDiscoveryRadiiKm = <double>[5, 10, 15];
const kMinDiscoveryRadiusKm = 5.0;
const kMaxDiscoveryRadiusKm = 15.0;
const kDefaultDiscoveryRadiusKm = 10.0;

/// Snap a stored or slider value onto 5, 10, or 15 km.
double snapDiscoveryRadius(double value) {
  var nearest = kDiscoveryRadiiKm.first;
  var best = (value - nearest).abs();
  for (final option in kDiscoveryRadiiKm.skip(1)) {
    final delta = (value - option).abs();
    if (delta < best) {
      nearest = option;
      best = delta;
    }
  }
  return nearest;
}

double radiusFromSliderPercent(double percent) {
  return snapDiscoveryRadius(
    kMinDiscoveryRadiusKm +
        (percent.clamp(0, 100) / 100.0) *
            (kMaxDiscoveryRadiusKm - kMinDiscoveryRadiusKm),
  );
}

double sliderPercentFromRadius(double radiusKm) {
  final snapped = snapDiscoveryRadius(radiusKm);
  return ((snapped - kMinDiscoveryRadiusKm) *
          100.0 /
          (kMaxDiscoveryRadiusKm - kMinDiscoveryRadiusKm))
      .clamp(0.0, 100.0);
}

/// Next allowed radius, or null when already at 15 km.
double? nextDiscoveryRadius(double currentKm) {
  final snapped = snapDiscoveryRadius(currentKm);
  final index = kDiscoveryRadiiKm.indexOf(snapped);
  if (index < 0 || index >= kDiscoveryRadiiKm.length - 1) return null;
  return kDiscoveryRadiiKm[index + 1];
}
