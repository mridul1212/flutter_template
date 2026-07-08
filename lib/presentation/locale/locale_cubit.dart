import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._prefs) : super(null) {
    final raw = _prefs.getString(AppConstants.localeKey);
    if (raw == null || raw.isEmpty) return;
    // store as e.g. "en" or "bn"
    emit(Locale(raw));
  }

  final SharedPreferences _prefs;

  Future<void> setLocale(Locale? locale) async {
    emit(locale);
    if (locale == null) {
      await _prefs.remove(AppConstants.localeKey);
      return;
    }
    await _prefs.setString(AppConstants.localeKey, locale.languageCode);
  }
}

