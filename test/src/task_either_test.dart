import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('TaskEither', () {
    group('tryCatch', () {
      test('Success', () async {
        final task = TaskEither<String, int>.tryCatch(
            () => Future.value(10), (_, __) => 'error');
        final r = await task.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Failure', () async {
        final task = TaskEither<String, int>.tryCatch(
            () => Future.error(10), (_, __) => 'error');
        final r = await task.run();
        r.match((l) => expect(l, 'error'), (r) => null);
      });

      test('throws Exception', () async {
        final task = TaskEither<String, int>.tryCatch(() {
          throw UnimplementedError();
        }, (error, _) {
          expect(error, isA<UnimplementedError>());
          return 'error';
        });
        final r = await task.run();
        r.match((l) => expect(l, 'error'), (r) => null);
      });
    });

    group('flatMap', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.flatMap(
            (r) => TaskEither<String, int>(() async => Either.of(r + 10)));
        final r = await ap.run();
        r.match((l) => null, (r) => expect(r, 20));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.flatMap(
            (r) => TaskEither<String, int>(() async => Either.of(r + 10)));
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('ap', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task
            .ap<double>(TaskEither(() async => Either.of((int c) => c / 2)));
        final r = await ap.run();
        r.match((l) => null, (r) => expect(r, 5.0));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task
            .ap<double>(TaskEither(() async => Either.of((int c) => c / 2)));
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('map', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.map((r) => r / 2);
        final r = await ap.run();
        r.match((l) => null, (r) => expect(r, 5.0));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.map((r) => r / 2);
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('map2', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.map2<int, double>(
            TaskEither<String, int>(() async => Either.of(2)), (b, c) => b / c);
        final r = await ap.run();
        r.match((l) => null, (r) => expect(r, 5.0));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.map2<int, double>(
            TaskEither<String, int>(() async => Either.of(2)), (b, c) => b / c);
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('map3', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.map3<int, int, double>(
            TaskEither<String, int>(() async => Either.of(2)),
            TaskEither<String, int>(() async => Either.of(5)),
            (b, c, d) => b * c / d);
        final r = await ap.run();
        r.match((l) => null, (r) => expect(r, 4.0));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.map3<int, int, double>(
            TaskEither<String, int>(() async => Either.of(2)),
            TaskEither<String, int>(() async => Either.of(5)),
            (b, c, d) => b * c / d);
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('andThen', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.andThen(
            () => TaskEither<String, double>(() async => Either.of(12.5)));
        final r = await ap.run();
        r.match((l) => null, (r) => expect(r, 12.5));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.andThen(
            () => TaskEither<String, double>(() async => Either.of(12.5)));
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('filterOrElse', () {
      test('Right (true)', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.filterOrElse((r) => r > 5, (r) => 'abc');
        final r = await ap.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Right (false)', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.filterOrElse((r) => r < 5, (r) => 'none');
        final r = await ap.run();
        r.match((l) => expect(l, 'none'), (r) => null);
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.filterOrElse((r) => r > 5, (r) => 'none');
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    test('pure', () async {
      final task = TaskEither<String, int>(() async => Either.left('abc'));
      final ap = task.pure('abc');
      final r = await ap.run();
      r.match((l) => null, (r) => expect(r, 'abc'));
    });

    test('run', () async {
      final task = TaskEither<String, int>(() async => Either.of(10));
      final future = task.run();
      expect(future, isA<Future>());
      final r = await future;
      r.match((l) => null, (r) => expect(r, 10));
    });

    group('fromEither', () {
      test('Right', () async {
        final task = TaskEither<String, int>.fromEither(Either.of(10));
        final r = await task.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = TaskEither<String, int>.fromEither(Either.left('error'));
        final r = await task.run();
        r.match((l) => expect(l, 'error'), (r) => null);
      });
    });

    group('fromOption', () {
      test('Some', () async {
        final task =
            TaskEither<String, int>.fromOption(Option.of(10), () => 'none');
        final r = await task.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('None', () async {
        final task =
            TaskEither<String, int>.fromOption(Option.none(), () => 'none');
        final r = await task.run();
        r.match((l) => expect(l, 'none'), (r) => null);
      });
    });

    group('fromPredicate', () {
      test('True', () async {
        final task = TaskEither<String, int>.fromPredicate(
            20, (n) => n > 10, (n) => '$n');
        final r = await task.run();
        r.match((l) => null, (r) => expect(r, 20));
      });

      test('False', () async {
        final task = TaskEither<String, int>.fromPredicate(
            10, (n) => n > 10, (n) => '$n');
        final r = await task.run();
        r.match((l) => expect(l, '10'), (r) => null);
      });
    });

    test('fromTask', () async {
      final task = TaskEither<String, int>.fromTask(Task(() async => 10));
      final r = await task.run();
      r.match((l) => null, (r) => expect(r, 10));
    });

    test('left', () async {
      final task = TaskEither<String, int>.left('none');
      final r = await task.run();
      r.match((l) => expect(l, 'none'), (r) => null);
    });

    test('right', () async {
      final task = TaskEither<String, int>.right(10);
      final r = await task.run();
      r.match((l) => null, (r) => expect(r, 10));
    });

    test('leftTask', () async {
      final task = TaskEither<String, int>.leftTask(Task(() async => 'none'));
      final r = await task.run();
      r.match((l) => expect(l, 'none'), (r) => null);
    });

    test('rightTask', () async {
      final task = TaskEither<String, int>.rightTask(Task.of(10));
      final r = await task.run();
      r.match((l) => null, (r) => expect(r, 10));
    });

    group('match', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ex = task.match((l) => l.length, (r) => r + 10);
        final r = await ex.run();
        expect(r, 20);
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('none'));
        final ex = task.match((l) => l.length, (r) => r + 10);
        final r = await ex.run();
        expect(r, 4);
      });
    });

    group('getOrElse', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ex = task.getOrElse((l) => l.length);
        final r = await ex.run();
        expect(r, 10);
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('none'));
        final ex = task.getOrElse((l) => l.length);
        final r = await ex.run();
        expect(r, 4);
      });
    });

    group('orElse', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ex =
            task.orElse<int>((l) => TaskEither(() async => Right(l.length)));
        final r = await ex.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('none'));
        final ex =
            task.orElse<int>((l) => TaskEither(() async => Right(l.length)));
        final r = await ex.run();
        r.match((l) => null, (r) => expect(r, 4));
      });
    });

    group('alt', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ex = task.alt(() => TaskEither(() async => Either.of(20)));
        final r = await ex.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('none'));
        final ex = task.alt(() => TaskEither(() async => Either.of(20)));
        final r = await ex.run();
        r.match((l) => null, (r) => expect(r, 20));
      });
    });

    test('swap', () async {
      final task = TaskEither<String, int>(() async => Either.of(10));
      final ex = task.swap();
      final r = await ex.run();
      r.match((l) => expect(l, 10), (r) => null);
    });

    test('of', () async {
      final task = TaskEither<String, int>.of(10);
      final r = await task.run();
      r.match((l) => null, (r) => expect(r, 10));
    });

    test('flatten', () async {
      final task = TaskEither<String, TaskEither<String, int>>.of(
          TaskEither<String, int>.of(10));
      final ap = TaskEither.flatten(task);
      final r = await ap.run();
      r.match((l) => null, (r) => expect(r, 10));
    });

    test('delay', () async {
      final task = TaskEither<String, int>(() async => Either.of(10));
      final ap = task.delay(const Duration(seconds: 2));
      final stopwatch = Stopwatch();
      stopwatch.start();
      await ap.run();
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds >= 2000, true);
    });
  });
}
