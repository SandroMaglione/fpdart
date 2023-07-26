import 'package:fpdart/fpdart.dart';

import 'utils/utils.dart';

void main() {
  group('ReaderTask', () {
    test('ask', () async {
      final apply = ReaderTask.ask<String, int>();

      final result = await apply.run("abc");
      expect(result, "abc");
    });

    test('asks', () async {
      final apply = ReaderTask<String, int>.asks(
        (env) => env.length,
      );

      final result = await apply.run("abc");
      expect(result, 3);
    });

    group('map', () {
      test('int to int', () async {
        final apply = ReaderTask<String, int>(
          (env) async => env.length,
        ).map((a) => a + 1);

        final result = await apply.run("abc");
        expect(result, 4);
      });
    });

    test('ap', () async {
      final apply = ReaderTask<String, int>(
        (env) async => env.length,
      ).ap(
        ReaderTask(
          (env) async => (a) => a + 1,
        ),
      );

      final result = await apply.run("abc");
      expect(result, 4);
    });

    test('flatMap', () async {
      final apply = ReaderTask<String, int>(
        (env) async => env.length,
      )
          .flatMap(
            (a) => ReaderTask(
              (env) async => '$a-$env',
            ),
          )
          .flatMap(
            (a) => ReaderTask(
              (env) async => a.length + env.length,
            ),
          );

      final result = await apply.run("abc");
      expect(result, 8);
    });

    test('pure', () async {
      final apply = ReaderTask<String, int>(
        (env) async => env.length,
      ).pure('abc');

      final result = await apply.run("abc");
      expect(result, 'abc');
    });

    test('map2', () async {
      final apply = ReaderTask<String, int>(
        (env) async => env.length,
      ).map2<String, int>(
        ReaderTask.of('abc'),
        (a, c) => a + c.length,
      );

      final result = await apply.run("abc");
      expect(result, 6);
    });

    test('map3', () async {
      final apply = ReaderTask<String, int>(
        (env) async => env.length,
      ).map3<int, String, double>(
        ReaderTask.of(2),
        ReaderTask.of('abc'),
        (a, c, d) => (a + d.length) / c,
      );

      final result = await apply.run("abc");
      expect(result, 3);
    });

    test('of', () async {
      final apply = ReaderTask<String, int>.of(10);

      final result = await apply.run("abc");
      expect(result, 10);
    });

    test('run', () async {
      final apply = ReaderTask<String, int>.of(10);
      final future = apply.run("abc");

      expect(future, isA<Future<int>>());
      final result = await future;
      expect(result, 10);
    });

    test('flatten', () async {
      final apply = ReaderTask<String, ReaderTask<String, int>>.of(
        ReaderTask<String, int>.of(10),
      );

      final mid = await apply.run("abc");
      final flatten = ReaderTask.flatten(apply);

      final resultMid = await mid.run("abc");
      final resultFlatten = await flatten.run("abc");

      expect(resultMid, 10);
      expect(resultFlatten, 10);
      expect(resultMid, resultFlatten);
    });

    group('andThen', () {
      test('run a Task after another Task', () async {
        final apply = ReaderTask<String, int>(
          (env) async => env.length,
        ).andThen(
          () => ReaderTask(
            (env) async => env.length * 2,
          ),
        );

        final result = await apply.run("abc");
        expect(result, 6);
      });

      test('never run the second Task since the first throws', () async {
        final apply = ReaderTask<String, int>(
          (env) async => throw UnimplementedError(),
        );

        final result = apply.andThen<double>(
          () => ReaderTask.of(12.2),
        );
        expect(() => result.run("abc"),
            throwsA(const TypeMatcher<UnimplementedError>()));
      });
    });

    group('call', () {
      test('run a Task after another Task', () async {
        final apply = ReaderTask<String, int>(
          (env) async => env.length,
        )(ReaderTask.of('abc'));

        final result = await apply.run("abc");
        expect(result, 'abc');
      });

      test('run the second Task but return throw error', () async {
        final apply =
            ReaderTask<String, int>((env) async => throw UnimplementedError())(
          ReaderTask.of('abc'),
        );

        expect(() => apply.run("abc"),
            throwsA(const TypeMatcher<UnimplementedError>()));
      });
    });

    test('toReaderTaskEither', () async {
      final apply = ReaderTask<String, int>.of(10).toReaderTaskEither<double>();

      final result = await apply.run("abc");
      result.matchTestRight((r) {
        expect(r, 10);
      });
    });

    group('Do Notation', () {
      test('should return the correct value', () async {
        final doTask = ReaderTask<String, int>.Do(
          (_) => _(
            ReaderTask.of(10),
          ),
        );

        final run = await doTask.run("abc");
        expect(run, 10);
      });

      test('should extract the correct values', () async {
        final doTask = ReaderTask<String, int>.Do((_) async {
          final a = await _(ReaderTask((env) async => env.length));
          final b = await _(ReaderTask((env) async => env.length));
          return a + b;
        });

        final run = await doTask.run("abc");
        expect(run, 6);
      });

      test('should not execute until run is called', () async {
        var mutable = 10;
        final doTask = ReaderTask<String, int>.Do((_) async {
          final a = await _(ReaderTask.of(10));
          final b = await _(ReaderTask.of(5));
          mutable += 10;
          return a + b;
        });

        expect(mutable, 10);
        final run = await doTask.run("abc");
        expect(mutable, 20);
        expect(run, 15);
      });
    });
  });
}
