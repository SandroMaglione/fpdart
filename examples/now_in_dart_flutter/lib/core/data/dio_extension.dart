import 'package:dio/dio.dart';

extension DioExceptionExtension on DioException {
  bool get isNoConnectionError {
    return type == DioExceptionType.connectionError;
  }
}
