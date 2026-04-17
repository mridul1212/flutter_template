import 'package:dio/dio.dart';
import 'package:flutter_template/core/network/api_endpoints.dart';
import 'package:flutter_template/core/network/auth_token_provider.dart';
import 'package:flutter_template/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_template/core/network/interceptors/connectivity_interceptor.dart';
import 'package:flutter_template/core/network/interceptors/logging_interceptor.dart';
import 'package:flutter_template/core/network/network_gate.dart';

/// Builds a single configured [Dio] instance (timeouts, base URL, default headers, interceptors).
abstract final class DioFactory {
  static Dio create({
    required AuthTokenProvider tokenProvider,
    required NetworkGate networkGate,
    bool enableLogging = true,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        sendTimeout: ApiEndpoints.sendTimeout,
        headers: const <String, dynamic>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.json,
        validateStatus: (code) => code != null && code >= 200 && code < 300,
      ),
    );

    dio.interceptors.add(ConnectivityInterceptor(networkGate));
    dio.interceptors.add(AuthInterceptor(tokenProvider));
    if (enableLogging) {
      dio.interceptors.add(LoggingInterceptor());
    }
    return dio;
  }
}
