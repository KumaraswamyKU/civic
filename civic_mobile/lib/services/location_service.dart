import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/api_exception.dart';

class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;
}

class LocationService {
  Future<DeviceLocation> current() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw ApiException('Location services are turned off.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw ApiException('Location permission is required to submit a complaint.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw ApiException(
        'Location permission is permanently denied. Enable it in system settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: await _reverseGeocode(position.latitude, position.longitude),
    );
  }

  Future<String?> _reverseGeocode(double latitude, double longitude) async {
    if (kIsWeb) {
      return null;
    }
    try {
      final marks = await placemarkFromCoordinates(latitude, longitude);
      if (marks.isEmpty) {
        return null;
      }
      final mark = marks.first;
      final parts = [
        mark.street,
        mark.subLocality,
        mark.locality,
        mark.administrativeArea,
        mark.postalCode,
      ].where((part) => part != null && part.trim().isNotEmpty).map((part) => part!.trim());
      final joined = parts.join(', ');
      return joined.isEmpty ? null : joined;
    } catch (_) {
      return null;
    }
  }
}
