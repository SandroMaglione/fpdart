import 'package:fpdart/fpdart.dart';
import 'package:now_in_dart_flutter/core/data/remote_response.dart';
import 'package:now_in_dart_flutter/core/domain/failure.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/constants.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_remote_service.dart';

typedef _FlutterDetail = TaskEither<Failure, RemoteResponse<String>>;

class FlutterDetailRemoteService extends DetailRemoteService {
  FlutterDetailRemoteService({
    super.dio,
    super.headerCache,
  });

  _FlutterDetail getWhatsNewFlutterDetail(int id) {
    return super.getDetail(id, flutterWhatsNewPath);
  }

  _FlutterDetail getFlutterReleaseNotesDetail(int id) {
    return super.getDetail(id, flutterReleaseNotesPath);
  }
}
