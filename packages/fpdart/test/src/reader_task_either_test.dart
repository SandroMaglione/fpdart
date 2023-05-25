import 'package:fpdart/fpdart.dart';

import './utils/utils.dart';

void main() {
  group('ReaderTaskEither', () {
    test('ask', () async {
      final apply = ReaderTaskEither.ask();

      final result = await apply.run(12.2);
      result.matchTestRight((r) {
        expect(r, 12.2);
      });
    });

    test('asks', () async {
      final apply = ReaderTaskEither<double, String, int>.asks(
        (env) => env.toInt(),
      );

      final result = await apply.run(12.2);
      result.matchTestRight((r) {
        expect(r, 12);
      });
    });

    group('tryCatch', () {
      test('Success', () async {
        final apply = ReaderTaskEither<double, String, int>.tryCatch(
          (env) => Future.value(env.toInt()),
          (_, __) => 'error',
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 12);
        });
      });

      test('Failure', () async {
        final apply = ReaderTaskEither<double, String, int>.tryCatch(
          (env) => Future.error(env.toInt()),
          (_, __) => 'error',
        );
        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "error");
        });
      });

      test('throws Exception', () async {
        final apply = ReaderTaskEither<double, String, int>.tryCatch((_) {
          throw UnimplementedError();
        }, (error, _) {
          expect(error, isA<UnimplementedError>());
          return 'error';
        });

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "error");
        });
      });
    });

    group('flatMap', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).flatMap(
          (r) => ReaderTaskEither<double, String, int>(
            (env) async => Either.of(r + env.toInt()),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 24);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left("$env"),
        ).flatMap(
          (r) => ReaderTaskEither<double, String, int>(
            (env) async => Either.of(r + env.toInt()),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12.2");
        });
      });
    });

    group('ap', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).ap<double>(
          ReaderTaskEither(
            (env) async => Either.of((c) => c / 2),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 6);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left("$env"),
        ).ap<double>(
          ReaderTaskEither(
            (env) async => Either.of((c) => c / 2),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12.2");
        });
      });
    });

    group('map', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).map((r) => r / 2);

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 6);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left('$env'),
        ).map((r) => r / 2);

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12.2");
        });
      });
    });

    group('mapLeft', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).mapLeft(
          (l) => '$l and more',
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 12);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left("$env"),
        ).mapLeft(
          (l) => '$l and more',
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12.2 and more");
        });
      });
    });

    group('bimap', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).bimap(
          (l) => '$l and more',
          (a) => a * 2,
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 24);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left('$env'),
        ).bimap(
          (l) => '$l and more',
          (a) => a * 2,
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12.2 and more");
        });
      });
    });

    group('map2', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).map2<int, double>(
          ReaderTaskEither(
            (env) async => Either.of(env.toInt()),
          ),
          (b, c) => b / c,
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 1);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left('$env'),
        ).map2<int, double>(
          ReaderTaskEither(
            (env) async => Either.of(env.toInt()),
          ),
          (b, c) => b / c,
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12.2");
        });
      });
    });

    group('map3', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).map3<int, int, double>(
          ReaderTaskEither(
            (env) async => Either.of(env.toInt()),
          ),
          ReaderTaskEither(
            (env) async => Either.of(env.toInt()),
          ),
          (b, c, d) => b * c / d,
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 12);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left('$env'),
        ).map3<int, int, double>(
          ReaderTaskEither(
            (env) async => Either.of(env.toInt()),
          ),
          ReaderTaskEither(
            (env) async => Either.of(env.toInt()),
          ),
          (b, c, d) => b * c / d,
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12.2");
        });
      });
    });

    group('andThen', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).andThen(
          () => ReaderTaskEither(
            (env) async => Either.of(
              env.toInt() / 2,
            ),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 6);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left('$env'),
        ).andThen(
          () => ReaderTaskEither(
            (env) async => Either.of(env.toInt() / 2),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12.2");
        });
      });
    });

    group('call', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        )(
          ReaderTaskEither(
            (env) async => Either.of(env.toInt() / 2),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 6);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left('$env'),
        )(
          ReaderTaskEither(
            (env) async => Either.of(env.toInt() / 2),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12.2");
        });
      });
    });

    group('filterOrElse', () {
      test('Right (true)', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).filterOrElse(
          (r) => r > 5,
          (r) => 'abc',
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 12);
        });
      });

      test('Right (false)', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).filterOrElse(
          (r) => r < 5,
          (r) => '$r',
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12");
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left("$env"),
        ).filterOrElse(
          (r) => r > 5,
          (r) => 'none',
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "12.2");
        });
      });
    });

    test('pure', () async {
      final apply = ReaderTaskEither<double, String, int>(
        (env) async => Either.left("$env"),
      ).pure('abc');

      final result = await apply.run(12.2);
      result.matchTestRight((r) {
        expect(r, "abc");
      });
    });

    test('run', () async {
      final apply = ReaderTaskEither<double, String, int>(
        (env) async => Either.of(env.toInt()),
      );

      final future = apply.run(12.2);
      expect(future, isA<Future>());
      final result = await future;
      result.matchTestRight((r) {
        expect(r, 12);
      });
    });

    group('fromEither', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>.fromEither(
          Either.of(10),
        );
        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 10);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>.fromEither(
          Either.left('error'),
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "error");
        });
      });
    });

    group('fromOption', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>.fromOption(
          Option.of(10),
          () => 'none',
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 10);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>.fromOption(
          Option.none(),
          () => 'none',
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "none");
        });
      });
    });

    group('fromNullable', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>.fromNullable(
          10,
          () => "Error",
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 10);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>.fromNullable(
          null,
          () => "error",
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "error");
        });
      });
    });

    group('fromNullableAsync', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>.fromNullableAsync(
          10,
          Task(
            () async => "Error",
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 10);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>.fromNullableAsync(
          null,
          Task(
            () async => "error",
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestLeft((l) {
          expect(l, "error");
        });
      });
    });

    test('fromTask', () async {
      final apply = ReaderTaskEither<double, String, int>.fromTask(
        Task(
          () async => 10,
        ),
      );

      final result = await apply.run(12.2);
      result.matchTestRight((r) {
        expect(r, 10);
      });
    });

    test('left', () async {
      final apply = ReaderTaskEither<double, String, int>.left(
        'none',
      );

      final result = await apply.run(12.2);
      result.matchTestLeft((l) {
        expect(l, 'none');
      });
    });

    test('leftTask', () async {
      final apply = ReaderTaskEither<double, String, int>.leftTask(
        Task(
          () async => 'none',
        ),
      );

      final result = await apply.run(12.2);
      result.matchTestLeft((l) {
        expect(l, 'none');
      });
    });

    group('orElse', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).orElse<int>(
          (l) => ReaderTaskEither(
            (env) async => Right(l.length),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 12);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left('$env'),
        ).orElse<int>(
          (l) => ReaderTaskEither(
            (env) async => Right(l.length),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 4);
        });
      });
    });

    group('alt', () {
      test('Right', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.of(env.toInt()),
        ).alt(
          () => ReaderTaskEither(
            (env) async => Either.of(env.toInt() * 2),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 12);
        });
      });

      test('Left', () async {
        final apply = ReaderTaskEither<double, String, int>(
          (env) async => Either.left('none'),
        ).alt(
          () => ReaderTaskEither(
            (env) async => Either.of(env.toInt() * 12),
          ),
        );

        final result = await apply.run(12.2);
        result.matchTestRight((r) {
          expect(r, 144);
        });
      });
    });

    test('swap', () async {
      final apply = ReaderTaskEither<double, String, int>(
        (env) async => Either.of(env.toInt()),
      ).swap();

      final result = await apply.run(12.2);
      result.matchTestLeft((l) {
        expect(l, 12);
      });
    });

    test('of', () async {
      final apply = ReaderTaskEither<double, String, int>.of(10);

      final result = await apply.run(12.2);
      result.matchTestRight((r) {
        expect(r, 10);
      });
    });

    test('flatten', () async {
      final apply = ReaderTaskEither<double, String,
          ReaderTaskEither<double, String, int>>.of(
        ReaderTaskEither<double, String, int>.of(10),
      );

      final result = await ReaderTaskEither.flatten(apply).run(12.2);
      result.matchTestRight((r) {
        expect(r, 10);
      });
    });

    test('chainFirst', () async {
      final apply = ReaderTaskEither<double, String, int>.of(10);
      var sideEffect = 10;

      final chain = apply.chainFirst((b) {
        sideEffect = 100;
        return ReaderTaskEither.left("$b");
      });

      expect(sideEffect, 10);
      final result = await chain.run(12.2);
      result.matchTestLeft((l) {
        expect(l, "10");
        expect(sideEffect, 100);
      });
    });

    group('Do Notation', () {
      test('should return the correct value', () async {
        final doTaskEither = ReaderTaskEither<double, String, int>.Do(
          ($) => $(
            ReaderTaskEither.asks((env) => env.toInt()),
          ),
        );

        final run = await doTaskEither.run(12.2);
        run.matchTestRight((r) {
          expect(r, 12);
        });
      });

      test('should extract the correct values', () async {
        final doTaskEither =
            ReaderTaskEither<double, String, int>.Do(($) async {
          final a = await $(ReaderTaskEither.of(10));
          final b = await $(ReaderTaskEither.asks((env) => env.toInt()));
          return a + b;
        });

        final run = await doTaskEither.run(12.2);
        run.matchTestRight((r) {
          expect(r, 22);
        });
      });

      test('should return Left if any Either is Left', () async {
        final doTaskEither =
            ReaderTaskEither<double, String, int>.Do(($) async {
          final a = await $(ReaderTaskEither.of(10));
          final b = await $(ReaderTaskEither.asks((env) => env.toInt()));
          final c = await $(
            ReaderTaskEither<double, String, int>.left('error'),
          );

          return a + b + c;
        });

        final run = await doTaskEither.run(12.2);
        run.matchTestLeft((l) {
          expect(l, 'error');
        });
      });

      test('should rethrow if throw is used inside Do', () {
        final doTaskEither = ReaderTaskEither<double, String, int>.Do(($) {
          $(ReaderTaskEither.of(10));
          throw UnimplementedError();
        });

        expect(
          () => doTaskEither.run(12.2),
          throwsA(
            const TypeMatcher<UnimplementedError>(),
          ),
        );
      });

      test('should rethrow if Left is thrown inside Do', () {
        final doTaskEither = ReaderTaskEither<double, String, int>.Do(($) {
          $(
            ReaderTaskEither.of(10),
          );
          throw Left('error');
        });

        expect(
          () => doTaskEither.run(12.2),
          throwsA(
            const TypeMatcher<Left>(),
          ),
        );
      });

      test('should no execute past the first Left', () async {
        var mutable = 10;

        final doTaskEitherLeft =
            ReaderTaskEither<double, String, int>.Do(($) async {
          final a = await $(ReaderTaskEither.of(10));
          final b =
              await $(ReaderTaskEither<double, String, int>.left("error"));
          mutable += 10;
          return a + b;
        });

        final runLeft = await doTaskEitherLeft.run(12.2);
        expect(mutable, 10);
        runLeft.matchTestLeft((l) {
          expect(l, "error");
        });

        final doTaskEitherRight =
            ReaderTaskEither<double, String, int>.Do(($) async {
          final a = await $(ReaderTaskEither.asks((env) => env.toInt()));
          mutable += 10;
          return a;
        });

        final runRight = await doTaskEitherRight.run(12.2);
        expect(mutable, 20);
        runRight.matchTestRight((r) {
          expect(r, 12);
        });
      });
    });
  });
}
