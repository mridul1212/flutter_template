import 'package:dio/dio.dart';

/// Minimal Dio for version policy fetches (no auth / connectivity interceptors).
abstract final class PlainDioFactory {
  static Dio create() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
        headers: const <String, dynamic>{
          'Accept': 'application/json',
        },
        validateStatus: (code) => code != null && code >= 200 && code < 500,
      ),
    );
  }
}
