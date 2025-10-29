import 'package:fpdart/fpdart.dart';

import '../utils/utils.dart';

void main() {
  group('CompositionOptionExtension', () {
    group('toTaskOptionFlat', () {
      test('Some', () async {
        final task = Task(() async => Option.of(10));
        final convert = task.toTaskOptionFlat();
        final r = await convert.run();
        r.matchTestSome((r) {
          expect(r, 10);
        });
      });
      test('None', () async {
        final task = Task(() async => Option.none());
        final convert = task.toTaskOptionFlat();
        final r = await convert.run();
        expect(r, isA<None>());
      });
    });
  });

  group('CompositionEitherExtension', () {
    group('toTaskEitherFlat', () {
      test('Right', () async {
        final task = Task(() async => Either.of(10));
        final convert = task.toTaskEitherFlat();
        final r = await convert.run();
        r.matchTestRight((r) {
          expect(r, 10);
        });
      });
      test('Left', () async {
        final task = Task(() async => Either.left('none'));
        final convert = task.toTaskEitherFlat();
        final r = await convert.run();
        r.matchTestLeft((l) {
          expect(l, 'none');
        });
      });
    });
  });
}
