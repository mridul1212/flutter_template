import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

/// Network / bundled source for year-wise Ponjika JSON.
final class PonjikaRemoteDataSource {
  PonjikaRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  static const _baseYear = 2026;

  /// Re-applies year-specific fields (dates, Bengali year, titles) to cached JSON.
  Map<String, dynamic> adaptJsonForYear(Map<String, dynamic> json, int year) => _normalizeYear(json, year);

  Future<Map<String, dynamic>> fetchYearJson(int year) async {
    final apiTemplate = const String.fromEnvironment('PONJIKA_API_URL', defaultValue: '');
    if (apiTemplate.isNotEmpty) {
      final url = apiTemplate.replaceAll('{year}', '$year');
      final res = await _dio.get<dynamic>(url);
      final data = res.data;
      if (data is Map<String, dynamic>) return _normalizeYear(data, year);
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return _normalizeYear(decoded, year);
      }
      throw StateError('Invalid Ponjika API response for $year');
    }

    final legacyUrl = const String.fromEnvironment('PONJIKA_REMOTE_JSON', defaultValue: '');
    if (legacyUrl.isNotEmpty) {
      final uri = Uri.parse(legacyUrl).replace(
        queryParameters: {...Uri.parse(legacyUrl).queryParameters, 'year': '$year'},
      );
      final res = await _dio.get<dynamic>(uri.toString());
      final data = res.data;
      if (data is! Map<String, dynamic>) throw StateError('Invalid remote ponjika JSON');
      return _normalizeYear(data, year);
    }

    await Future<void>.delayed(const Duration(milliseconds: 150));
    final raw = await rootBundle.loadString('assets/mock/ponjika.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) throw StateError('Invalid ponjika asset JSON');
    return _normalizeYear(decoded, year);
  }

  Map<String, dynamic> _normalizeYear(Map<String, dynamic> json, int year) {
    final copy = jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
    final delta = year - _baseYear;
    copy['year'] = year;
    copy['bengaliYear'] = '${1433 + delta}';

    final today = copy['today'];
    if (today is Map<String, dynamic>) {
      copy['today'] = {
        ...today,
        'date': _shiftIsoDate(today['date'] as String? ?? '', delta),
        'bengaliDate': _shiftBengaliYearLabel(today['bengaliDate'] as String? ?? '', delta),
      };
    }

    final days = copy['durgaPujaDays'];
    if (days is List) {
      copy['durgaPujaDays'] = days.map((d) {
        final m = Map<String, dynamic>.from(d as Map);
        m['date'] = _shiftIsoDate(m['date'] as String? ?? '', delta);
        return m;
      }).toList();
    }

    final ek = copy['ekadashi'];
    if (ek is Map<String, dynamic>) {
      final items = ek['items'];
      copy['ekadashi'] = {
        ...ek,
        'year': year,
        'upcomingDate': _shiftIsoDate(ek['upcomingDate'] as String? ?? '', delta),
        if (items is List)
          'items': items.map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            m['date'] = _shiftIsoDate(m['date'] as String? ?? '', delta);
            m['parana'] = _shiftParana(m['parana'] as String? ?? '', delta);
            return m;
          }).toList(),
      };
    }

    final logno = copy['logno'];
    if (logno is Map<String, dynamic>) {
      copy['logno'] = _normalizeLognoYear(logno, year, delta);
    }

    return copy;
  }

  Map<String, dynamic> _normalizeLognoYear(Map<String, dynamic> logno, int year, int delta) {
    final out = Map<String, dynamic>.from(logno);
    for (final key in ['puja', 'marriage', 'beye']) {
      final section = out[key];
      if (section is Map<String, dynamic>) {
        out[key] = {
          ...section,
          'title': (section['title'] as String? ?? '').replaceAll(RegExp(r'\d{4}'), '$year'),
        };
      }
    }
    if (out['todayTitle'] is String) {
      out['todayTitle'] = (out['todayTitle'] as String).replaceAll(RegExp(r'\d{4}'), '$year');
    }
    final highlights = out['monthlyHighlights'];
    if (highlights is List) {
      out['monthlyHighlights'] = highlights.map((h) {
        final m = Map<String, dynamic>.from(h as Map);
        m['month'] = (m['month'] as String? ?? '').replaceAll(RegExp(r'\d{4}'), '$year');
        return m;
      }).toList();
    }
    return out;
  }

  static String _shiftIsoDate(String iso, int yearDelta) {
    if (iso.isEmpty) return iso;
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateTime(d.year + yearDelta, d.month, d.day).toIso8601String().split('T').first;
  }

  static String _shiftParana(String parana, int yearDelta) {
    final parts = parana.split(' ');
    if (parts.isEmpty) return parana;
    final date = _shiftIsoDate(parts.first, yearDelta);
    return parts.length > 1 ? '$date ${parts.sublist(1).join(' ')}' : date;
  }

  static String _shiftBengaliYearLabel(String label, int yearDelta) {
    final match = RegExp(r'১৪(\d{2})').firstMatch(label);
    if (match == null) return label;
    final bn = int.tryParse(match.group(1)!);
    if (bn == null) return label;
    return label.replaceFirst(match.group(0)!, '১৪${(bn + yearDelta).toString().padLeft(2, '0')}');
  }
}
