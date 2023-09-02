import 'package:fpdart/fpdart.dart';
import 'package:now_in_dart_flutter/core/data/remote_response.dart';
import 'package:now_in_dart_flutter/core/domain/failure.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_remote_service.dart';

typedef _FlutterDetail = TaskEither<Failure, RemoteResponse<String>>;

class FlutterDetailRemoteService extends DetailRemoteService {
  FlutterDetailRemoteService({
    super.dio,
    super.headerCache,
  });

  _FlutterDetail getWhatsNewFlutterDetail(int id) {
    const fullPathToMarkdownFile =
        'repos/flutter/website/contents/src/release/whats-new.md';
    return super.getDetail(id, fullPathToMarkdownFile);
  }

  _FlutterDetail getFlutterReleaseNotesDetail(int id) {
    const fullPathToMarkdownFile =
        'repos/flutter/website/contents/src/release/release-notes/index.md';
    return super.getDetail(id, fullPathToMarkdownFile);
  }
}
