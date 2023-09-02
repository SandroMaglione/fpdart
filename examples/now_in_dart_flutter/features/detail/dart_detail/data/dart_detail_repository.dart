import 'package:fpdart/fpdart.dart';
import 'package:now_in_dart_flutter/core/data/data.dart';
import 'package:now_in_dart_flutter/core/domain/failure.dart';
import 'package:now_in_dart_flutter/core/domain/fresh.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_dto.dart';
import 'package:now_in_dart_flutter/features/detail/core/domain/detail.dart';
import 'package:now_in_dart_flutter/features/detail/dart_detail/data/dart_detail_local_service.dart';
import 'package:now_in_dart_flutter/features/detail/dart_detail/data/dart_detail_remote_service.dart';

typedef _DartDetailOrFailure = TaskEither<Failure, Fresh<Detail>>;

class DartDetailRepository {
  DartDetailRepository({
    DartDetailLocalService? localService,
    DartDetailRemoteService? remoteService,
  })  : _localService = localService ?? DartDetailLocalService(),
        _remoteService = remoteService ?? DartDetailRemoteService();

  final DartDetailLocalService _localService;
  final DartDetailRemoteService _remoteService;

  _DartDetailOrFailure getDartDetail(int id) {
    return TaskEither.Do(
      (_) async {
        final remoteResponse = await _(
          _remoteService.getDartChangelogDetail(id),
        );

        return remoteResponse.when(
          noConnection: () async {
            final dto = await _(_localService.getDartDetail(id).toTaskEither());
            return Fresh.no(entity: dto?.toDomain() ?? Detail.empty);
          },
          unmodifed: () async {
            final cachedData = await _(
              _localService.getDartDetail(id).toTaskEither(),
            );
            return Fresh.yes(entity: cachedData?.toDomain() ?? Detail.empty);
          },
          modified: (data) async {
            final dto = DetailDTO.parseHtml(id, data);
            await _(_localService.upsertDartDetail(dto).toTaskEither());
            return Fresh.yes(entity: dto.toDomain());
          },
        );
      },
    );
  }
}
