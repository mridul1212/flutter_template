import 'dart:convert';

import 'package:flutter/services.dart';

class FeatureContentData {
  FeatureContentData({
    required this.title,
    required this.subtitle,
    required this.year,
    required this.items,
  });

  final String title;
  final String subtitle;
  final int year;
  final List<FeatureContentItem> items;

  factory FeatureContentData.fromJson(Map<String, dynamic> json) {
    return FeatureContentData(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      items: (json['items'] as List<dynamic>)
          .map((e) => FeatureContentItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class FeatureContentItem {
  FeatureContentItem({
    required this.title,
    required this.subtitle,
    required this.detail,
    this.tag,
  });

  final String title;
  final String subtitle;
  final String detail;
  final String? tag;

  factory FeatureContentItem.fromJson(Map<String, dynamic> json) {
    return FeatureContentItem(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      detail: json['detail'] as String,
      tag: json['tag'] as String?,
    );
  }
}

abstract class FeatureContentRepository {
  Future<FeatureContentData> fetch(String featureId);
}

final class FeatureContentRepositoryImpl implements FeatureContentRepository {
  final Map<String, FeatureContentData> _cache = {};
  final Map<String, Future<FeatureContentData>> _inFlight = {};

  static const _assetIds = {
    'shopping': 'shopping',
    'soronjam': 'soronjam',
    'budget': 'budget',
    'itihash': 'itihash',
    'community': 'community',
    'gallery': 'gallery',
    'shareme': 'shareme',
  };

  @override
  Future<FeatureContentData> fetch(String featureId) {
    final assetId = _assetIds[featureId];
    if (assetId == null) throw StateError('Unknown feature: $featureId');

    final cached = _cache[featureId];
    if (cached != null) return Future.value(cached);

    final existing = _inFlight[featureId];
    if (existing != null) return existing;

    final fut = _load(featureId, assetId).whenComplete(() => _inFlight.remove(featureId));
    _inFlight[featureId] = fut;
    return fut;
  }

  Future<FeatureContentData> _load(String featureId, String assetId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final raw = await rootBundle.loadString('assets/mock/features/$assetId.json');
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) throw StateError('Invalid feature JSON');
    final data = FeatureContentData.fromJson(json);
    _cache[featureId] = data;
    return data;
  }
}
