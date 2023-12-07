import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_dto.dart';
import 'package:test/test.dart';

import '../../../../helpers/mocks.dart';

void main() {
  final isar = MockIsar();
  final isarDb = MockIsarDatabase();
  final isarCollection = MockIsarCollection<DetailDTO>();
  final detailLocalService = MockDetailLocalService(isarDb: isarDb);

  group(
    'DetailLocalService |',
    () {
      const fakeDetailDTO = DetailDTO(id: 1, html: 'html');

      setUpAll(() => when(() => isarDb.instance).thenReturn(isar));

      test(
        'should instantiate IsarDatabase() when not injected',
        () => expect(MockDetailLocalService(), isNotNull),
      );

      test(
        'The method `upsertDetail` should either update or insert the passed '
        'DetailDTO',
        () async {
          when(
            () => isar.writeTxn<Unit>(
              any(that: isA<Function>()),
              silent: any(named: 'silent', that: isA<bool>()),
            ),
          ).thenAnswer((_) async => unit);

          final result =
              await detailLocalService.upsertDetail(fakeDetailDTO).run();

          expect(result, isA<Unit>());
        },
      );

      group(
        'The method `getDetail`',
        () {
          setUpAll(
            () => when(() => isar.detailDTOs).thenReturn(isarCollection),
          );
          test(
            'should return DetailDTO object for the passed id',
            () async {
              when(() => isarCollection.get(any(that: isA<int>())))
                  .thenAnswer((_) async => fakeDetailDTO);

              final result = await detailLocalService.getDetail(1).run();

              expect(result, fakeDetailDTO);
            },
          );

          test(
            'should return null if invalid id is passed',
            () async {
              when(() => isarCollection.get(any(that: isA<int>())))
                  .thenAnswer((_) async => null);

              final result = await detailLocalService.getDetail(1).run();

              expect(result, isNull);
            },
          );
        },
      );
    },
  );
}
