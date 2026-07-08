import 'dart:convert';

import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:flutter_template/features/budget/data/models/budget_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class BudgetLocalStore {
  BudgetLocalStore(this._prefs);

  final SharedPreferences _prefs;

  List<BudgetEntry>? readOverrides() {
    final raw = _prefs.getString(AppConstants.budgetEntriesKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw);
      if (list is! List) return null;
      return list.map((e) => BudgetEntry.fromJson(e as Map<String, dynamic>)).toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeOverrides(List<BudgetEntry> entries) async {
    final encoded = entries.map((e) => e.toJson()).toList(growable: false);
    await _prefs.setString(AppConstants.budgetEntriesKey, jsonEncode(encoded));
  }
}
