import 'dart:io';

import 'package:dio/dio.dart';

extension DioErrorX on DioException {
  bool get isNoConnectionError {
    return error is SocketException;
  }
}
