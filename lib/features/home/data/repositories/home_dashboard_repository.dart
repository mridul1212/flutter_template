import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_template/features/home/data/models/home_dashboard_models.dart';

abstract class HomeDashboardRepository {
  Future<HomeDashboardData> fetchDashboard();
}

final class HomeDashboardRepositoryMock implements HomeDashboardRepository {
  HomeDashboardRepositoryMock();

  HomeDashboardData? _cache;
  Future<HomeDashboardData>? _inFlight;

  @override
  Future<HomeDashboardData> fetchDashboard() {
    final cached = _cache;
    if (cached != null) return Future.value(cached);
    final existing = _inFlight;
    if (existing != null) return existing;

    final fut = _load().whenComplete(() => _inFlight = null);
    _inFlight = fut;
    return fut;
  }

  Future<HomeDashboardData> _load() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final raw = await rootBundle.loadString('assets/mock/home_dashboard.json');
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) throw StateError('Invalid home dashboard JSON');
    final data = HomeDashboardData.fromJson(json);
    _cache = data;
    return data;
  }
}

