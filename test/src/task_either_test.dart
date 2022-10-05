import 'package:fpdart/fpdart.dart';

import './utils/utils.dart';

void main() {
  group('TaskEither', () {
    group('tryCatch', () {
      test('Success', () async {
        final task = TaskEither<String, int>.tryCatch(
            () => Future.value(10), (_, __) => 'error');
        final r = await task.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Failure', () async {
        final task = TaskEither<String, int>.tryCatch(
            () => Future.error(10), (_, __) => 'error');
        final r = await task.run();
        r.match((l) => expect(l, 'error'), (_) {
          fail('should be left');
        });
      });

      test('throws Exception', () async {
        final task = TaskEither<String, int>.tryCatch(() {
          throw UnimplementedError();
        }, (error, _) {
          expect(error, isA<UnimplementedError>());
          return 'error';
        });
        final r = await task.run();
        r.match((l) => expect(l, 'error'), (_) {
          fail('should be left');
        });
      });
    });

    group('tryCatchK', () {
      test('Success', () async {
        final task = TaskEither<String, int>.right(10);
        final ap = task.flatMap(TaskEither.tryCatchK(
          (n) => Future.value(n + 5),
          (_, __) => 'error',
        ));
        final r = await ap.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 15));
      });

      test('Failure', () async {
        final task = TaskEither<String, int>.right(10);
        final ap = task.flatMap(TaskEither.tryCatchK(
          (n) => Future<int>.error(n + 5),
          (_, __) => 'error',
        ));
        final r = await ap.run();
        r.match((l) => expect(l, 'error'), (_) {
          fail('should be left');
        });
      });

      test('throws Exception', () async {
        final task = TaskEither<String, int>.right(10);
        final ap = task.flatMap(TaskEither.tryCatchK<String, int, int>((_) {
          throw UnimplementedError();
        }, (error, _) {
          expect(error, isA<UnimplementedError>());
          return 'error';
        }));
        final r = await ap.run();
        r.match((l) => expect(l, 'error'), (_) {
          fail('should be left');
        });
      });
    });

    group('flatMap', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.flatMap(
            (r) => TaskEither<String, int>(() async => Either.of(r + 10)));
        final r = await ap.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 20));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.flatMap(
            (r) => TaskEither<String, int>(() async => Either.of(r + 10)));
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (_) {
          fail('should be left');
        });
      });
    });

    group('ap', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task
            .ap<double>(TaskEither(() async => Either.of((int c) => c / 2)));
        final r = await ap.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 5.0));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task
            .ap<double>(TaskEither(() async => Either.of((int c) => c / 2)));
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (_) {
          fail('should be left');
        });
      });
    });

    group('map', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.map((r) => r / 2);
        final r = await ap.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 5.0));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.map((r) => r / 2);
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (_) {
          fail('should be left');
        });
      });
    });

    group('mapLeft', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.mapLeft((l) => '$l and more');
        final r = await ap.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.mapLeft((l) => '$l and more');
        final r = await ap.run();
        r.match((l) => expect(l, 'abc and more'), (_) {
          fail('should be left');
        });
      });
    });

    group('bimap', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.bimap((l) => '$l and more', (a) => a * 2);
        final r = await ap.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 20));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.bimap((l) => '$l and more', (a) => a * 2);
        final r = await ap.run();
        r.match((l) => expect(l, 'abc and more'), (_) {
          fail('should be left');
        });
      });
    });

    group('map2', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.map2<int, double>(
            TaskEither<String, int>(() async => Either.of(2)), (b, c) => b / c);
        final r = await ap.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 5.0));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.map2<int, double>(
            TaskEither<String, int>(() async => Either.of(2)), (b, c) => b / c);
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (_) {
          fail('should be left');
        });
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
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 4.0));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.map3<int, int, double>(
            TaskEither<String, int>(() async => Either.of(2)),
            TaskEither<String, int>(() async => Either.of(5)),
            (b, c, d) => b * c / d);
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (_) {
          fail('should be left');
        });
      });
    });

    group('andThen', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.andThen(
            () => TaskEither<String, double>(() async => Either.of(12.5)));
        final r = await ap.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 12.5));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.andThen(
            () => TaskEither<String, double>(() async => Either.of(12.5)));
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (_) {
          fail('should be left');
        });
      });
    });

    group('call', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap =
            task(TaskEither<String, double>(() async => Either.of(12.5)));
        final r = await ap.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 12.5));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap =
            task(TaskEither<String, double>(() async => Either.of(12.5)));
        final r = await ap.run();
        r.match((r) {
          expect(r, 'abc');
        }, (_) {
          fail('should be left');
        });
      });
    });

    group('filterOrElse', () {
      test('Right (true)', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.filterOrElse((r) => r > 5, (r) => 'abc');
        final r = await ap.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Right (false)', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ap = task.filterOrElse((r) => r < 5, (r) => 'none');
        final r = await ap.run();
        r.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('abc'));
        final ap = task.filterOrElse((r) => r > 5, (r) => 'none');
        final r = await ap.run();
        r.match((l) => expect(l, 'abc'), (_) {
          fail('should be left');
        });
      });
    });

    test('pure', () async {
      final task = TaskEither<String, int>(() async => Either.left('abc'));
      final ap = task.pure('abc');
      final r = await ap.run();
      r.match((_) {
        fail('should be right');
      }, (r) => expect(r, 'abc'));
    });

    test('run', () async {
      final task = TaskEither<String, int>(() async => Either.of(10));
      final future = task.run();
      expect(future, isA<Future>());
      final r = await future;
      r.match((_) {
        fail('should be right');
      }, (r) => expect(r, 10));
    });

    group('fromEither', () {
      test('Right', () async {
        final task = TaskEither<String, int>.fromEither(Either.of(10));
        final r = await task.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = TaskEither<String, int>.fromEither(Either.left('error'));
        final r = await task.run();
        r.match((l) => expect(l, 'error'), (_) {
          fail('should be left');
        });
      });
    });

    group('fromOption', () {
      test('Some', () async {
        final task =
            TaskEither<String, int>.fromOption(Option.of(10), () => 'none');
        final r = await task.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('None', () async {
        final task =
            TaskEither<String, int>.fromOption(Option.none(), () => 'none');
        final r = await task.run();
        r.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('fromPredicate', () {
      test('True', () async {
        final task = TaskEither<String, int>.fromPredicate(
            20, (n) => n > 10, (n) => '$n');
        final r = await task.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 20));
      });

      test('False', () async {
        final task = TaskEither<String, int>.fromPredicate(
            10, (n) => n > 10, (n) => '$n');
        final r = await task.run();
        r.match((l) => expect(l, '10'), (_) {
          fail('should be left');
        });
      });
    });

    test('fromTask', () async {
      final task = TaskEither<String, int>.fromTask(Task(() async => 10));
      final r = await task.run();
      r.match((_) {
        fail('should be right');
      }, (r) => expect(r, 10));
    });

    test('left', () async {
      final task = TaskEither<String, int>.left('none');
      final r = await task.run();
      r.match((l) => expect(l, 'none'), (_) {
        fail('should be left');
      });
    });

    test('right', () async {
      final task = TaskEither<String, int>.right(10);
      final r = await task.run();
      r.match((_) {
        fail('should be right');
      }, (r) => expect(r, 10));
    });

    test('leftTask', () async {
      final task = TaskEither<String, int>.leftTask(Task(() async => 'none'));
      final r = await task.run();
      r.match((l) => expect(l, 'none'), (_) {
        fail('should be left');
      });
    });

    test('rightTask', () async {
      final task = TaskEither<String, int>.rightTask(Task.of(10));
      final r = await task.run();
      r.match((_) {
        fail('should be right');
      }, (r) => expect(r, 10));
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
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('none'));
        final ex =
            task.orElse<int>((l) => TaskEither(() async => Right(l.length)));
        final r = await ex.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 4));
      });
    });

    group('alt', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Either.of(10));
        final ex = task.alt(() => TaskEither(() async => Either.of(20)));
        final r = await ex.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Either.left('none'));
        final ex = task.alt(() => TaskEither(() async => Either.of(20)));
        final r = await ex.run();
        r.match((_) {
          fail('should be right');
        }, (r) => expect(r, 20));
      });
    });

    test('swap', () async {
      final task = TaskEither<String, int>(() async => Either.of(10));
      final ex = task.swap();
      final r = await ex.run();
      r.match((l) => expect(l, 10), (_) {
        fail('should be left');
      });
    });

    test('of', () async {
      final task = TaskEither<String, int>.of(10);
      final r = await task.run();
      r.match((_) {
        fail('should be right');
      }, (r) => expect(r, 10));
    });

    test('flatten', () async {
      final task = TaskEither<String, TaskEither<String, int>>.of(
          TaskEither<String, int>.of(10));
      final ap = TaskEither.flatten(task);
      final r = await ap.run();
      r.match((_) {
        fail('should be right');
      }, (r) => expect(r, 10));
    });

    test('chainFirst', () async {
      final task = TaskEither<String, int>.of(10);
      var sideEffect = 10;
      final chain = task.chainFirst((b) {
        sideEffect = 100;
        return TaskEither.left("abc");
      });
      final r = await chain.run();
      r.match(
        (l) => fail('should be right'),
        (r) {
          expect(r, 10);
          expect(sideEffect, 100);
        },
      );
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

    group('sequenceList', () {
      test('Right', () async {
        var sideEffect = 0;
        final list = [
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(1);
          }),
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(2);
          }),
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(3);
          }),
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(4);
          }),
        ];
        final traverse = TaskEither.sequenceList(list);
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestRight((t) {
          expect(t, [1, 2, 3, 4]);
        });
        expect(sideEffect, list.length);
      });

      test('Left', () async {
        var sideEffect = 0;
        final list = [
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(1);
          }),
          TaskEither(() async {
            sideEffect += 1;
            return left<String, int>("Error");
          }),
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(3);
          }),
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(4);
          }),
        ];
        final traverse = TaskEither.sequenceList(list);
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, list.length);
      });
    });

    group('traverseList', () {
      test('Right', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse =
            TaskEither.traverseList<String, int, String>(list, (a) {
          sideEffect += 1;
          return TaskEither.of("$a");
        });
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestRight((t) {
          expect(t, ['1', '2', '3', '4', '5', '6']);
        });
        expect(sideEffect, list.length);
      });

      test('Left', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse =
            TaskEither.traverseList<String, int, String>(list, (a) {
          sideEffect += 1;
          return a % 2 == 0 ? TaskEither.left("Error") : TaskEither.of("$a");
        });
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, list.length);
      });
    });

    group('traverseListWithIndex', () {
      test('Right', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse =
            TaskEither.traverseListWithIndex<String, int, String>(list, (a, i) {
          sideEffect += 1;
          return TaskEither.of("$a$i");
        });
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestRight((t) {
          expect(t, ['10', '21', '32', '43', '54', '65']);
        });
        expect(sideEffect, list.length);
      });

      test('Left', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse =
            TaskEither.traverseListWithIndex<String, int, String>(list, (a, i) {
          sideEffect += 1;
          return a % 2 == 0 ? TaskEither.left("Error") : TaskEither.of("$a$i");
        });
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, list.length);
      });
    });
  });
}
