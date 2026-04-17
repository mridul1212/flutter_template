import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    final raw = _prefs.getString(AppConstants.themeModeKey);
    if (raw != null) {
      for (final mode in ThemeMode.values) {
        if (mode.name == raw) {
          emit(mode);
          break;
        }
      }
    }
  }

  final SharedPreferences _prefs;

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(AppConstants.themeModeKey, mode.name);
  }
}
