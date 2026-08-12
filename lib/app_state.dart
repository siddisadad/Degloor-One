import 'package:flutter/material.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A singleton class that manages the application's global state using [ChangeNotifier].
///
/// It handles persistent state using [SharedPreferences], including user location,
/// discovery radius, and locale settings.
class FFAppState extends ChangeNotifier {
  static FFAppState? _instance;

  /// Returns the singleton instance of [FFAppState].
  static FFAppState get instance => _instance ??= FFAppState._internal();

  FFAppState._internal();

  /// Resets the application state to its initial internal state.
  static void reset() {
    _instance = FFAppState._internal();
  }

  /// Initializes persisted state from [SharedPreferences].
  ///
  /// This should be called during the application startup flow.
  Future initializePersistedState() async {
    _prefs = await SharedPreferences.getInstance();
    _discoveryRadius = _prefs.getDouble('ff_discoveryRadius') ?? 10.0;
    if (_prefs.containsKey('ff_userLocation')) {
      _userLocation = latLngFromString(_prefs.getString('ff_userLocation')!);
    }
    _locale = _prefs.getString('ff_locale') ?? 'en';
  }

  late SharedPreferences _prefs;

  /// Executes a [callback] and notifies listeners of changes.
  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  /// The current user location. Defaults to null to require user input/permission.
  LatLng? _userLocation;
  LatLng? get userLocation => _userLocation;
  set userLocation(LatLng? value) {
    _userLocation = value;
    if (value != null) {
      _prefs.setString('ff_userLocation', value.serialize());
    } else {
      _prefs.remove('ff_userLocation');
    }
    notifyListeners();
  }

  /// The radius in kilometers for local discovery.
  double _discoveryRadius = 10.0;
  double get discoveryRadius => _discoveryRadius;
  set discoveryRadius(double value) {
    _discoveryRadius = value;
    _prefs.setDouble('ff_discoveryRadius', value);
    notifyListeners();
  }

  /// The current application locale (e.g., 'en', 'mr', 'hi').
  String _locale = 'en';
  String get locale => _locale;
  set locale(String value) {
    _locale = value;
    _prefs.setString('ff_locale', value);
    notifyListeners();
  }
}
