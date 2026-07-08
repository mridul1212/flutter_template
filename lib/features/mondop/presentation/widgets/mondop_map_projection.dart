import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_template/features/mondop/data/models/mondop_models.dart';

/// Lat/lng → screen projection for the offline Bangladesh map.
class MondopMapProjection {
  MondopMapProjection({
    required this.mondops,
    required this.userPosition,
    required this.size,
  }) {
    var minLat = kBangladeshMapCenter.latitude;
    var maxLat = kBangladeshMapCenter.latitude;
    var minLng = kBangladeshMapCenter.longitude;
    var maxLng = kBangladeshMapCenter.longitude;

    void absorb(MapPosition p) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    for (final m in mondops) {
      absorb(m.mondop.position);
    }
    if (userPosition != null) absorb(userPosition!);

    const pad = 0.35;
    _minLat = minLat - pad;
    _maxLat = maxLat + pad;
    _minLng = minLng - pad;
    _maxLng = maxLng + pad;
  }

  final List<MondopWithDistance> mondops;
  final MapPosition? userPosition;
  final Size size;

  late final double _minLat;
  late final double _maxLat;
  late final double _minLng;
  late final double _maxLng;

  Offset project(double lat, double lng) {
    final x = (lng - _minLng) / (_maxLng - _minLng);
    final y = (_maxLat - lat) / (_maxLat - _minLat);
    return Offset(16 + x * (size.width - 32), 40 + y * (size.height - 56));
  }

  MondopItem? hitTest(Offset local, {double radius = 22}) {
    for (final item in mondops) {
      final m = item.mondop;
      final c = project(m.lat, m.lng);
      if ((local - c).distance <= radius) return m;
    }
    return null;
  }
}
