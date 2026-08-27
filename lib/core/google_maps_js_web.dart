import 'dart:js_interop';

@JS('__degloorGoogleMapsReady')
external bool? _googleMapsReady();

@JS('google.maps.MapTypeId')
external JSAny? get _mapTypeId;

/// True when `google.maps.MapTypeId` exists so [GoogleMap] can mount on web.
bool isGoogleMapsJsReady() {
  try {
    if (_googleMapsReady() == true) return true;
  } catch (_) {}
  try {
    return _mapTypeId != null;
  } catch (_) {
    return false;
  }
}
