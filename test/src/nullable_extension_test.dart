import 'package:fpdart/fpdart.dart';

import 'utils/utils.dart';

void main() {
  group("FpdartOnNullable", () {
    group("toOption", () {
      test('Some', () {
        final value = 10;
        final result = value.toOption();
        result.matchTestSome((t) {
          expect(t, value);
        });
      });

      test('None', () {
        int? value = null;
        final result = value.toOption();
        expect(result, isA<None<int>>());
      });
    });

    group("toEither", () {
      test('Right', () {
        final value = 10;
        final result = value.toEither(() => "Error");
        result.matchTestRight((t) {
          expect(t, value);
        });
      });

      test('Left', () {
        int? value = null;
        final result = value.toEither(() => "Error");
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
      });
    });

    group("toTaskEither", () {
      test('Right', () async {
        final value = 10;
        final task = value.toTaskEither(() => "Error");
        final result = await task.run();
        result.matchTestRight((t) {
          expect(t, value);
        });
      });

      test('Left', () async {
        int? value = null;
        final task = value.toTaskEither(() => "Error");
        final result = await task.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
      });
    });

    group("toTaskEitherAsync", () {
      test('Right', () async {
        final value = 10;
        final task = value.toTaskEitherAsync(Task.of("Error"));
        final result = await task.run();
        result.matchTestRight((t) {
          expect(t, value);
        });
      });

      test('Left', () async {
        int? value = null;
        final task = value.toTaskEitherAsync(Task.of("Error"));
        final result = await task.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
      });
    });
  });
}
