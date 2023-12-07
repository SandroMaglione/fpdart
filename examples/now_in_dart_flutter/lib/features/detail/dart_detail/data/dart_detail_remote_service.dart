import 'package:fpdart/fpdart.dart';
import 'package:now_in_dart_flutter/core/data/remote_response.dart';
import 'package:now_in_dart_flutter/core/domain/failure.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/constants.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_remote_service.dart';

typedef _DartDetail = TaskEither<Failure, RemoteResponse<String>>;

class DartDetailRemoteService extends DetailRemoteService {
  DartDetailRemoteService({
    super.dio,
    super.headerCache,
  });

  _DartDetail getDartChangelogDetail(int id) {
    return super.getDetail(id, dartChangelogPath);
  }
}
