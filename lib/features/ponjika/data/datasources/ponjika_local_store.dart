import 'dart:convert';
import 'dart:io';

import 'package:flutter_template/core/cache/year_cache_policy.dart';
import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Disk + metadata cache for Ponjika bundle (serves Ponjika, Logno, Ekadashi screens).
final class PonjikaLocalStore {
  PonjikaLocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const _cacheDirName = 'ponjika_cache';

  Future<Directory> _cacheDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_cacheDirName');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _fileName(int year) => 'ponjika_$year.json';

  Map<int, DateTime> _readMeta() {
    final raw = _prefs.getString(AppConstants.ponjikaCacheMetaKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      final map = <int, DateTime>{};
      for (final entry in decoded.entries) {
        final year = int.tryParse(entry.key);
        final value = entry.value;
        if (year == null || value is! String) continue;
        final dt = DateTime.tryParse(value);
        if (dt != null) map[year] = dt;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeMeta(Map<int, DateTime> meta) async {
    final encoded = <String, String>{};
    for (final e in meta.entries) {
      encoded['${e.key}'] = e.value.toUtc().toIso8601String();
    }
    await _prefs.setString(AppConstants.ponjikaCacheMetaKey, jsonEncode(encoded));
  }

  /// Returns cached data if present. [allowStale] serves expired cache when offline fallback is needed.
  Future<PonjikaData?> read(int year, {bool allowStale = false}) async {
    final meta = _readMeta();
    final savedAt = meta[year];
    if (savedAt == null) return null;
    if (!allowStale && !YearCachePolicy.isFresh(year, savedAt)) return null;

    final dir = await _cacheDir();
    final file = File('${dir.path}/${_fileName(year)}');
    if (!file.existsSync()) return null;

    try {
      final raw = await file.readAsString();
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      return PonjikaData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(int year, Map<String, dynamic> json) async {
    final dir = await _cacheDir();
    final file = File('${dir.path}/${_fileName(year)}');
    await file.writeAsString(jsonEncode(json));

    final meta = _readMeta();
    meta[year] = DateTime.now();
    await _writeMeta(meta);
    await _prune(meta);
  }

  Future<void> _prune(Map<int, DateTime> meta) async {
    if (meta.length <= AppConstants.ponjikaMaxCachedYears) return;

    final sorted = meta.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final keep = sorted.take(AppConstants.ponjikaMaxCachedYears).map((e) => e.key).toSet();
    final dir = await _cacheDir();

    for (final year in meta.keys.toList(growable: false)) {
      if (keep.contains(year)) continue;
      meta.remove(year);
      final file = File('${dir.path}/${_fileName(year)}');
      if (file.existsSync()) {
        await file.delete();
      }
    }
    await _writeMeta(meta);
  }

  Future<void> clearAll() async {
    await _prefs.remove(AppConstants.ponjikaCacheMetaKey);
    final dir = await _cacheDir();
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }
}
