import 'package:dio/dio.dart';

/// Best-effort public IPv4 for client-side diagnostics. Prefer deriving IP on the server from the request.
final class PublicIpService {
  PublicIpService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );

  final Dio _dio;

  String? _cached;
  DateTime? _cachedAt;
  static const _ttl = Duration(minutes: 30);

  Future<String?> getPublicIpv4() async {
    if (_cached != null && _cachedAt != null && DateTime.now().difference(_cachedAt!) < _ttl) {
      return _cached;
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>('https://api.ipify.org?format=json');
      final ip = res.data?['ip'] as String?;
      _cached = ip;
      _cachedAt = DateTime.now();
      return ip;
    } catch (_) {
      return null;
    }
  }
}
