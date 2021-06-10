import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/task.dart';
import 'package:fpdart/src/task_either.dart';
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

    group('fromEither', () {
      test('Right', () async {
        final task = TaskEither<String, int>.fromEither(Right(10));
        final r = await task.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = TaskEither<String, int>.fromEither(Left('error'));
        final r = await task.run();
        r.match((l) => expect(l, 'error'), (r) => null);
      });
    });

    group('fromMaybe', () {
      test('Just', () async {
        final task = TaskEither<String, int>.fromMaybe(Just(10), () => 'none');
        final r = await task.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Nothing', () async {
        final task = TaskEither<String, int>.fromMaybe(Nothing(), () => 'none');
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

    group('match', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Right(10));
        final ex = task.match((l) => l.length, (r) => r + 10);
        final r = await ex.run();
        expect(r, 20);
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Left('none'));
        final ex = task.match((l) => l.length, (r) => r + 10);
        final r = await ex.run();
        expect(r, 4);
      });
    });

    group('getOrElse', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Right(10));
        final ex = task.getOrElse((l) => l.length);
        final r = await ex.run();
        expect(r, 10);
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Left('none'));
        final ex = task.getOrElse((l) => l.length);
        final r = await ex.run();
        expect(r, 4);
      });
    });

    group('orElse', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Right(10));
        final ex =
            task.orElse<int>((l) => TaskEither(() async => Right(l.length)));
        final r = await ex.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Left('none'));
        final ex =
            task.orElse<int>((l) => TaskEither(() async => Right(l.length)));
        final r = await ex.run();
        r.match((l) => null, (r) => expect(r, 4));
      });
    });

    group('alt', () {
      test('Right', () async {
        final task = TaskEither<String, int>(() async => Right(10));
        final ex = task.alt(() => TaskEither(() async => Right(20)));
        final r = await ex.run();
        r.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () async {
        final task = TaskEither<String, int>(() async => Left('none'));
        final ex = task.alt(() => TaskEither(() async => Right(20)));
        final r = await ex.run();
        r.match((l) => null, (r) => expect(r, 20));
      });
    });

    test('swap', () async {
      final task = TaskEither<String, int>(() async => Right(10));
      final ex = task.swap();
      final r = await ex.run();
      r.match((l) => expect(l, 10), (r) => null);
    });
  });
}
