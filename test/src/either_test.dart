import 'package:fpdart/fpdart.dart';

import './utils/utils.dart';

void main() {
  group('Either', () {
    group('[Property-based testing]', () {});

    group('is a', () {
      final either = Either<String, int>.of(10);

      test('Monad', () {
        expect(either, isA<Monad2>());
      });

      test('Applicative', () {
        expect(either, isA<Applicative2>());
      });

      test('Functor', () {
        expect(either, isA<Functor2>());
      });

      test('Foldable', () {
        expect(either, isA<Foldable2>());
      });

      test('Alt', () {
        expect(either, isA<Alt2>());
      });

      test('Extend', () {
        expect(either, isA<Extend2>());
      });
    });

    group('map', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final map = value.map((a) => a + 1);
        map.matchTestRight((r) {
          expect(r, 11);
        });
      });

      test('Left', () {
        final value = Either<String, int>.left('abc');
        final map = value.map((a) => a + 1);
        map.matchTestLeft((l) => expect(l, 'abc'));
      });
    });

    group('map2', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final map = value.map2<double, double>(
            Either<String, double>.of(1.5), (a, b) => a + b);
        map.match((_) {
          fail('should be right');
        }, (r) => expect(r, 11.5));
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final map = value.map2<double, double>(
            Either<String, double>.of(1.5), (a, b) => a + b);
        map.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('map3', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final map = value.map3<double, double, double>(
            Either<String, double>.of(1.5),
            Either<String, double>.of(1.5),
            (a, b, c) => a + b + c);
        map.match((_) {
          fail('should be right');
        }, (r) => expect(r, 13.0));
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final map = value.map3<double, double, double>(
            Either<String, double>.of(1.5),
            Either<String, double>.of(1.5),
            (a, b, c) => a + b + c);
        map.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    test('pure', () {
      final value = Either<String, int>.of(10);
      final pure = value.pure('abc');
      pure.match((_) {
        fail('should be right');
      }, (r) => expect(r, 'abc'));
    });

    group('mapLeft', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final map = value.mapLeft((a) => 'pre-$a');
        map.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Left', () {
        final value = Either<String, int>.left('abc');
        final map = value.mapLeft((a) => 'pre-$a');
        map.match((l) => expect(l, 'pre-abc'), (_) {
          fail('should be left');
        });
      });
    });

    group('foldRight', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final fold = value.foldRight<int>(10, (a, b) => a + b);
        expect(fold, 20);
      });

      test('Left', () {
        final value = Either<String, int>.left('abc');
        final fold = value.foldRight<int>(10, (a, b) => a + b);
        expect(fold, 10);
      });
    });

    group('foldLeft', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final fold = value.foldLeft<int>(10, (a, b) => a + b);
        expect(fold, 20);
      });

      test('Left', () {
        final value = Either<String, int>.left('abc');
        final fold = value.foldLeft<int>(10, (a, b) => a + b);
        expect(fold, 10);
      });
    });

    group('foldRightWithIndex', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final fold = value.foldRightWithIndex<int>(10, (i, a, b) => a + b);
        expect(fold, 20);
      });

      test('Left', () {
        final value = Either<String, int>.left('abc');
        final fold = value.foldRightWithIndex<int>(10, (i, a, b) => a + b);
        expect(fold, 10);
      });
    });

    group('foldLeftWithIndex', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final fold = value.foldLeftWithIndex<int>(10, (i, a, b) => a + b);
        expect(fold, 20);
      });

      test('Left', () {
        final value = Either<String, int>.left('abc');
        final fold = value.foldLeftWithIndex<int>(10, (i, a, b) => a + b);
        expect(fold, 10);
      });
    });

    group('foldMap', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final fold = value.foldMap<int>(
            Monoid.instance(0, (a1, a2) => a1 + a2), (a) => a);
        expect(fold, 10);
      });

      test('Left', () {
        final value = Either<String, int>.left('abc');
        final fold = value.foldMap<int>(
            Monoid.instance(0, (a1, a2) => a1 + a2), (a) => a);
        expect(fold, 0);
      });
    });

    group('ap', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.ap(Either<String, int Function(int)>.of((n) => n + 1));
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, 11));
      });

      test('Left', () {
        final value = Either<String, int>.of(10);
        final ap = value.ap(Either<String, int Function(int)>.left('none'));
        ap.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('alt', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.alt(() => Either<String, int>.of(0));
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.alt(() => Either<String, int>.of(0));
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, 0));
      });
    });

    group('extend', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.extend((t) => t.getOrElse((l) => -1) * 0.5);
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, 5.0));
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.extend((t) => t.getOrElse((l) => -1) * 0.5);
        ap.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('duplicate', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.duplicate();
        expect(ap, isA<Either<String, Either<String, int>>>());
        ap.match((_) {
          fail('should be right');
        },
            (r) => r.match((_) {
                  fail('should be right');
                }, (r) => expect(r, 10)));
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.duplicate();
        expect(ap, isA<Either<String, Either<String, int>>>());
        ap.match(
            (l) => expect(l, 'none'),
            (r) => r.match((l) => expect(l, 'none'), (_) {
                  fail('should be left');
                }));
      });
    });

    group('length', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        expect(value.length(), 1);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        expect(value.length(), 0);
      });
    });

    group('concatenate', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.concatenate(Monoid.instance(0, (a1, a2) => a1 + a2));
        expect(ap, 10);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.concatenate(Monoid.instance(0, (a1, a2) => a1 + a2));
        expect(ap, 0);
      });
    });

    group('any', () {
      test('Right (true)', () {
        final value = Either<String, int>.of(10);
        final ap = value.any((a) => a > 5);
        expect(ap, true);
      });

      test('Right (false)', () {
        final value = Either<String, int>.of(10);
        final ap = value.any((a) => a < 5);
        expect(ap, false);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.any((a) => a > 5);
        expect(ap, false);
      });
    });

    group('all', () {
      test('Right (true)', () {
        final value = Either<String, int>.of(10);
        final ap = value.all((a) => a > 5);
        expect(ap, true);
      });

      test('Right (false)', () {
        final value = Either<String, int>.of(10);
        final ap = value.all((a) => a < 5);
        expect(ap, false);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.all((a) => a > 5);
        expect(ap, true);
      });
    });

    group('filterOrElse', () {
      test('Right (true)', () {
        final value = Either<String, int>.of(10);
        final ap = value.filterOrElse((r) => r > 5, (r) => 'else');
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Right (false)', () {
        final value = Either<String, int>.of(10);
        final ap = value.filterOrElse((r) => r < 5, (r) => 'else');
        ap.match((l) => expect(l, 'else'), (_) {
          fail('should be left');
        });
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.filterOrElse((r) => r > 5, (r) => 'else');
        ap.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('flatMap', () {
      group('Right', () {
        test('then Right', () {
          final value = Either<String, int>.of(10);
          final ap = value.flatMap<String>((a) => Right('$a'));
          ap.match((_) {
            fail('should be right');
          }, (r) => expect(r, '10'));
        });

        test('then Left', () {
          final value = Either<String, int>.of(10);
          final ap =
              value.flatMap<String>((a) => Either<String, String>.left('none'));
          ap.match((l) => expect(l, 'none'), (_) {
            fail('should be left');
          });
        });
      });

      group('Left', () {
        test('then Right', () {
          final value = Either<String, int>.left('0');
          final ap =
              value.flatMap<String>((a) => Either<String, String>.of('$a'));
          ap.match((l) => expect(l, '0'), (_) {
            fail('should be left');
          });
        });

        test('then Left', () {
          final value = Either<String, int>.left('0');
          final ap =
              value.flatMap<String>((a) => Either<String, String>.left('none'));
          ap.match((l) => expect(l, '0'), (_) {
            fail('should be left');
          });
        });
      });
    });

    group('toOption', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.toOption();
        ap.match((some) => expect(some, 10), () => null);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.toOption();
        expect(ap, isA<None<int>>());
      });
    });

    group('toTaskEither', () {
      test('Right', () async {
        final value = Either<String, int>.of(10);
        final ap = value.toTaskEither();
        final result = await ap.run();
        expect(result, value);
      });

      test('Left', () async {
        final value = Either<String, int>.left('none');
        final ap = value.toTaskEither();
        final result = await ap.run();
        expect(result, value);
      });
    });

    group('isLeft', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.isLeft();
        expect(ap, false);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.isLeft();
        expect(ap, true);
      });
    });

    group('isRight', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.isRight();
        expect(ap, true);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.isRight();
        expect(ap, false);
      });
    });

    group('getLeft', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.getLeft();
        expect(ap, isA<None<String>>());
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.getLeft();
        ap.match((some) => expect(some, 'none'), () => null);
      });
    });

    group('getRight', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.getRight();
        ap.match((some) => expect(some, 10), () => null);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.getRight();
        expect(ap, isA<None<int>>());
      });
    });

    group('getOrElse', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.getOrElse((l) => -1);
        expect(ap, 10);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.getOrElse((l) => -1);
        expect(ap, -1);
      });
    });

    group('match', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.match((l) => -1, (r) => 1);
        expect(ap, 1);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.match((l) => -1, (r) => 1);
        expect(ap, -1);
      });
    });

    group('elem', () {
      test('Right (true)', () {
        final value = Either<String, int>.of(10);
        final ap = value.elem(10, Eq.instance((a1, a2) => a1 == a2));
        expect(ap, true);
      });

      test('Right (false)', () {
        final value = Either<String, int>.of(10);
        final ap = value.elem(0, Eq.instance((a1, a2) => a1 == a2));
        expect(ap, false);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.elem(10, Eq.instance((a1, a2) => a1 == a2));
        expect(ap, false);
      });
    });

    group('exists', () {
      test('Right (true)', () {
        final value = Either<String, int>.of(10);
        final ap = value.exists((r) => r > 5);
        expect(ap, true);
      });

      test('Right (false)', () {
        final value = Either<String, int>.of(10);
        final ap = value.exists((r) => r < 5);
        expect(ap, false);
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.exists((r) => r > 5);
        expect(ap, false);
      });
    });

    group('swap', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.swap();
        ap.match((l) => expect(l, 10), (_) {
          fail('should be left');
        });
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.swap();
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, 'none'));
      });
    });

    group('flatten', () {
      test('Right Right', () {
        final value = Either<String, Either<String, int>>.of(Either.of(10));
        final ap = Either.flatten(value);
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Right Left', () {
        final value =
            Either<String, Either<String, int>>.of(Either.left('none'));
        final ap = Either.flatten(value);
        ap.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });

      test('Left', () {
        final value = Either<String, Either<String, int>>.left('none');
        final ap = Either.flatten(value);
        ap.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('orElse', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.orElse((l) => Either<String, int>.of(0));
        ap.match((l) {
          fail('should be right');
        }, (r) {
          expect(r, 10);
        });
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.orElse((l) => Either<String, int>.of(0));
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, 0));
      });
    });

    group('andThen', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value.andThen(() => Either<String, String>.of('10'));
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, '10'));
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value.andThen(() => Either<String, String>.of('10'));
        ap.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('call', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        final ap = value(Either<String, String>.of('10'));
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, '10'));
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        final ap = value(Either<String, String>.of('10'));
        ap.match((l) {
          expect(l, 'none');
        }, (_) {
          fail('should be left');
        });
      });
    });

    test('of()', () {
      final value = Either<String, int>.of(10);
      expect(value, isA<Right>());
      value.match((_) {
        fail('should be right');
      }, (r) => expect(r, 10));
    });

    test('right()', () {
      final value = Either<String, int>.right(10);
      expect(value, isA<Right>());
      value.match((_) {
        fail('should be right');
      }, (r) => expect(r, 10));
    });

    test('of() == right()', () {
      final of = Either<String, int>.of(10);
      final right = Either<String, int>.right(10);
      expect(of, right);
    });

    test('left()', () {
      final value = Either<String, int>.left('none');
      expect(value, isA<Left>());
      value.match((l) => expect(l, 'none'), (_) {
        fail('should be left');
      });
    });

    group('fromOption', () {
      test('Some', () {
        final value = Option.of(10);
        final either = Either.fromOption(value, () => 'none');
        either.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('None', () {
        final value = Option<int>.none();
        final either = Either.fromOption(value, () => 'none');
        either.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('fromPredicate', () {
      test('Right', () {
        final either =
            Either<String, int>.fromPredicate(10, (v) => v > 5, (_) => 'none');
        either.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Left', () {
        final either =
            Either<String, int>.fromPredicate(10, (v) => v < 5, (_) => 'none');
        either.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('fromNullable', () {
      test('Right', () {
        final either = Either<String, int>.fromNullable(10, (r) => 'none');
        either.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Left', () {
        final either = Either<String, int>.fromNullable(null, (r) => 'none');
        either.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('tryCatch', () {
      test('Right', () {
        final either = Either<String, int>.tryCatch(
            () => int.parse('10'), (o, s) => 'none');
        either.match((_) {
          fail('should be right');
        }, (r) => expect(r, 10));
      });

      test('Left', () {
        final either = Either<String, int>.tryCatch(
            () => int.parse('invalid'), (o, s) => 'none');
        either.match((l) => expect(l, 'none'), (_) {
          fail('should be left');
        });
      });
    });

    group('tryCatchK', () {
      test('Right', () {
        final either = Either<String, int>.of(10);
        final ap = either.flatMap(Either.tryCatchK(
          (n) => n + 5,
          (_, __) => 'none',
        ));
        ap.match((_) {
          fail('should be right');
        }, (r) => expect(r, 15));
      });

      test('Left', () {
        final either = Either<String, int>.of(10);
        final ap = either.flatMap(Either.tryCatchK(
          (_) => int.parse('invalid'),
          (_, __) => 'none',
        ));
        ap.match((l) => expect(l, 'none'), (r) {
          fail('should be left');
        });
      });
    });

    test('getEq', () {
      final eq = Either.getEq<String, int>(
          Eq.instance((a1, a2) => a1 == a2), Eq.instance((a1, a2) => a1 == a2));
      final eitherR = Either<String, int>.of(10);
      final eitherL = Either<String, int>.left('none');
      expect(eq.eqv(eitherR, eitherR), true);
      expect(eq.eqv(eitherR, Either<String, int>.of(10)), true);
      expect(eq.eqv(eitherR, Either<String, int>.of(9)), false);
      expect(eq.eqv(eitherR, Either<String, int>.left('none')), false);
      expect(eq.eqv(eitherL, eitherL), true);
      expect(eq.eqv(eitherL, Either<String, int>.left('none')), true);
      expect(eq.eqv(eitherL, Either<String, int>.left('error')), false);
    });

    test('getSemigroup', () {
      final sg = Either.getSemigroup<String, int>(
          Semigroup.instance((a1, a2) => a1 + a2));
      final eitherR = Either<String, int>.of(10);
      final eitherL = Either<String, int>.left('none');
      expect(sg.combine(eitherR, eitherR), Either<String, int>.of(20));
      expect(sg.combine(eitherR, eitherL), eitherR);
      expect(sg.combine(eitherL, eitherR), eitherR);
      expect(sg.combine(eitherL, Either<String, int>.left('error')), eitherL);
    });

    test('Right value', () {
      const r = Right<String, int>(10);
      expect(r.value, 10);
    });

    test('Left value', () {
      const l = Left<String, int>('none');
      expect(l.value, 'none');
    });

    group('traverseList', () {
      test('Right', () {
        final list = [1, 2, 3, 4, 5, 6];
        final result =
            Either.traverseList<String, int, String>(list, (a) => right("$a"));
        result.matchTestRight((r) {
          expect(r, ["1", "2", "3", "4", "5", "6"]);
        });
      });

      test('Left', () {
        final list = [1, 2, 3, 4, 5, 6];
        final result = Either.traverseList<String, int, String>(
          list,
          (a) => a % 2 == 0 ? right("$a") : left("Error"),
        );
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
      });
    });

    group('traverseListWithIndex', () {
      test('Right', () {
        final list = [1, 2, 3, 4, 5, 6];
        final result = Either.traverseListWithIndex<String, int, String>(
            list, (a, i) => right("$a$i"));
        result.matchTestRight((r) {
          expect(r, ["10", "21", "32", "43", "54", "65"]);
        });
      });

      test('Left', () {
        final list = [1, 2, 3, 4, 5, 6];
        final result = Either.traverseListWithIndex<String, int, String>(
          list,
          (a, i) => i % 2 == 0 ? right("$a$i") : left("Error"),
        );
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
      });
    });

    test('Right == Right', () {
      final r1 = Either<String, int>.of(10);
      final r2 = Either<String, int>.of(9);
      final r3 = Either<String, double>.of(8.0);
      final r4 = Either<String, int>.of(10);
      final r5 = Either<String, double>.of(10.0);
      final l1 = Either<String, int>.left('none');
      final l2 = Either<String, int>.left('error');
      final map1 = <String, Either>{'m1': r1, 'm2': r1};
      final map2 = <String, Either>{'m1': r1, 'm2': r2};
      final map3 = <String, Either>{'m1': r1, 'm2': r4};
      final map4 = <String, Either>{'m1': r1, 'm2': r3};
      final map5 = <String, Either>{'m1': r1, 'm2': r5};
      final map6 = <String, Either>{'m1': r1, 'm2': r1};
      final map7 = <String, Either>{'m1': r1, 'm2': l1};
      expect(r1, r1);
      expect(r1, r4);
      expect(r1, r5);
      expect(r1 == r2, false);
      expect(r1 == r3, false);
      expect(r1 == r3, false);
      expect(r1 == l1, false);
      expect(r1 == l2, false);
      expect(map1, map1);
      expect(map1, map6);
      expect(map1, map3);
      expect(map1, map5);
      expect(map1 == map2, false);
      expect(map1 == map4, false);
      expect(map1 == map7, false);
    });

    test('Left == Left', () {
      final r1 = Either<String, int>.of(10);
      final l1 = Either<String, int>.left('none');
      final l2 = Either<String, int>.left('error');
      final l3 = Either<String, int>.left('none');
      final l4 = Either<double, int>.left(1.0);
      final map1 = <String, Either>{'m1': l1, 'm2': l1};
      final map2 = <String, Either>{'m1': l1, 'm2': l3};
      final map3 = <String, Either>{'m1': l1, 'm2': l2};
      final map4 = <String, Either>{'m1': l1, 'm2': l4};
      final map5 = <String, Either>{'m1': l1, 'm2': r1};
      expect(l1, l1);
      expect(l1, l3);
      expect(l1 == l2, false);
      expect(l1 == r1, false);
      expect(map1, map1);
      expect(map1, map2);
      expect(map1 == map3, false);
      expect(map1 == map4, false);
      expect(map1 == map5, false);
    });

    group('toString', () {
      test('Right', () {
        final value = Either<String, int>.of(10);
        expect(value.toString(), 'Right(10)');
      });

      test('Left', () {
        final value = Either<String, int>.left('none');
        expect(value.toString(), 'Left(none)');
      });
    });
  });

  group('bind', () {
    test('Right', () {
      final either1 = Either<String, int>.of(10);
      final result = either1.bind((r) => Either<String, int>.of(r + 10));
      expect(result.getOrElse((l) => 0), 20);
    });

    test('Left', () {
      final either1 = Either<String, int>.left('String');
      final result = either1.bind((r) => Either<String, int>.of(r + 10));
      expect(result.getOrElse((l) => 0), 0);
      expect(result.getLeft().getOrElse(() => ''), 'String');
    });
  });

  group('bindFuture', () {
    test('Right', () async {
      final either1 = Either<String, int>.of(10);
      final asyncEither = either1.bindFuture((r) async => Either.of(r + 10));
      final result = await asyncEither.run();
      expect(result.getOrElse((l) => 0), 20);
    });

    test('Left', () async {
      final either1 = Either<String, int>.left('String');
      final asyncEither = either1.bindFuture((r) async => Either.of(r + 10));
      final result = await asyncEither.run();
      expect(result.getOrElse((l) => 0), 0);
      expect(result.getLeft().getOrElse(() => ''), 'String');
    });
  });

  test('chainFirst', () {
    final either = Either<String, int>.of(10);
    var sideEffect = 10;
    final chain = either.chainFirst((b) {
      sideEffect = 100;
      return Either.left("abc");
    });
    chain.match(
      (l) => fail('should be right'),
      (r) {
        expect(r, 10);
        expect(sideEffect, 100);
      },
    );
  });
}
