import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-ekadashi reminder toggles (SRS EKD-02 mock).
class EkadashiReminderStore {
  EkadashiReminderStore(this._prefs);

  final SharedPreferences _prefs;
  static const _prefix = 'ekadashi_reminder_';

  bool isEnabled(String ekadashiId) => _prefs.getBool('$_prefix$ekadashiId') ?? false;

  Future<void> setEnabled(String ekadashiId, bool enabled) async {
    await _prefs.setBool('$_prefix$ekadashiId', enabled);
  }
}
