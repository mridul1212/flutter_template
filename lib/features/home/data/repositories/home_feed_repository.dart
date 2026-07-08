import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_template/features/home/data/models/feed_models.dart';

abstract class HomeFeedRepository {
  Future<List<FeedSection>> fetchExplore();
  Future<List<FeedItem>> fetchActivity();
  Future<List<FeedItem>> fetchSaved();
}

final class HomeFeedRepositoryMock implements HomeFeedRepository {
  List<FeedSection>? _exploreCache;
  Future<List<FeedSection>>? _exploreInFlight;

  List<FeedItem>? _activityCache;
  Future<List<FeedItem>>? _activityInFlight;

  List<FeedItem>? _savedCache;
  Future<List<FeedItem>>? _savedInFlight;

  @override
  Future<List<FeedSection>> fetchExplore() {
    final cached = _exploreCache;
    if (cached != null) return Future.value(cached);

    final existing = _exploreInFlight;
    if (existing != null) return existing;

    final fut = _loadExplore().whenComplete(() => _exploreInFlight = null);
    _exploreInFlight = fut;
    return fut;
  }

  @override
  Future<List<FeedItem>> fetchActivity() {
    final cached = _activityCache;
    if (cached != null) return Future.value(cached);

    final existing = _activityInFlight;
    if (existing != null) return existing;

    final fut = _loadActivity().whenComplete(() => _activityInFlight = null);
    _activityInFlight = fut;
    return fut;
  }

  @override
  Future<List<FeedItem>> fetchSaved() {
    final cached = _savedCache;
    if (cached != null) return Future.value(cached);

    final existing = _savedInFlight;
    if (existing != null) return existing;

    final fut = _loadSaved().whenComplete(() => _savedInFlight = null);
    _savedInFlight = fut;
    return fut;
  }

  Future<List<FeedSection>> _loadExplore() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final raw = await rootBundle.loadString('assets/mock/explore.json');
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) throw StateError('Invalid explore JSON');
    final sections = json['sections'];
    if (sections is! List) throw StateError('Invalid explore sections');
    final list = sections.map((e) => FeedSection.fromJson(e as Map<String, dynamic>)).toList(growable: false);
    _exploreCache = list;
    return list;
  }

  Future<List<FeedItem>> _loadActivity() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final raw = await rootBundle.loadString('assets/mock/activity.json');
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) throw StateError('Invalid activity JSON');
    final items = json['items'];
    if (items is! List) throw StateError('Invalid activity items');
    final list = items.map((e) => FeedItem.fromJson(e as Map<String, dynamic>)).toList(growable: false);
    _activityCache = list;
    return list;
  }

  Future<List<FeedItem>> _loadSaved() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final raw = await rootBundle.loadString('assets/mock/saved.json');
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) throw StateError('Invalid saved JSON');
    final items = json['items'];
    if (items is! List) throw StateError('Invalid saved items');
    final list = items.map((e) => FeedItem.fromJson(e as Map<String, dynamic>)).toList(growable: false);
    _savedCache = list;
    return list;
  }
}
