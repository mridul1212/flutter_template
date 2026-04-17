import 'package:dio/dio.dart';

/// Maps [DioException] to a single app-level failure type.
class NetworkException implements Exception {
  NetworkException({
    required this.message,
    this.statusCode,
    this.data,
    this.type = DioExceptionType.unknown,
  });

  final String message;
  final int? statusCode;
  final dynamic data;
  final DioExceptionType type;

  factory NetworkException.fromDio(DioException e) {
    final response = e.response;
    final status = response?.statusCode;
    final data = response?.data;
    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Request timed out. Check your connection.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Invalid server certificate.';
        break;
      case DioExceptionType.badResponse:
        message = _messageFromStatus(status) ?? 'Unexpected server response.';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        break;
      case DioExceptionType.unknown:
        message = e.message?.isNotEmpty == true ? e.message! : 'Something went wrong.';
        break;
    }
    return NetworkException(
      message: message,
      statusCode: status,
      data: data,
      type: e.type,
    );
  }

  static String? _messageFromStatus(int? code) {
    if (code == null) return null;
    if (code == 401) return 'Unauthorized.';
    if (code == 403) return 'Forbidden.';
    if (code == 404) return 'Not found.';
    if (code >= 500) return 'Server error. Try again later.';
    return null;
  }

  @override
  String toString() => 'NetworkException($statusCode): $message';
}
