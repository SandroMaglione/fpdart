import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:meta/meta.dart';
import 'package:now_in_dart_flutter/core/data/data.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_dto.dart';

abstract class DetailLocalService {
  DetailLocalService({
    IsarDatabase? isarDb,
  }) : _isarDb = isarDb ?? IsarDatabase();

  final IsarDatabase _isarDb;

  Isar get _isar => _isarDb.instance;

  @protected
  @visibleForTesting
  Task<Unit> upsertDetail(DetailDTO detailDTO) {
    return Task(
      () {
        return _isar.writeTxn<Unit>(
          () async {
            await _isar.detailDTOs.put(detailDTO);
            return unit;
          },
          silent: true,
        );
      },
    );
  }

  @protected
  @visibleForTesting
  Task<DetailDTO?> getDetail(int id) {
    return Task(() => _isar.detailDTOs.get(id));
  }
}
