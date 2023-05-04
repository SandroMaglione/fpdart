import 'package:fpdart/fpdart.dart';

import './utils/utils.dart';

void main() {
  group('IOOption', () {
    group('tryCatch', () {
      test('Success', () {
        final io = IOOption<int>.tryCatch(() => 10);
        final r = io.run();
        r.matchTestSome((r) => expect(r, 10));
      });

      test('throws Exception', () {
        final io = IOOption<int>.tryCatch(() {
          throw UnimplementedError();
        });
        final r = io.run();
        expect(r, isA<None>());
      });
    });

    group('tryCatchK', () {
      test('Success', () {
        final io = IOOption<int>.of(10);
        final ap = io.flatMap(IOOption.tryCatchK(
          (n) => n + 5,
        ));
        final r = ap.run();
        r.matchTestSome((r) => expect(r, 15));
      });

      test('throws Exception', () {
        final io = IOOption<int>.of(10);
        final ap = io.flatMap(IOOption.tryCatchK<int, int>((_) {
          throw UnimplementedError();
        }));
        final r = ap.run();
        expect(r, isA<None>());
      });
    });

    group('flatMap', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ap = io.flatMap((r) => IOOption<int>(() => Option.of(r + 10)));
        final r = ap.run();
        r.matchTestSome((r) => expect(r, 20));
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ap = io.flatMap((r) => IOOption<int>(() => Option.of(r + 10)));
        final r = ap.run();
        expect(r, isA<None>());
      });
    });

    group('ap', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ap = io.ap<double>(IOOption(() => Option.of((int c) => c / 2)));
        final r = ap.run();
        r.matchTestSome((r) => expect(r, 5.0));
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ap = io.ap<double>(IOOption(() => Option.of((int c) => c / 2)));
        final r = ap.run();
        expect(r, isA<None>());
      });
    });

    group('map', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ap = io.map((r) => r / 2);
        final r = ap.run();
        r.matchTestSome((r) => expect(r, 5.0));
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ap = io.map((r) => r / 2);
        final r = ap.run();
        expect(r, isA<None>());
      });
    });

    group('map2', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ap = io.map2<int, double>(
            IOOption<int>(() => Option.of(2)), (b, c) => b / c);
        final r = ap.run();
        r.matchTestSome((r) => expect(r, 5.0));
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ap = io.map2<int, double>(
            IOOption<int>(() => Option.of(2)), (b, c) => b / c);
        final r = ap.run();
        expect(r, isA<None>());
      });
    });

    group('map3', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ap = io.map3<int, int, double>(IOOption<int>(() => Option.of(2)),
            IOOption<int>(() => Option.of(5)), (b, c, d) => b * c / d);
        final r = ap.run();
        r.matchTestSome((r) => expect(r, 4.0));
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ap = io.map3<int, int, double>(IOOption<int>(() => Option.of(2)),
            IOOption<int>(() => Option.of(5)), (b, c, d) => b * c / d);
        final r = ap.run();
        expect(r, isA<None>());
      });
    });

    group('andThen', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ap = io.andThen(() => IOOption<double>(() => Option.of(12.5)));
        final r = ap.run();
        r.matchTestSome((r) => expect(r, 12.5));
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ap = io.andThen(() => IOOption<double>(() => Option.of(12.5)));
        final r = ap.run();
        expect(r, isA<None>());
      });
    });

    group('call', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ap = io(IOOption<double>(() => Option.of(12.5)));
        final r = ap.run();
        r.matchTestSome((r) => expect(r, 12.5));
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ap = io(IOOption<double>(() => Option.of(12.5)));
        final r = ap.run();
        expect(r, isA<None>());
      });
    });

    test('pure', () {
      final io = IOOption<int>(() => Option.none());
      final ap = io.pure('abc');
      final r = ap.run();
      r.matchTestSome((r) => expect(r, 'abc'));
    });

    test('run', () {
      final io = IOOption<int>(() => Option.of(10));
      final r = io.run();
      r.matchTestSome((r) => expect(r, 10));
    });

    group('fromEither', () {
      test('Some', () {
        final io = IOOption.fromEither<String, int>(Either.of(10));
        final r = io.run();
        r.matchTestSome((r) => expect(r, 10));
      });

      test('None', () {
        final io = IOOption.fromEither<String, int>(Either.left('none'));
        final r = io.run();
        expect(r, isA<None>());
      });
    });

    group('fromNullable', () {
      test('Right', () {
        final io = IOOption<int>.fromNullable(10);
        final result = io.run();
        result.matchTestSome((r) {
          expect(r, 10);
        });
      });

      test('Left', () {
        final io = IOOption<int>.fromNullable(null);
        final result = io.run();
        expect(result, isA<None>());
      });
    });

    group('fromPredicate', () {
      test('True', () {
        final io = IOOption<int>.fromPredicate(20, (n) => n > 10);
        final r = io.run();
        r.matchTestSome((r) => expect(r, 20));
      });

      test('False', () {
        final io = IOOption<int>.fromPredicate(10, (n) => n > 10);
        final r = io.run();
        expect(r, isA<None>());
      });
    });

    test('none()', () {
      final io = IOOption<int>.none();
      final r = io.run();
      expect(r, isA<None>());
    });

    test('some()', () {
      final io = IOOption<int>.some(10);
      final r = io.run();
      r.matchTestSome((r) => expect(r, 10));
    });

    group('match', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ex = io.match(() => -1, (r) => r + 10);
        final r = ex.run();
        expect(r, 20);
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ex = io.match(() => -1, (r) => r + 10);
        final r = ex.run();
        expect(r, -1);
      });
    });

    group('getOrElse', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ex = io.getOrElse(() => -1);
        final r = ex.run();
        expect(r, 10);
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ex = io.getOrElse(() => -1);
        final r = ex.run();
        expect(r, -1);
      });
    });

    group('orElse', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ex = io.orElse<int>(() => IOOption(() => Option.of(-1)));
        final r = ex.run();
        r.matchTestSome((r) => expect(r, 10));
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ex = io.orElse<int>(() => IOOption(() => Option.of(-1)));
        final r = ex.run();
        r.matchTestSome((r) => expect(r, -1));
      });
    });

    group('alt', () {
      test('Some', () {
        final io = IOOption<int>(() => Option.of(10));
        final ex = io.alt(() => IOOption(() => Option.of(20)));
        final r = ex.run();
        r.matchTestSome((r) => expect(r, 10));
      });

      test('None', () {
        final io = IOOption<int>(() => Option.none());
        final ex = io.alt(() => IOOption(() => Option.of(20)));
        final r = ex.run();
        r.matchTestSome((r) => expect(r, 20));
      });
    });

    test('of', () {
      final io = IOOption<int>.of(10);
      final r = io.run();
      r.matchTestSome((r) => expect(r, 10));
    });

    test('flatten', () {
      final io = IOOption<IOOption<int>>.of(IOOption<int>.of(10));
      final ap = IOOption.flatten(io);
      final r = ap.run();
      r.matchTestSome((r) => expect(r, 10));
    });

    group('toTaskOption', () {
      test('Some', () async {
        final io = IOOption(() => Option.of(10));
        final convert = io.toTaskOption();
        final r = await convert.run();
        r.matchTestSome((r) {
          expect(r, 10);
        });
      });

      test('None', () async {
        final io = IOOption(() => const Option.none());
        final convert = io.toTaskOption();
        final r = await convert.run();
        expect(r, isA<None>());
      });
    });

    group('toOptionEither', () {
      test('Some', () {
        final io = IOOption(() => Option.of(10));
        final convert = io.toIOEither(() => 'None');
        final r = convert.run();
        r.matchTestRight((r) {
          expect(r, 10);
        });
      });

      test('None', () {
        final io = IOOption(() => const Option.none());
        final convert = io.toIOEither(() => 'None');
        final r = convert.run();
        r.matchTestLeft((l) {
          expect(l, 'None');
        });
      });
    });

    group('toTaskEither', () {
      test('Some', () async {
        final io = IOOption(() => Option.of(10));
        final convert = io.toTaskEither(() => 'None');
        final r = await convert.run();
        r.matchTestRight((r) {
          expect(r, 10);
        });
      });

      test('None', () async {
        final io = IOOption(() => const Option.none());
        final convert = io.toTaskEither(() => 'None');
        final r = await convert.run();
        r.matchTestLeft((l) {
          expect(l, 'None');
        });
      });
    });

    group('sequenceList', () {
      test('Some', () {
        var sideEffect = 0;
        final list = [
          IOOption(() {
            sideEffect += 1;
            return some(1);
          }),
          IOOption(() {
            sideEffect += 1;
            return some(2);
          }),
          IOOption(() {
            sideEffect += 1;
            return some(3);
          }),
          IOOption(() {
            sideEffect += 1;
            return some(4);
          }),
        ];
        final traverse = IOOption.sequenceList(list);
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestSome((t) {
          expect(t, [1, 2, 3, 4]);
        });
        expect(sideEffect, list.length);
      });

      test('None', () {
        var sideEffect = 0;
        final list = [
          IOOption(() {
            sideEffect += 1;
            return some(1);
          }),
          IOOption(() {
            sideEffect += 1;
            return none<int>();
          }),
          IOOption(() {
            sideEffect += 1;
            return some(3);
          }),
          IOOption(() {
            sideEffect += 1;
            return some(4);
          }),
        ];
        final traverse = IOOption.sequenceList(list);
        expect(sideEffect, 0);
        final result = traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('traverseList', () {
      test('Some', () {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = IOOption.traverseList<int, String>(
          list,
          (a) => IOOption(
            () {
              sideEffect += 1;
              return some("$a");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestSome((t) {
          expect(t, ['1', '2', '3', '4', '5', '6']);
        });
        expect(sideEffect, list.length);
      });

      test('None', () {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = IOOption.traverseList<int, String>(
          list,
          (a) => IOOption(
            () {
              sideEffect += 1;
              return a % 2 == 0 ? some("$a") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('traverseListWithIndex', () {
      test('Some', () {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = IOOption.traverseListWithIndex<int, String>(
          list,
          (a, i) => IOOption(
            () {
              sideEffect += 1;
              return some("$a$i");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestSome((t) {
          expect(t, ['10', '21', '32', '43', '54', '65']);
        });
        expect(sideEffect, list.length);
      });

      test('None', () {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = IOOption.traverseListWithIndex<int, String>(
          list,
          (a, i) => IOOption(
            () {
              sideEffect += 1;
              return a % 2 == 0 ? some("$a$i") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('Do Notation', () {
      test('should return the correct value', () {
        final doIOOption = IOOption<int>.Do(($) => $(IOOption.of(10)));
        final run = doIOOption.run();
        run.matchTestSome((t) {
          expect(t, 10);
        });
      });

      test('should extract the correct values', () {
        final doIOOption = IOOption<int>.Do(($) {
          final a = $(IOOption.of(10));
          final b = $(IOOption.of(5));
          return a + b;
        });
        final run = doIOOption.run();
        run.matchTestSome((t) {
          expect(t, 15);
        });
      });

      test('should return Left if any Either is Left', () {
        final doIOOption = IOOption<int>.Do(($) {
          final a = $(IOOption.of(10));
          final b = $(IOOption.of(5));
          final c = $(IOOption<int>.none());
          return a + b + c;
        });
        final run = doIOOption.run();
        expect(run, isA<None>());
      });

      test('should rethrow if throw is used inside Do', () {
        final doIOOption = IOOption<int>.Do(($) {
          $(IOOption.of(10));
          throw UnimplementedError();
        });

        expect(
            doIOOption.run, throwsA(const TypeMatcher<UnimplementedError>()));
      });

      test('should rethrow if None is thrown inside Do', () {
        final doIOOption = IOOption<int>.Do(($) {
          $(IOOption.of(10));
          throw const None();
        });

        expect(doIOOption.run, throwsA(const TypeMatcher<None>()));
      });

      test('should no execute past the first Left', () {
        var mutable = 10;
        final doIOOptionNone = IOOption<int>.Do(($) {
          final a = $(IOOption.of(10));
          final b = $(IOOption<int>.none());
          mutable += 10;
          return a + b;
        });

        final runNone = doIOOptionNone.run();
        expect(mutable, 10);
        expect(runNone, isA<None>());

        final doIOOptionSome = IOOption<int>.Do(($) {
          final a = $(IOOption.of(10));
          mutable += 10;
          return a;
        });

        final runSome = doIOOptionSome.run();
        expect(mutable, 20);
        runSome.matchTestSome((t) {
          expect(t, 10);
        });
      });
    });
  });
}
