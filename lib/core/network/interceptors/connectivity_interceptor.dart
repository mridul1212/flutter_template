import 'package:dio/dio.dart';
import 'package:flutter_template/core/network/network_gate.dart';

/// Blocks outgoing API calls while offline. Set [RequestOptions.extra] key
/// `skipConnectivityCheck` to `true` for health/version pings that must run without network gate.
final class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._gate);

  final NetworkGate _gate;

  static const String skipConnectivityCheckKey = 'skipConnectivityCheck';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra[skipConnectivityCheckKey] == true) {
      handler.next(options);
      return;
    }
    if (!_gate.isOnline) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection.',
        ),
      );
      return;
    }
    handler.next(options);
  }
}
