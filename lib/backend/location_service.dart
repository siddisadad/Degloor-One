import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/location_explanation_dialog.dart';
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
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15), // Increased from 10
          ),
        );
      } catch (e) {
        AppLogger.error('Geolocator.getCurrentPosition failed', e);
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

      await DeliveryPartnersTable().update(
        data: {
          'current_latitude': position.latitude,
          'current_longitude': position.longitude,
        },
        matchingRows: (src) => src.eq('id', partnerId),
      );
    } catch (e) {
      // Internal error handling logic could go here
    }
  }
}
