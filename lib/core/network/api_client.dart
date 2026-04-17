import 'package:dio/dio.dart';
import 'package:flutter_template/core/network/network_exception.dart';

/// Thin typed wrapper over [Dio] for all HTTP verbs with shared error mapping.
///
/// Pass per-call [headers] to merge with [BaseOptions.headers]. The auth interceptor
/// may add `Authorization` automatically.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Dio get raw => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _guard(() {
      final merged = _mergeOptions(options, headers);
      return _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _guard(() {
      final merged = _mergeOptions(options, headers);
      return _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _guard(() {
      final merged = _mergeOptions(options, headers);
      return _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _guard(() {
      final merged = _mergeOptions(options, headers);
      return _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(() {
      final merged = _mergeOptions(options, headers);
      return _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
      );
    });
  }

  Options? _mergeOptions(Options? options, Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return options;
    final base = options ?? Options();
    return base.copyWith(
      headers: {...?base.headers, ...headers},
    );
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw NetworkException.fromDio(e);
    }
  }
}
