import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:now_in_dart_flutter/core/data/data.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_local_service.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_remote_service.dart';

part 'fakes.dart';

class MockDio extends Mock implements Dio {}

class MockResponse<T> extends Mock implements Response<T> {}

class MockHeaders extends Mock implements Headers {}

class MockHeaderCache extends Mock implements HeaderCache {}

class MockDetailRemoteService extends DetailRemoteService {
  MockDetailRemoteService({super.dio, super.headerCache});
}

class MockDetailLocalService extends DetailLocalService {
  MockDetailLocalService({super.isarDb});
}

class MockIsarDatabase extends Mock implements IsarDatabase {}

class MockIsar extends Mock implements Isar {}

class MockIsarCollection<T> extends Mock implements IsarCollection<T> {}
