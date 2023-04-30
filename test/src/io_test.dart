import 'package:fpdart/fpdart.dart';

import 'utils/utils.dart';

void main() {
  group('IO', () {
    group('is a', () {
      final io = IO(() => 10);

      test('Monad', () {
        expect(io, isA<Monad>());
      });

      test('Applicative', () {
        expect(io, isA<Applicative>());
      });

      test('Functor', () {
        expect(io, isA<Functor>());
      });
    });

    test('flatMap', () {
      final io = IO(() => 10);
      final ap = io.flatMap((a) => IO(() => a + 10));
      final r = ap.run();
      expect(r, 20);
    });

    test('flatMapTask', () async {
      final io = IO(() => 10);
      final ap = io.flatMapTask((a) => Task(() async => a + 10));
      final r = await ap.run();
      expect(r, 20);
    });

    test('toIOEither', () {
      final io = IO(() => 10);
      final ap = io.toIOEither<String>();
      final r = ap.run();
      r.matchTestRight((r) => expect(r, 10));
    });

    test('toTask', () async {
      final io = IO(() => 10);
      final ap = io.toTask();
      final r = await ap.run();
      expect(r, 10);
    });

    test('toTaskEither', () async {
      final io = IO(() => 10);
      final ap = io.toTaskEither<String>();
      final r = await ap.run();
      r.matchTestRight((r) => expect(r, 10));
    });

    test('toTaskOption', () async {
      final io = IO(() => 10);
      final ap = io.toTaskOption();
      final r = await ap.run();
      r.matchTestSome((r) => expect(r, 10));
    });

    test('ap', () {
      final io = IO(() => 10);
      final ap = io.ap(IO(() => (int a) => a * 3));
      final r = ap.run();
      expect(r, 30);
    });

    test('pure', () {
      final io = IO(() => 10);
      final ap = io.pure('abc');
      final r = ap.run();
      expect(r, 'abc');
    });

    test('map', () {
      final io = IO(() => 10);
      final ap = io.map((a) => '$a');
      final r = ap.run();
      expect(r, '10');
    });

    test('map2', () {
      final io = IO(() => 10);
      final ap = io.map2<String, int>(IO(() => 'abc'), (a, c) => a + c.length);
      final r = ap.run();
      expect(r, 13);
    });

    test('map3', () {
      final io = IO(() => 10);
      final ap = io.map3<String, double, double>(
          IO(() => 'ab'), IO(() => 0.5), (a, c, d) => (a + c.length) * d);
      final r = ap.run();
      expect(r, 6.0);
    });

    test('andThen', () {
      final io = IO(() => 10);
      final ap = io.andThen(() => IO(() => 'abc'));
      final r = ap.run();
      expect(r, 'abc');
    });

    test('call', () {
      final io = IO(() => 10);
      final ap = io(IO(() => 'abc'));
      final r = ap.run();
      expect(r, 'abc');
    });

    test('flatten', () {
      final io = IO(() => IO(() => 10));
      final ap = IO.flatten(io);
      expect(ap, isA<IO<int>>());
      final r = ap.run();
      expect(r, 10);
    });

    test('run', () {
      final io = IO(() => 10);
      final r = io.run();
      expect(r, isA<int>());
      expect(r, 10);
    });

    test('sequenceList', () {
      var sideEffect = 0;
      final list = [
        IO(() {
          sideEffect += 1;
          return 1;
        }),
        IO(() {
          sideEffect += 1;
          return 2;
        }),
        IO(() {
          sideEffect += 1;
          return 3;
        }),
        IO(() {
          sideEffect += 1;
          return 4;
        })
      ];
      final traverse = IO.sequenceList(list);
      expect(sideEffect, 0);
      final result = traverse.run();
      expect(result, [1, 2, 3, 4]);
      expect(sideEffect, list.length);
    });

    test('traverseList', () {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = IO.traverseList<int, String>(list, (a) {
        sideEffect += 1;
        return IO.of("$a");
      });
      expect(sideEffect, 0);
      final result = traverse.run();
      expect(result, ['1', '2', '3', '4', '5', '6']);
      expect(sideEffect, list.length);
    });

    test('traverseListWithIndex', () {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = IO.traverseListWithIndex<int, String>(list, (a, i) {
        sideEffect += 1;
        return IO.of("$a$i");
      });
      expect(sideEffect, 0);
      final result = traverse.run();
      expect(result, ['10', '21', '32', '43', '54', '65']);
      expect(sideEffect, list.length);
    });
  });
}
