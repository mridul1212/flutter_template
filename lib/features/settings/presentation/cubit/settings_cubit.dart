import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:flutter_template/core/permissions/location_permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    required this.pushNotifications,
    required this.anjaliReminders,
    required this.eventAlerts,
    required this.nearbyPujaAlerts,
    required this.groupUpdates,
    required this.locationSharing,
    this.busy = false,
    this.message,
    this.error,
  });

  final bool pushNotifications;
  final bool anjaliReminders;
  final bool eventAlerts;
  final bool nearbyPujaAlerts;
  final bool groupUpdates;
  final bool locationSharing;
  final bool busy;
  final String? message;
  final String? error;

  SettingsState copyWith({
    bool? pushNotifications,
    bool? anjaliReminders,
    bool? eventAlerts,
    bool? nearbyPujaAlerts,
    bool? groupUpdates,
    bool? locationSharing,
    bool? busy,
    String? message,
    bool clearMessage = false,
    String? error,
    bool clearError = false,
  }) {
    return SettingsState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      anjaliReminders: anjaliReminders ?? this.anjaliReminders,
      eventAlerts: eventAlerts ?? this.eventAlerts,
      nearbyPujaAlerts: nearbyPujaAlerts ?? this.nearbyPujaAlerts,
      groupUpdates: groupUpdates ?? this.groupUpdates,
      locationSharing: locationSharing ?? this.locationSharing,
      busy: busy ?? this.busy,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        pushNotifications,
        anjaliReminders,
        eventAlerts,
        nearbyPujaAlerts,
        groupUpdates,
        locationSharing,
        busy,
        message,
        error,
      ];

  static SettingsState fromPrefs(SharedPreferences prefs) {
    return SettingsState(
      pushNotifications: prefs.getBool(AppConstants.settingsPushNotificationsKey) ?? true,
      anjaliReminders: prefs.getBool(AppConstants.settingsAnjaliRemindersKey) ?? true,
      eventAlerts: prefs.getBool(AppConstants.settingsEventAlertsKey) ?? true,
      nearbyPujaAlerts: prefs.getBool(AppConstants.settingsNearbyAlertsKey) ?? true,
      groupUpdates: prefs.getBool(AppConstants.settingsGroupUpdatesKey) ?? true,
      locationSharing: prefs.getBool(AppConstants.settingsLocationSharingKey) ?? false,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs, this._location) : super(SettingsState.fromPrefs(_prefs));

  final SharedPreferences _prefs;
  final LocationPermissionService _location;

  Future<void> setPushNotifications(bool v) async {
    emit(state.copyWith(pushNotifications: v));
    await _prefs.setBool(AppConstants.settingsPushNotificationsKey, v);
  }

  Future<void> setAnjaliReminders(bool v) async {
    emit(state.copyWith(anjaliReminders: v));
    await _prefs.setBool(AppConstants.settingsAnjaliRemindersKey, v);
  }

  Future<void> setEventAlerts(bool v) async {
    emit(state.copyWith(eventAlerts: v));
    await _prefs.setBool(AppConstants.settingsEventAlertsKey, v);
  }

  Future<void> setNearbyPujaAlerts(bool v) async {
    emit(state.copyWith(nearbyPujaAlerts: v));
    await _prefs.setBool(AppConstants.settingsNearbyAlertsKey, v);
  }

  Future<void> setGroupUpdates(bool v) async {
    emit(state.copyWith(groupUpdates: v));
    await _prefs.setBool(AppConstants.settingsGroupUpdatesKey, v);
  }

  Future<void> setLocationSharing(bool v) async {
    emit(state.copyWith(locationSharing: v));
    await _prefs.setBool(AppConstants.settingsLocationSharingKey, v);
  }

  /// Turns on location sharing and requests OS permission. Returns false if denied.
  Future<bool> enableLocationSharing() async {
    await setLocationSharing(true);
    final ok = await _location.ensurePermission(requestIfNeeded: true);
    if (!ok) {
      await setLocationSharing(false);
    }
    return ok;
  }

  void clearTransient() => emit(state.copyWith(clearMessage: true, clearError: true));
}

