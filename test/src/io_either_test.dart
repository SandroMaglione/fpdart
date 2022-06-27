import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('IOEither', () {
    group('tryCatch', () {
      test('Success', () {
        final task =
            IOEither<String, int>.tryCatch(() => 10, (_, __) => 'error');
        final r = task.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Failure', () {
        final task =
            IOEither<String, int>.tryCatch(() => 10, (_, __) => 'error');
        final r = task.run();
        r.match((l) => expect(l, 'error'), (r) => null);
      });

      test('throws Exception', () {
        final task = IOEither<String, int>.tryCatch(() {
          throw UnimplementedError();
        }, (error, _) {
          expect(error, isA<UnimplementedError>());
          return 'error';
        });
        final r = task.run();
        r.match((l) => expect(l, 'error'), (r) => null);
      });
    });

    group('flatMap', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap =
            task.flatMap((r) => IOEither<String, int>(() => Either.of(r + 10)));
        final r = ap.run();
        r.match((l) => null, (r) => expect(r, 20));
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap =
            task.flatMap((r) => IOEither<String, int>(() => Either.of(r + 10)));
        final r = ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('flatMapTask', () {
      test('Right to Right', () async {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap = task.flatMapTask((r) => TaskEither.of(r + 1));
        final r = await ap.run();
        r.match((l) => null, (r) => expect(r, 11));
      });

      test('Left to Right', () async {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap = task.flatMapTask((r) => TaskEither.of(r + 1));
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });

      test('Right to Left', () async {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap =
            task.flatMapTask((r) => TaskEither<String, int>.left('none'));
        final r = await ap.run();
        r.match((l) => expect(l, 'none'), (r) => null);
      });

      test('Left to Left', () async {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap =
            task.flatMapTask((r) => TaskEither<String, int>.left('none'));
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('toTask', () {
      test('Right', () async {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap = task.toTask();
        final r = await ap.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap = task.toTask();
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('ap', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap = task.ap<double>(IOEither(() => Either.of((int c) => c / 2)));
        final r = ap.run();
        r.match((l) => null, (r) => expect(r, 5.0));
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap = task.ap<double>(IOEither(() => Either.of((int c) => c / 2)));
        final r = ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('map', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap = task.map((r) => r / 2);
        final r = ap.run();
        r.match((l) => null, (r) => expect(r, 5.0));
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap = task.map((r) => r / 2);
        final r = ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('map2', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap = task.map2<int, double>(
            IOEither<String, int>(() => Either.of(2)), (b, c) => b / c);
        final r = ap.run();
        r.match((l) => null, (r) => expect(r, 5.0));
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap = task.map2<int, double>(
            IOEither<String, int>(() => Either.of(2)), (b, c) => b / c);
        final r = ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('map3', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap = task.map3<int, int, double>(
            IOEither<String, int>(() => Either.of(2)),
            IOEither<String, int>(() => Either.of(5)),
            (b, c, d) => b * c / d);
        final r = ap.run();
        r.match((l) => null, (r) => expect(r, 4.0));
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap = task.map3<int, int, double>(
            IOEither<String, int>(() => Either.of(2)),
            IOEither<String, int>(() => Either.of(5)),
            (b, c, d) => b * c / d);
        final r = ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('andThen', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap =
            task.andThen(() => IOEither<String, double>(() => Either.of(12.5)));
        final r = ap.run();
        r.match((l) => null, (r) => expect(r, 12.5));
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap =
            task.andThen(() => IOEither<String, double>(() => Either.of(12.5)));
        final r = ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('call', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap = task(IOEither<String, double>(() => Either.of(12.5)));
        final r = ap.run();
        r.match((l) => null, (r) => expect(r, 12.5));
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap = task(IOEither<String, double>(() => Either.of(12.5)));
        final r = ap.run();
        r.match((l) => null, (r) => expect(r, 12.5));
      });
    });

    group('filterOrElse', () {
      test('Right (true)', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap = task.filterOrElse((r) => r > 5, (r) => 'abc');
        final r = ap.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Right (false)', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ap = task.filterOrElse((r) => r < 5, (r) => 'none');
        final r = ap.run();
        r.match((l) => expect(l, 'none'), (r) => null);
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('abc'));
        final ap = task.filterOrElse((r) => r > 5, (r) => 'none');
        final r = ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    test('pure', () {
      final task = IOEither<String, int>(() => Either.left('abc'));
      final ap = task.pure('abc');
      final r = ap.run();
      r.match((l) => null, (r) => expect(r, 'abc'));
    });

    test('run', () {
      final task = IOEither<String, int>(() => Either.of(10));
      final func = task.run();
      expect(func, isA<Either<String, int>>());
      final r = func;
      r.match((l) => null, (r) => expect(r, 10));
    });

    group('fromEither', () {
      test('Right', () {
        final task = IOEither<String, int>.fromEither(Either.of(10));
        final r = task.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () {
        final task = IOEither<String, int>.fromEither(Either.left('error'));
        final r = task.run();
        r.match((l) => expect(l, 'error'), (r) => null);
      });
    });

    group('fromOption', () {
      test('Some', () {
        final task =
            IOEither<String, int>.fromOption(Option.of(10), () => 'none');
        final r = task.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('None', () {
        final task =
            IOEither<String, int>.fromOption(Option.none(), () => 'none');
        final r = task.run();
        r.match((l) => expect(l, 'none'), (r) => null);
      });
    });

    group('fromPredicate', () {
      test('True', () {
        final task =
            IOEither<String, int>.fromPredicate(20, (n) => n > 10, (n) => '$n');
        final r = task.run();
        r.match((l) => null, (r) => expect(r, 20));
      });

      test('False', () {
        final task =
            IOEither<String, int>.fromPredicate(10, (n) => n > 10, (n) => '$n');
        final r = task.run();
        r.match((l) => expect(l, '10'), (r) => null);
      });
    });

    test('fromIO', () {
      final task = IOEither<String, int>.fromIO(IO(() => 10));
      final r = task.run();
      r.match((l) => null, (r) => expect(r, 10));
    });

    test('left', () {
      final task = IOEither<String, int>.left('none');
      final r = task.run();
      r.match((l) => expect(l, 'none'), (r) => null);
    });

    test('right', () {
      final task = IOEither<String, int>.right(10);
      final r = task.run();
      r.match((l) => null, (r) => expect(r, 10));
    });

    test('leftTask', () {
      final task = IOEither<String, int>.leftIO(IO(() => 'none'));
      final r = task.run();
      r.match((l) => expect(l, 'none'), (r) => null);
    });

    test('rightTask', () {
      final task = IOEither<String, int>.rightIO(IO.of(10));
      final r = task.run();
      r.match((l) => null, (r) => expect(r, 10));
    });

    group('match', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ex = task.match((l) => l.length, (r) => r + 10);
        final r = ex.run();
        expect(r, 20);
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('none'));
        final ex = task.match((l) => l.length, (r) => r + 10);
        final r = ex.run();
        expect(r, 4);
      });
    });

    group('getOrElse', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ex = task.getOrElse((l) => l.length);
        final r = ex.run();
        expect(r, 10);
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('none'));
        final ex = task.getOrElse((l) => l.length);
        final r = ex.run();
        expect(r, 4);
      });
    });

    group('orElse', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ex = task.orElse<int>((l) => IOEither(() => Right(l.length)));
        final r = ex.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('none'));
        final ex = task.orElse<int>((l) => IOEither(() => Right(l.length)));
        final r = ex.run();
        r.match((l) => null, (r) => expect(r, 4));
      });
    });

    group('alt', () {
      test('Right', () {
        final task = IOEither<String, int>(() => Either.of(10));
        final ex = task.alt(() => IOEither(() => Either.of(20)));
        final r = ex.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () {
        final task = IOEither<String, int>(() => Either.left('none'));
        final ex = task.alt(() => IOEither(() => Either.of(20)));
        final r = ex.run();
        r.match((l) => null, (r) => expect(r, 20));
      });
    });

    test('swap', () {
      final task = IOEither<String, int>(() => Either.of(10));
      final ex = task.swap();
      final r = ex.run();
      r.match((l) => expect(l, 10), (r) => null);
    });

    test('of', () {
      final task = IOEither<String, int>.of(10);
      final r = task.run();
      r.match((l) => null, (r) => expect(r, 10));
    });

    test('flatten', () {
      final task = IOEither<String, IOEither<String, int>>.of(
          IOEither<String, int>.of(10));
      final ap = IOEither.flatten(task);
      final r = ap.run();
      r.match((l) => null, (r) => expect(r, 10));
    });
  });

  test('chainFirst', () async {
    final task = IOEither<String, int>.of(10);
    var sideEffect = 10;
    final chain = task.chainFirst((b) {
      sideEffect = 100;
      return IOEither.left("abc");
    });
    final r = await chain.run();
    r.match((l) => null, (r) {
      expect(r, 10);
      expect(sideEffect, 100);
    });
  });
}
