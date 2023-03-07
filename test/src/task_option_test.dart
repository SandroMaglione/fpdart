import 'package:fpdart/fpdart.dart';

import './utils/utils.dart';

void main() {
  group('TaskOption', () {
    group('tryCatch', () {
      test('Success', () async {
        final task = TaskOption<int>.tryCatch(() => Future.value(10));
        final r = await task.run();
        r.matchTestSome((r) => expect(r, 10));
      });

      test('Failure', () async {
        final task = TaskOption<int>.tryCatch(() => Future.error(10));
        final r = await task.run();
        expect(r, isA<None>());
      });

      test('throws Exception', () async {
        final task = TaskOption<int>.tryCatch(() {
          throw UnimplementedError();
        });
        final r = await task.run();
        expect(r, isA<None>());
      });
    });

    group('tryCatchK', () {
      test('Success', () async {
        final task = TaskOption<int>.of(10);
        final ap = task.flatMap(TaskOption.tryCatchK(
          (n) => Future.value(n + 5),
        ));
        final r = await ap.run();
        r.matchTestSome((r) => expect(r, 15));
      });

      test('Failure', () async {
        final task = TaskOption<int>.of(10);
        final ap = task.flatMap(TaskOption.tryCatchK(
          (n) => Future<int>.error(n + 5),
        ));
        final r = await ap.run();
        expect(r, isA<None>());
      });

      test('throws Exception', () async {
        final task = TaskOption<int>.of(10);
        final ap = task.flatMap(TaskOption.tryCatchK<int, int>((_) {
          throw UnimplementedError();
        }));
        final r = await ap.run();
        expect(r, isA<None>());
      });
    });

    group('flatMap', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ap =
            task.flatMap((r) => TaskOption<int>(() async => Option.of(r + 10)));
        final r = await ap.run();
        r.matchTestSome((r) => expect(r, 20));
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ap =
            task.flatMap((r) => TaskOption<int>(() async => Option.of(r + 10)));
        final r = await ap.run();
        expect(r, isA<None>());
      });
    });

    group('ap', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ap = task
            .ap<double>(TaskOption(() async => Option.of((int c) => c / 2)));
        final r = await ap.run();
        r.matchTestSome((r) => expect(r, 5.0));
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ap = task
            .ap<double>(TaskOption(() async => Option.of((int c) => c / 2)));
        final r = await ap.run();
        expect(r, isA<None>());
      });
    });

    group('map', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ap = task.map((r) => r / 2);
        final r = await ap.run();
        r.matchTestSome((r) => expect(r, 5.0));
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ap = task.map((r) => r / 2);
        final r = await ap.run();
        expect(r, isA<None>());
      });
    });

    group('map2', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ap = task.map2<int, double>(
            TaskOption<int>(() async => Option.of(2)), (b, c) => b / c);
        final r = await ap.run();
        r.matchTestSome((r) => expect(r, 5.0));
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ap = task.map2<int, double>(
            TaskOption<int>(() async => Option.of(2)), (b, c) => b / c);
        final r = await ap.run();
        expect(r, isA<None>());
      });
    });

    group('map3', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ap = task.map3<int, int, double>(
            TaskOption<int>(() async => Option.of(2)),
            TaskOption<int>(() async => Option.of(5)),
            (b, c, d) => b * c / d);
        final r = await ap.run();
        r.matchTestSome((r) => expect(r, 4.0));
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ap = task.map3<int, int, double>(
            TaskOption<int>(() async => Option.of(2)),
            TaskOption<int>(() async => Option.of(5)),
            (b, c, d) => b * c / d);
        final r = await ap.run();
        expect(r, isA<None>());
      });
    });

    group('andThen', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ap =
            task.andThen(() => TaskOption<double>(() async => Option.of(12.5)));
        final r = await ap.run();
        r.matchTestSome((r) => expect(r, 12.5));
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ap =
            task.andThen(() => TaskOption<double>(() async => Option.of(12.5)));
        final r = await ap.run();
        expect(r, isA<None>());
      });
    });

    group('call', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ap = task(TaskOption<double>(() async => Option.of(12.5)));
        final r = await ap.run();
        r.matchTestSome((r) => expect(r, 12.5));
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ap = task(TaskOption<double>(() async => Option.of(12.5)));
        final r = await ap.run();
        expect(r, isA<None>());
      });
    });

    test('pure', () async {
      final task = TaskOption<int>(() async => Option.none());
      final ap = task.pure('abc');
      final r = await ap.run();
      r.matchTestSome((r) => expect(r, 'abc'));
    });

    test('run', () async {
      final task = TaskOption<int>(() async => Option.of(10));
      final future = task.run();
      expect(future, isA<Future>());
      final r = await future;
      r.matchTestSome((r) => expect(r, 10));
    });

    group('fromEither', () {
      test('Some', () async {
        final task = TaskOption.fromEither<String, int>(Either.of(10));
        final r = await task.run();
        r.matchTestSome((r) => expect(r, 10));
      });

      test('None', () async {
        final task = TaskOption.fromEither<String, int>(Either.left('none'));
        final r = await task.run();
        expect(r, isA<None>());
      });
    });

    group('fromNullable', () {
      test('Right', () async {
        final task = TaskOption<int>.fromNullable(10);
        final result = await task.run();
        result.matchTestSome((r) {
          expect(r, 10);
        });
      });

      test('Left', () async {
        final task = TaskOption<int>.fromNullable(null);
        final result = await task.run();
        expect(result, isA<None>());
      });
    });

    group('fromPredicate', () {
      test('True', () async {
        final task = TaskOption<int>.fromPredicate(20, (n) => n > 10);
        final r = await task.run();
        r.matchTestSome((r) => expect(r, 20));
      });

      test('False', () async {
        final task = TaskOption<int>.fromPredicate(10, (n) => n > 10);
        final r = await task.run();
        expect(r, isA<None>());
      });
    });

    test('fromTask', () async {
      final task = TaskOption<int>.fromTask(Task(() async => 10));
      final r = await task.run();
      r.matchTestSome((r) => expect(r, 10));
    });

    test('none()', () async {
      final task = TaskOption<int>.none();
      final r = await task.run();
      expect(r, isA<None>());
    });

    test('some()', () async {
      final task = TaskOption<int>.some(10);
      final r = await task.run();
      r.matchTestSome((r) => expect(r, 10));
    });

    group('match', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ex = task.match(() => -1, (r) => r + 10);
        final r = await ex.run();
        expect(r, 20);
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ex = task.match(() => -1, (r) => r + 10);
        final r = await ex.run();
        expect(r, -1);
      });
    });

    group('getOrElse', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ex = task.getOrElse(() => -1);
        final r = await ex.run();
        expect(r, 10);
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ex = task.getOrElse(() => -1);
        final r = await ex.run();
        expect(r, -1);
      });
    });

    group('orElse', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ex =
            task.orElse<int>(() => TaskOption(() async => Option.of(-1)));
        final r = await ex.run();
        r.matchTestSome((r) => expect(r, 10));
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ex =
            task.orElse<int>(() => TaskOption(() async => Option.of(-1)));
        final r = await ex.run();
        r.matchTestSome((r) => expect(r, -1));
      });
    });

    group('alt', () {
      test('Some', () async {
        final task = TaskOption<int>(() async => Option.of(10));
        final ex = task.alt(() => TaskOption(() async => Option.of(20)));
        final r = await ex.run();
        r.matchTestSome((r) => expect(r, 10));
      });

      test('None', () async {
        final task = TaskOption<int>(() async => Option.none());
        final ex = task.alt(() => TaskOption(() async => Option.of(20)));
        final r = await ex.run();
        r.matchTestSome((r) => expect(r, 20));
      });
    });

    test('of', () async {
      final task = TaskOption<int>.of(10);
      final r = await task.run();
      r.matchTestSome((r) => expect(r, 10));
    });

    test('flatten', () async {
      final task = TaskOption<TaskOption<int>>.of(TaskOption<int>.of(10));
      final ap = TaskOption.flatten(task);
      final r = await ap.run();
      r.matchTestSome((r) => expect(r, 10));
    });

    test('delay', () async {
      final task = TaskOption<int>(() async => Option.of(10));
      final ap = task.delay(const Duration(seconds: 2));
      final stopwatch = Stopwatch();
      stopwatch.start();
      await ap.run();
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds >= 2000, true);
    });

    group('toTaskEither', () {
      test('Some', () async {
        final task = TaskOption(() async => Option.of(10));
        final convert = task.toTaskEither(() => 'None');
        final r = await convert.run();
        r.matchTestRight((r) {
          expect(r, 10);
        });
      });

      test('None', () async {
        final task = TaskOption(() async => const Option.none());
        final convert = task.toTaskEither(() => 'None');
        final r = await convert.run();
        r.matchTestLeft((l) {
          expect(l, 'None');
        });
      });
    });

    group('sequenceList', () {
      test('Some', () async {
        var sideEffect = 0;
        final list = [
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return some(1);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return some(2);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return some(3);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return some(4);
          }),
        ];
        final traverse = TaskOption.sequenceList(list);
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, [1, 2, 3, 4]);
        });
        expect(sideEffect, list.length);
      });

      test('None', () async {
        var sideEffect = 0;
        final list = [
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return some(1);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return none<int>();
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return some(3);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return some(4);
          }),
        ];
        final traverse = TaskOption.sequenceList(list);
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('traverseList', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = TaskOption.traverseList<int, String>(
          list,
          (a) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return some("$a");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, ['1', '2', '3', '4', '5', '6']);
        });
        expect(sideEffect, list.length);
      });

      test('None', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = TaskOption.traverseList<int, String>(
          list,
          (a) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return a % 2 == 0 ? some("$a") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('traverseListWithIndex', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = TaskOption.traverseListWithIndex<int, String>(
          list,
          (a, i) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return some("$a$i");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, ['10', '21', '32', '43', '54', '65']);
        });
        expect(sideEffect, list.length);
      });

      test('None', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = TaskOption.traverseListWithIndex<int, String>(
          list,
          (a, i) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return a % 2 == 0 ? some("$a$i") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('sequenceListSeq', () {
      test('Some', () async {
        var sideEffect = 0;
        final list = [
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 0;
            return some(1);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 1;
            return some(2);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 2;
            return some(3);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 3;
            return some(4);
          }),
        ];
        final traverse = TaskOption.sequenceListSeq(list);
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, [1, 2, 3, 4]);
        });
        expect(sideEffect, 3);
      });

      test('None', () async {
        var sideEffect = 0;
        final list = [
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 0;
            return some(1);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 1;
            return none<int>();
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 2;
            return some(3);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 3;
            return some(4);
          }),
        ];
        final traverse = TaskOption.sequenceListSeq(list);
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, 3);
      });
    });

    group('traverseListSeq', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = TaskOption.traverseListSeq<int, String>(
          list,
          (a) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a - 1;
              return some("$a");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, ['1', '2', '3', '4', '5', '6']);
        });
        expect(sideEffect, 5);
      });

      test('None', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = TaskOption.traverseListSeq<int, String>(
          list,
          (a) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a - 1;
              return a % 2 == 0 ? some("$a") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, 5);
      });
    });

    group('traverseListWithIndexSeq', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = TaskOption.traverseListWithIndexSeq<int, String>(
          list,
          (a, i) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a + i;
              return some("$a$i");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, ['10', '21', '32', '43', '54', '65']);
        });
        expect(sideEffect, 11);
      });

      test('None', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = TaskOption.traverseListWithIndexSeq<int, String>(
          list,
          (a, i) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a + i;
              return a % 2 == 0 ? some("$a$i") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, 11);
      });
    });

    group('Do Notation', () {
      test('should return the correct value', () async {
        final doTaskOption = TaskOption<int>.Do(($) => $(TaskOption.of(10)));
        final run = await doTaskOption.run();
        run.matchTestSome((t) {
          expect(t, 10);
        });
      });

      test('should extract the correct values', () async {
        final doTaskOption = TaskOption<int>.Do(($) async {
          final a = await $(TaskOption.of(10));
          final b = await $(TaskOption.of(5));
          return a + b;
        });
        final run = await doTaskOption.run();
        run.matchTestSome((t) {
          expect(t, 15);
        });
      });

      test('should return Left if any Either is Left', () async {
        final doTaskOption = TaskOption<int>.Do(($) async {
          final a = await $(TaskOption.of(10));
          final b = await $(TaskOption.of(5));
          final c = await $(TaskOption<int>.none());
          return a + b + c;
        });
        final run = await doTaskOption.run();
        expect(run, isA<None>());
      });

      test('should rethrow if throw is used inside Do', () {
        final doTaskOption = TaskOption<int>.Do(($) {
          $(TaskOption.of(10));
          throw UnimplementedError();
        });

        expect(
            doTaskOption.run, throwsA(const TypeMatcher<UnimplementedError>()));
      });

      test('should rethrow if None is thrown inside Do', () {
        final doTaskOption = TaskOption<int>.Do(($) {
          $(TaskOption.of(10));
          throw const None();
        });

        expect(doTaskOption.run, throwsA(const TypeMatcher<None>()));
      });

      test('should no execute past the first Left', () async {
        var mutable = 10;
        final doTaskOptionNone = TaskOption<int>.Do(($) async {
          final a = await $(TaskOption.of(10));
          final b = await $(TaskOption<int>.none());
          mutable += 10;
          return a + b;
        });

        final runNone = await doTaskOptionNone.run();
        expect(mutable, 10);
        expect(runNone, isA<None>());

        final doTaskOptionSome = TaskOption<int>.Do(($) async {
          final a = await $(TaskOption.of(10));
          mutable += 10;
          return a;
        });

        final runSome = await doTaskOptionSome.run();
        expect(mutable, 20);
        runSome.matchTestSome((t) {
          expect(t, 10);
        });
      });
    });
  });
}
