import 'package:fpdart/fpdart.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_dto.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_local_service.dart';

class FlutterDetailLocalService extends DetailLocalService {
  FlutterDetailLocalService({super.isarDb});

  Task<Unit> upsertFlutterDetail(DetailDTO detailDTO) {
    return super.upsertDetail(detailDTO);
  }

  Task<DetailDTO?> getFlutterDetail(int id) => super.getDetail(id);
}
