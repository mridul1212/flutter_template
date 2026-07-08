import 'dart:convert';

import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SoronjamLocalStore {
  SoronjamLocalStore(this._prefs);

  final SharedPreferences _prefs;

  Set<String> readChecked() {
    final raw = _prefs.getString(AppConstants.soronjamCheckedKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw);
      if (list is! List) return {};
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> writeChecked(Set<String> ids) async {
    await _prefs.setString(AppConstants.soronjamCheckedKey, jsonEncode(ids.toList(growable: false)));
  }
}
