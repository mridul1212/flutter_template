abstract final class AppConstants {
  /// Demo credentials for local dummy auth.
  static const demoEmail = 'demo@app.com';
  static const demoPassword = 'password1';

  static const onboardingKey = 'onboarding_completed_v1';
  static const tokenKey = 'auth_token_v1';
  static const tokenExpiryKey = 'auth_token_expiry_v1';
  static const userJsonKey = 'user_profile_json_v1';

  static const themeModeKey = 'theme_mode_v1';

  /// Token TTL for dummy JWT-style persistence (7 days).
  static const tokenTtl = Duration(days: 7);

  static const dummyAvatarUrl = 'https://picsum.photos/id/64/400/400';
}
