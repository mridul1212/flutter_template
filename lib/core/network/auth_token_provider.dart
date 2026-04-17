/// Supplies access tokens for [AuthInterceptor] without coupling Dio to SharedPreferences.
abstract class AuthTokenProvider {
  Future<String?> readAccessToken();
}
