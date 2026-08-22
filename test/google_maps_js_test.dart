import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/core/google_maps_js.dart';

void main() {
  test('VM builds treat native maps as ready', () {
    expect(isGoogleMapsJsReady(), isTrue);
  });
}
