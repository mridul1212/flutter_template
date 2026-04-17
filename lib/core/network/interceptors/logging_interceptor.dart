import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs requests/responses in debug mode only.
final class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> ${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        debugPrint('Headers: ${options.headers}');
      }
      if (options.data != null) {
        debugPrint('Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('*** DioError ${err.requestOptions.uri}: ${err.message}');
    }
    handler.next(err);
  }
}
