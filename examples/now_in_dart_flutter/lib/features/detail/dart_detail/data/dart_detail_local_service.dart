import 'package:fpdart/fpdart.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_dto.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_local_service.dart';

class DartDetailLocalService extends DetailLocalService {
  DartDetailLocalService({super.isarDb});

  Task<Unit> upsertDartDetail(DetailDTO detailDTO) {
    return super.upsertDetail(detailDTO);
  }

  Task<DetailDTO?> getDartDetail(int id) => super.getDetail(id);
}
