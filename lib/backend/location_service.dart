import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/backend/delivery_service.dart';
import 'package:degloor_one/components/location_explanation_dialog.dart';
import 'package:degloor_one/flutter_flow/lat_lng.dart';
import 'package:degloor_one/core/error_handler.dart';

class LocationService {
  static Future<void> updateCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (!context.mounted) return;
      // Show explanation dialog before requesting
      final proceed = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => const LocationExplanationDialog(),
      );

      if (proceed != true) return;

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: kIsWeb ? 4 : 10),
          ),
        );
      } on TimeoutException catch (e) {
        AppLogger.log(
          'Location timed out; using last known if available',
          error: e,
        );
        position = null;
      } catch (e) {
        AppLogger.log('Geolocator.getCurrentPosition failed', error: e);
        position = null;
      }

      position ??= await Geolocator.getLastKnownPosition();

      if (position != null) {
        final pos = position;
        FFAppState.instance.update(() {
          FFAppState.instance.userLocation = LatLng(pos.latitude, pos.longitude);
        });
      } else {
        AppLogger.log('Could not determine location (position is null)');
      }
    } catch (e) {
      AppLogger.error('LocationService internal error', e);
    }
  }

  static Future<void> syncPartnerLocation(String partnerId) async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      await DeliveryService.updatePartnerLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      // Internal error handling logic could go here
    }
  }
}
