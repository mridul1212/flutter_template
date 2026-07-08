import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Location permission + position helper (respects Settings → Location Sharing).
final class LocationPermissionService {
  LocationPermissionService(this._prefs);

  final SharedPreferences _prefs;

  bool get isSharingEnabled =>
      _prefs.getBool(AppConstants.settingsLocationSharingKey) ?? false;

  Future<bool> ensurePermission({bool requestIfNeeded = true}) async {
    if (!isSharingEnabled) return false;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestIfNeeded) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final ok = await ensurePermission();
    if (!ok) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }

  static double distanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final meters = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
    return meters / 1000.0;
  }
}
