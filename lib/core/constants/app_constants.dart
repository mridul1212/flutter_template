abstract final class AppConstants {
  /// Demo credentials for local dummy auth.
  static const demoEmail = 'demo@app.com';
  static const demoPassword = 'password1';

  static const onboardingKey = 'onboarding_completed_v1';
  static const tokenKey = 'auth_token_v1';
  static const tokenExpiryKey = 'auth_token_expiry_v1';
  static const userJsonKey = 'user_profile_json_v1';

  static const themeModeKey = 'theme_mode_v1';
  static const localeKey = 'locale_v1';

  // Settings toggles
  static const settingsPushNotificationsKey = 'settings_push_notifications_v1';
  static const settingsAnjaliRemindersKey = 'settings_anjali_reminders_v1';
  static const settingsEventAlertsKey = 'settings_event_alerts_v1';
  static const settingsNearbyAlertsKey = 'settings_nearby_alerts_v1';
  static const settingsGroupUpdatesKey = 'settings_group_updates_v1';
  static const settingsLocationSharingKey = 'settings_location_sharing_v1';

  /// Ponjika / Logno / Ekadashi — on-device cache (keyed by calendar year).
  static const ponjikaCacheMetaKey = 'ponjika_cache_meta_v1';
  static const ponjikaSelectedYearKey = 'ponjika_selected_year_v1';
  static const soronjamCheckedKey = 'soronjam_checked_v1';
  static const budgetEntriesKey = 'budget_entries_v1';
  static const ponjikaCacheTtlCurrentYearHours = 24;
  static const ponjikaCacheTtlPastYearDays = 30;
  static const ponjikaMaxCachedYears = 4;

  /// Token TTL for dummy JWT-style persistence (7 days).
  static const tokenTtl = Duration(days: 7);

  static const dummyAvatarUrl = 'https://picsum.photos/id/64/400/400';
}
