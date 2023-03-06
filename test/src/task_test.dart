import 'package:fpdart/fpdart.dart';

import 'utils/utils.dart';

void main() {
  group('Task', () {
    group('map', () {
      test('int to int', () async {
        final task = Task(() async => 10);
        final ap = task.map((a) => a + 1);
        expect(ap, isA<Task<int>>());
        final r = await ap.run();
        expect(r, 11);
      });

      test('String to int', () async {
        final task = Task(() async => 'abc');
        final ap = task.map((a) => a.length);
        expect(ap, isA<Task<int>>());
        final r = await ap.run();
        expect(r, 3);
      });
    });

    test('ap', () async {
      final task = Task(() async => 10);
      final ap = task.ap(Task(() async => (int a) => a + 1));
      expect(ap, isA<Task>());
      final r = await ap.run();
      expect(r, 11);
    });

    test('flatMap', () async {
      final task = Task(() async => 10);
      final ap = task
          .flatMap((a) => Task(() async => '$a'))
          .flatMap((a) => Task(() async => a.length));
      expect(ap, isA<Task>());
      final r = await ap.run();
      expect(r, 2);
    });

    test('pure', () async {
      final task = Task(() async => 10);
      final ap = task.pure('abc');
      final r = await ap.run();
      expect(r, 'abc');
    });

    test('map2', () async {
      final task = Task(() async => 10);
      final m2 = task.map2<String, int>(Task.of('abc'), (a, c) => a + c.length);
      final r = await m2.run();
      expect(r, 13);
    });

    test('map3', () async {
      final task = Task(() async => 10);
      final m3 = task.map3<int, String, double>(
          Task.of(2), Task.of('abc'), (a, c, d) => (a + d.length) / c);
      final r = await m3.run();
      expect(r, 6.5);
    });

    test('delay', () async {
      final task = Task(() async => 10);
      final ap = task.delay(const Duration(seconds: 2));
      final stopwatch = Stopwatch();
      stopwatch.start();
      await ap.run();
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds >= 2000, true);
    });

    test('of', () async {
      final task = Task.of(10);
      final r = await task.run();
      expect(r, 10);
    });

    test('run', () async {
      final task = Task.of(10);
      final future = task.run();
      expect(future, isA<Future<int>>());
      final r = await future;
      expect(r, 10);
    });

    test('flatten', () async {
      final task = Task.of(Task.of(10));
      final t1 = await task.run();
      final t2 = await t1.run();
      final ap = Task.flatten(task);
      final r = await ap.run();
      expect(r, 10);
      expect(t2, 10);
      expect(r, t2);
    });

    group('andThen', () {
      test('run a Task after another Task', () async {
        final task = Task(() async => 10);
        final ap = task.andThen(() => Task.of('abc'));
        final r = await ap.run();
        expect(r, 'abc');
      });

      test('never run the second Task since the first throws', () async {
        final task = Task(() async => throw UnimplementedError());
        final ap = task.andThen(() => Task.of('abc'));
        expect(ap.run, throwsA(const TypeMatcher<UnimplementedError>()));
      });
    });

    group('call', () {
      test('run a Task after another Task', () async {
        final task = Task(() async => 10);
        final ap = task(Task.of('abc'));
        final r = await ap.run();
        expect(r, 'abc');
      });

      test('run the second Task but return throw error', () async {
        final task = Task<String>(() async => throw UnimplementedError());
        final ap = task(Task.of('abc'));
        expect(ap.run, throwsA(const TypeMatcher<UnimplementedError>()));
      });
    });

    test('toTaskOption', () async {
      final io = Task.of(10);
      final convert = io.toTaskOption();
      final r = await convert.run();
      r.matchTestSome((r) {
        expect(r, 10);
      });
    });

    test('toTaskEither', () async {
      final io = Task.of(10);
      final convert = io.toTaskEither();
      final r = await convert.run();
      r.matchTestRight((r) {
        expect(r, 10);
      });
    });

    test('sequenceList', () async {
      var sideEffect = 0;
      final list = [
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect += 1;
          return 1;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect += 1;
          return 2;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect += 1;
          return 3;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect += 1;
          return 4;
        }),
      ];
      final traverse = Task.sequenceList(list);
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, [1, 2, 3, 4]);
      expect(sideEffect, list.length);
    });

    test('sequenceListSeq', () async {
      var sideEffect = 0;
      final list = [
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect = 0;
          return 1;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect = 1;
          return 2;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect = 2;
          return 3;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect = 3;
          return 4;
        }),
      ];
      final traverse = Task.sequenceListSeq(list);
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, [1, 2, 3, 4]);
      expect(sideEffect, 3);
    });

    test('traverseList', () async {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = Task.traverseList<int, String>(
        list,
        (a) => Task(
          () async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return "$a";
          },
        ),
      );
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, ['1', '2', '3', '4', '5', '6']);
      expect(sideEffect, list.length);
    });

    test('traverseListWithIndex', () async {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = Task.traverseListWithIndex<int, String>(
        list,
        (a, i) => Task(
          () async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return "$a$i";
          },
        ),
      );
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, ['10', '21', '32', '43', '54', '65']);
      expect(sideEffect, list.length);
    });

    test('traverseListSeq', () async {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = Task.traverseListSeq<int, String>(
        list,
        (a) => Task(
          () async {
            await AsyncUtils.waitFuture();
            sideEffect = a;
            return "$a";
          },
        ),
      );
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, ['1', '2', '3', '4', '5', '6']);
      expect(sideEffect, 6);
    });

    test('traverseListWithIndexSeq', () async {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = Task.traverseListWithIndexSeq<int, String>(
        list,
        (a, i) => Task(
          () async {
            await AsyncUtils.waitFuture();
            sideEffect = a + i;
            return "$a$i";
          },
        ),
      );
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, ['10', '21', '32', '43', '54', '65']);
      expect(sideEffect, 11);
    });

    group('Do Notation', () {
      test('should return the correct value', () async {
        final doTask = Task.Do(($) => $(Task.of(10)));
        final run = await doTask.run();
        expect(run, 10);
      });

      test('should extract the correct values', () async {
        final doTask = Task.Do(($) async {
          final a = await $(Task.of(10));
          final b = await $(Task.of(5));
          return a + b;
        });
        final run = await doTask.run();
        expect(run, 15);
      });

      test('should not execute until run is called', () async {
        var mutable = 10;
        final doTask = Task.Do(($) async {
          final a = await $(Task.of(10));
          final b = await $(Task.of(5));
          mutable += 10;
          return a + b;
        });
        expect(mutable, 10);
        final run = await doTask.run();
        expect(mutable, 20);
        expect(run, 15);
      });
    });
  });
}
