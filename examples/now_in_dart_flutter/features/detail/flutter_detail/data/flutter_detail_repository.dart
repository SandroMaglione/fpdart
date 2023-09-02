import 'package:fpdart/fpdart.dart';
import 'package:now_in_dart_flutter/core/data/remote_response.dart';
import 'package:now_in_dart_flutter/core/domain/failure.dart';
import 'package:now_in_dart_flutter/core/domain/fresh.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_dto.dart';
import 'package:now_in_dart_flutter/features/detail/core/domain/detail.dart';
import 'package:now_in_dart_flutter/features/detail/flutter_detail/data/flutter_detail_local_service.dart';
import 'package:now_in_dart_flutter/features/detail/flutter_detail/data/flutter_detail_remote_service.dart';

typedef _FlutterDetailOrFailure = TaskEither<Failure, Fresh<Detail>>;

class FlutterDetailRepository {
  FlutterDetailRepository({
    FlutterDetailLocalService? localService,
    FlutterDetailRemoteService? remoteService,
  })  : _localService = localService ?? FlutterDetailLocalService(),
        _remoteService = remoteService ?? FlutterDetailRemoteService();

  final FlutterDetailLocalService _localService;
  final FlutterDetailRemoteService _remoteService;

  _FlutterDetailOrFailure getWhatsNewFlutterDetail(int id) {
    return _getFlutterDetail(id, _remoteService.getWhatsNewFlutterDetail);
  }

  _FlutterDetailOrFailure getFlutterReleaseNotesDetail(int id) {
    return _getFlutterDetail(id, _remoteService.getFlutterReleaseNotesDetail);
  }

  _FlutterDetailOrFailure _getFlutterDetail(
    int id,
    TaskEither<Failure, RemoteResponse<String>> Function(int) caller,
  ) {
    return TaskEither.Do(
      (_) async {
        final remoteResponse = await _(caller(id));

        return remoteResponse.when(
          noConnection: () async {
            final dto = await _(
              _localService.getFlutterDetail(id).toTaskEither(),
            );
            return Fresh.no(entity: dto?.toDomain() ?? Detail.empty);
          },
          unmodifed: () async {
            final cachedData = await _(
              _localService.getFlutterDetail(id).toTaskEither(),
            );
            return Fresh.yes(entity: cachedData?.toDomain() ?? Detail.empty);
          },
          modified: (data) async {
            final dto = DetailDTO.parseHtml(id, data);
            await _(_localService.upsertFlutterDetail(dto).toTaskEither());
            return Fresh.yes(entity: dto.toDomain());
          },
        );
      },
    );
  }
}
