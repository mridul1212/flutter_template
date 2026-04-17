/// Central place for API configuration. Replace with your backend URL.
abstract final class ApiEndpoints {
  /// Public JSON placeholder API — safe for demos (no API key).
  /// Swap for `String.fromEnvironment('API_BASE_URL')` in production.
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  /// Optional HTTPS JSON document with the same shape as [assets/config/version_policy.json].
  /// Leave empty to ship with asset-only policy (recommended until you host a real endpoint).
  static const String remoteVersionPolicyUrl = '';
}
