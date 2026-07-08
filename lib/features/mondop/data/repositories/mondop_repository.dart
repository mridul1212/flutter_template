import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_template/features/mondop/data/models/mondop_models.dart';

abstract class MondopRepository {
  Future<List<MondopItem>> fetchMondops({bool force = false});
  Future<MondopItem?> findById(String id);
  Future<MondopReviewSummary> fetchReviews(String mondopId);
  Future<MondopReview> submitReview({required String mondopId, required int rating, required String comment});
  List<String> areasFrom(List<MondopItem> items);
}

final class MondopRepositoryImpl implements MondopRepository {
  List<MondopItem>? _cache;
  Future<List<MondopItem>>? _inFlight;
  Map<String, dynamic>? _reviewsCache;

  @override
  Future<List<MondopItem>> fetchMondops({bool force = false}) {
    if (force) _cache = null;
    final cached = _cache;
    if (cached != null) return Future.value(cached);

    final existing = _inFlight;
    if (existing != null) return existing;

    final fut = _load().whenComplete(() => _inFlight = null);
    _inFlight = fut;
    return fut;
  }

  @override
  Future<MondopItem?> findById(String id) async {
    final items = await fetchMondops();
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  List<String> areasFrom(List<MondopItem> items) {
    final areas = items.map((m) => m.area).toSet().toList(growable: false)..sort();
    return areas;
  }

  Future<Map<String, dynamic>> _reviewsRaw() async {
    if (_reviewsCache != null) return _reviewsCache!;
    final raw = await rootBundle.loadString('assets/mock/mondop_reviews.json');
    _reviewsCache = jsonDecode(raw) as Map<String, dynamic>;
    return _reviewsCache!;
  }

  @override
  Future<MondopReviewSummary> fetchReviews(String mondopId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final all = (await _reviewsRaw())['reviews'] as Map<String, dynamic>? ?? {};
    final entry = all[mondopId] as Map<String, dynamic>?;
    if (entry == null) {
      return MondopReviewSummary(averageRating: 0, reviewCount: 0, items: const []);
    }
    return MondopReviewSummary.fromJson(entry);
  }

  @override
  Future<MondopReview> submitReview({
    required String mondopId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) throw Exception('Rating must be 1–5');
    if (comment.trim().length < 10) throw Exception('Comment too short');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return MondopReview(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      user: 'You',
      rating: rating,
      comment: comment.trim(),
      date: DateTime.now().toIso8601String().split('T').first,
    );
  }

  Future<List<MondopItem>> _load() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final raw = await rootBundle.loadString('assets/mock/mondops.json');
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) throw StateError('Invalid mondops JSON');
    final items = json['items'] as List;
    final list = <MondopItem>[];
    final reviews = await _reviewsRaw();
    final revMap = reviews['reviews'] as Map<String, dynamic>? ?? {};
    for (var i = 0; i < items.length; i++) {
      final itemJson = Map<String, dynamic>.from(items[i] as Map<String, dynamic>);
      final id = itemJson['id'] as String;
      final rev = revMap[id] as Map<String, dynamic>?;
      if (rev != null) {
        itemJson['rating'] = rev['averageRating'];
        itemJson['reviewCount'] = rev['reviewCount'];
      }
      list.add(MondopItem.fromJson(itemJson, i + 1));
    }
    _cache = list;
    return list;
  }
}
