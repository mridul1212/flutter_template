import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_template/features/biye_lagno/data/models/biye_lagno_models.dart';

abstract class BiyeLagnoRepository {
  Future<BiyeLagnoData> loadMeta();
  Future<BiyeLagnoResult> match({
    required String profileAKey,
    required String profileBKey,
    String? manualAName,
    String? manualBName,
  });
}

class BiyeLagnoRepositoryImpl implements BiyeLagnoRepository {
  Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> _raw() async {
    if (_cache != null) return _cache!;
    final text = await rootBundle.loadString('assets/mock/biye_lagno.json');
    _cache = jsonDecode(text) as Map<String, dynamic>;
    return _cache!;
  }

  @override
  Future<BiyeLagnoData> loadMeta() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return BiyeLagnoData.fromJson(await _raw());
  }

  @override
  Future<BiyeLagnoResult> match({
    required String profileAKey,
    required String profileBKey,
    String? manualAName,
    String? manualBName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final raw = await _raw();
    final results = raw['mockResults'] as Map<String, dynamic>;
    final key = '${profileAKey}_$profileBKey';
    final alt = '${profileBKey}_$profileAKey';
    final resultJson = results[key] ?? results[alt];
    if (resultJson == null) {
      return BiyeLagnoResult(
        totalScore: 22,
        maxScore: 36,
        verdict: 'Average',
        verdictBn: 'মাঝারি',
        nadiDosha: false,
        bhakootDosha: true,
        breakdown: const [
          GunaFactorBreakdown(key: 'varna', points: 1, note: 'Partial match'),
          GunaFactorBreakdown(key: 'nadi', points: 0, note: 'Check with astrologer'),
        ],
        summary: 'Demo score for ${manualAName ?? profileAKey} & ${manualBName ?? profileBKey}. '
            'This is informational only — consult a priest for final guidance.',
      );
    }
    return BiyeLagnoResult.fromJson(resultJson as Map<String, dynamic>);
  }
}
