import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

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
  });
}
