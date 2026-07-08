import 'dart:convert';

import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:flutter_template/features/auth/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  String? readAccessToken() => _prefs.getString(AppConstants.tokenKey);

  int? readTokenExpiryMs() => _prefs.getInt(AppConstants.tokenExpiryKey);

  bool isTokenValid() {
    final token = readAccessToken();
    if (token == null || token.isEmpty) return false;
    final expMs = readTokenExpiryMs();
    if (expMs == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expMs;
  }

  Future<void> persistSession({
    required String token,
    required DateTime expiresAt,
    required UserEntity user,
  }) async {
    await _prefs.setString(AppConstants.tokenKey, token);
    await _prefs.setInt(AppConstants.tokenExpiryKey, expiresAt.millisecondsSinceEpoch);
    await _prefs.setString(AppConstants.userJsonKey, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.tokenExpiryKey);
    await _prefs.remove(AppConstants.userJsonKey);
  }

  UserEntity? readUser() {
    final raw = _prefs.getString(AppConstants.userJsonKey);
    if (raw == null) return null;
    try {
      return UserEntity.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool readOnboardingCompleted() => _prefs.getBool(AppConstants.onboardingKey) ?? false;

  Future<void> writeOnboardingCompleted() async {
    await _prefs.setBool(AppConstants.onboardingKey, true);
  }
}
