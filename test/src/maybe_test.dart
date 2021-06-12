import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Maybe', () {
    group('is a', () {
      test('Monad', () {
        final maybe = Maybe.of(10);
        expect(maybe, isA<Monad>());
      });

      test('Applicative', () {
        final maybe = Maybe.of(10);
        expect(maybe, isA<Applicative>());
      });

      test('Foldable', () {
        final maybe = Maybe.of(10);
        expect(maybe, isA<Foldable>());
      });

      test('Alt', () {
        final maybe = Maybe.of(10);
        expect(maybe, isA<Alt>());
      });

      test('Extend', () {
        final maybe = Maybe.of(10);
        expect(maybe, isA<Extend>());
      });

      test('Filterable', () {
        final maybe = Maybe.of(10);
        expect(maybe, isA<Filterable>());
      });
    });

    test('map', () {
      final maybe = Maybe.of(10);
      final map = maybe.map((a) => a + 1);
      map.match((just) => expect(just, 11), () => null);
    });

    test('map2', () {
      final maybe = Maybe.of(10);
      final map =
          maybe.map2<String, int>(Maybe.of('abc'), (a, b) => a + b.length);
      map.match((just) => expect(just, 13), () => null);
    });

    test('map3', () {
      final maybe = Maybe.of(10);
      final map = maybe.map3<String, double, double>(
          Maybe.of('abc'), Maybe.of(2.0), (a, b, c) => (a + b.length) / c);
      map.match((just) => expect(just, 6.5), () => null);
    });

    test('foldRight', () {
      final maybe = Maybe.of(10);
      final foldRight = maybe.foldRight<int>(1, (a, b) => a + b);
      expect(foldRight, 11);
    });

    test('fold', () {
      final maybe = Maybe.of(10);
      final fold = maybe.fold<int>(1, (a, b) => a + b);
      expect(fold, 11);
    });

    test('foldMap', () {
      final maybe = Maybe.of(10);
      final foldMap =
          maybe.foldMap<int>(Monoid.instance(0, (a1, a2) => a1 + a2), (a) => a);
      expect(foldMap, 10);
    });

    group('ap', () {
      test('Just', () {
        final maybe = Maybe.of(10);
        final pure = maybe.ap(Maybe.of((int i) => i + 1));
        pure.match((just) => expect(just, 11), () => null);
      });

      test('Just (curried)', () {
        final ap = Maybe.of((int a) => (int b) => a + b)
            .ap(
              Maybe.of((f) => f(3)),
            )
            .ap(
              Maybe.of((f) => f(5)),
            );
        ap.match((just) => expect(just, 8), () => null);
      });

      test('Nothing', () {
        final maybe = Maybe<int>.nothing();
        final pure = maybe.ap(Maybe.of((int i) => i + 1));
        expect(pure, isA<Nothing>());
      });
    });

    group('flatMap', () {
      test('Just', () {
        final maybe = Maybe.of(10);
        final flatMap = maybe.flatMap<int>((a) => Maybe.of(a + 1));
        flatMap.match((just) => expect(just, 11), () => null);
      });

      test('Nothing', () {
        final maybe = Maybe<int>.nothing();
        final flatMap = maybe.flatMap<int>((a) => Maybe.of(a + 1));
        expect(flatMap, isA<Nothing>());
      });
    });

    group('getOrElse', () {
      test('Just', () {
        final maybe = Maybe.of(10);
        final value = maybe.getOrElse(() => 0);
        expect(value, 10);
      });

      test('Nothing', () {
        final maybe = Maybe<int>.nothing();
        final value = maybe.getOrElse(() => 0);
        expect(value, 0);
      });
    });

    group('alt', () {
      test('Just', () {
        final maybe = Maybe.of(10);
        final value = maybe.alt(() => Maybe.of(0));
        value.match((just) => expect(just, 10), () => null);
      });

      test('Nothing', () {
        final maybe = Maybe<int>.nothing();
        final value = maybe.alt(() => Maybe.of(0));
        value.match((just) => expect(just, 0), () => null);
      });
    });

    group('extend', () {
      test('Just', () {
        final maybe = Maybe.of(10);
        final value = maybe.extend((t) => t.isJust() ? 'valid' : 'invalid');
        value.match((just) => expect(just, 'valid'), () => null);
      });

      test('Nothing', () {
        final maybe = Maybe<int>.nothing();
        final value = maybe.extend((t) => t.isJust() ? 'valid' : 'invalid');
        value.match((just) => expect(just, 'invalid'), () => null);
      });
    });

    group('duplicate', () {
      test('Just', () {
        final maybe = Maybe.of(10);
        final value = maybe.duplicate();
        value.match((just) => expect(just, isA<Just>()), () => null);
      });

      test('Nothing', () {
        final maybe = Maybe<int>.nothing();
        final value = maybe.duplicate();
        expect(value, isA<Nothing>());
      });
    });

    group('filter', () {
      test('Just (true)', () {
        final maybe = Maybe.of(10);
        final value = maybe.filter((a) => a > 5);
        value.match((just) => expect(just, 10), () => null);
      });

      test('Just (false)', () {
        final maybe = Maybe.of(10);
        final value = maybe.filter((a) => a < 5);
        expect(value, isA<Nothing>());
      });

      test('Nothing', () {
        final maybe = Maybe<int>.nothing();
        final value = maybe.filter((a) => a > 5);
        expect(value, isA<Nothing>());
      });
    });

    group('filterMap', () {
      test('Just', () {
        final maybe = Maybe.of(10);
        final value = maybe.filterMap<String>((a) => Maybe.of('$a'));
        value.match((just) => expect(just, '10'), () => null);
      });

      test('Nothing', () {
        final maybe = Maybe<int>.nothing();
        final value = maybe.filterMap<String>((a) => Maybe.of('$a'));
        expect(value, isA<Nothing>());
      });
    });

    group('partition', () {
      test('Just (true)', () {
        final maybe = Maybe.of(10);
        final value = maybe.partition((a) => a > 5);
        expect(value.value1, isA<Nothing>());
        value.value2.match((just) => expect(just, 10), () => null);
      });

      test('Just (false)', () {
        final maybe = Maybe.of(10);
        final value = maybe.partition((a) => a < 5);
        value.value1.match((just) => expect(just, 10), () => null);
        expect(value.value2, isA<Nothing>());
      });

      test('Nothing', () {
        final maybe = Maybe<int>.nothing();
        final value = maybe.partition((a) => a > 5);
        expect(value.value1, isA<Nothing>());
        expect(value.value2, isA<Nothing>());
      });
    });

    group('partitionMap', () {
      test('Just (right)', () {
        final maybe = Maybe.of(10);
        final value =
            maybe.partitionMap<String, double>((a) => Either.of(a / 2));
        expect(value.value1, isA<Nothing>());
        value.value2.match((just) => expect(just, 5.0), () => null);
      });

      test('Just (left)', () {
        final maybe = Maybe.of(10);
        final value =
            maybe.partitionMap<String, double>((a) => Either.left('$a'));
        value.value1.match((just) => expect(just, '10'), () => null);
        expect(value.value2, isA<Nothing>());
      });

      test('Nothing', () {
        final maybe = Maybe<int>.nothing();
        final value =
            maybe.partitionMap<String, double>((a) => Either.of(a / 2));
        expect(value.value1, isA<Nothing>());
        expect(value.value2, isA<Nothing>());
      });
    });

    group('fromEither', () {
      test('Right', () {
        final maybe = Maybe.fromEither<String, int>(Either.of(10));
        maybe.match((just) => expect(just, 10), () => null);
      });

      test('Left', () {
        final maybe = Maybe.fromEither<String, int>(Either.left('none'));
        expect(maybe, isA<Nothing>());
      });
    });

    group('fromPredicate', () {
      test('Just', () {
        final maybe = Maybe<int>.fromPredicate(10, (a) => a > 5);
        maybe.match((just) => expect(just, 10), () => null);
      });

      test('Nothing', () {
        final maybe = Maybe<int>.fromPredicate(10, (a) => a < 5);
        expect(maybe, isA<Nothing>());
      });
    });

    group('fromPredicateMap', () {
      test('Just', () {
        final maybe =
            Maybe.fromPredicateMap<int, String>(10, (a) => a > 5, (a) => '$a');
        maybe.match((just) => expect(just, '10'), () => null);
      });

      test('Nothing', () {
        final maybe =
            Maybe.fromPredicateMap<int, String>(10, (a) => a < 5, (a) => '$a');
        expect(maybe, isA<Nothing>());
      });
    });

    group('flatten', () {
      test('Right', () {
        final maybe = Maybe.flatten(Maybe.of(Maybe.of(10)));
        maybe.match((just) => expect(just, 10), () => null);
      });

      test('Left', () {
        final maybe = Maybe.flatten(Maybe.of(Maybe<int>.nothing()));
        expect(maybe, isA<Nothing>());
      });
    });

    group('separate', () {
      test('Right', () {
        final maybe = Maybe.separate<String, int>(Maybe.of(Either.of(10)));
        expect(maybe.value1, isA<Nothing>());
        maybe.value2.match((just) => expect(just, 10), () => null);
      });

      test('Left', () {
        final maybe =
            Maybe.separate<String, int>(Maybe.of(Either.left('none')));
        maybe.value1.match((just) => expect(just, 'none'), () => null);
        expect(maybe.value2, isA<Nothing>());
      });
    });

    test('nothing', () {
      final maybe = Maybe<int>.nothing();
      expect(maybe, isA<Nothing>());
    });

    test('of', () {
      final maybe = Maybe.of(10);
      maybe.match((just) => expect(just, 10), () => null);
    });

    test('iJust', () {
      final maybe = Maybe.of(10);
      expect(maybe.isJust(), true);
      expect(maybe.isNothing(), false);
    });

    test('isNothing', () {
      final maybe = Maybe<int>.nothing();
      expect(maybe.isNothing(), true);
      expect(maybe.isJust(), false);
    });

    test('getEq', () {
      final eq = Maybe.getEq<int>(Eq.instance((a1, a2) => a1 == a2));
      expect(eq.eqv(Maybe.of(10), Maybe.of(10)), true);
      expect(eq.eqv(Maybe.of(10), Maybe.of(9)), false);
      expect(eq.eqv(Maybe.of(10), Maybe<int>.nothing()), false);
      expect(eq.eqv(Maybe<int>.nothing(), Maybe<int>.nothing()), true);
    });

    test('getOrder', () {
      final order =
          Maybe.getOrder<int>(Order.from((a1, a2) => a1.compareTo(a2)));
      final maybe1 = Maybe.of(10);
      final maybe2 = Maybe.of(9);
      final maybe3 = Maybe<int>.nothing();
      expect(order.compare(maybe1, maybe1), 0);
      expect(order.compare(maybe3, maybe3), 0);
      expect(order.compare(maybe1, maybe2), 1);
      expect(order.compare(maybe2, maybe1), -1);
      expect(order.compare(maybe1, maybe3), 1);
      expect(order.compare(maybe3, maybe1), -1);
    });

    test('fromNullable', () {
      final m1 = Maybe<int>.fromNullable(10);
      final m2 = Maybe<int>.fromNullable(null);
      expect(m1, isA<Just>());
      expect(m2, isA<Nothing>());
    });

    test('tryCatch', () {
      final m1 = Maybe.tryCatch(() => 10);
      final m2 = Maybe.tryCatch(() => throw UnimplementedError());
      expect(m1, isA<Just>());
      expect(m2, isA<Nothing>());
    });

    test('toEither', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe<int>.nothing();
      final e1 = m1.toEither(() => 'left');
      final e2 = m2.toEither(() => 'left');
      e1.match((l) => null, (r) => expect(r, 10));
      e2.match((l) => expect(l, 'left'), (r) => null);
    });

    test('toNullable', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe<int>.nothing();
      expect(m1.toNullable(), 10);
      expect(m1.toNullable(), isA<int?>());
      expect(m2.toNullable(), null);
    });

    test('pure', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe<int>.nothing();
      m1.pure('abc').match((just) => expect(just, 'abc'), () => null);
      m2.pure('abc').match((just) => expect(just, 'abc'), () => null);
    });

    test('andThen', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe<int>.nothing();
      m1
          .andThen(() => Maybe.of('abc'))
          .match((just) => expect(just, 'abc'), () => null);
      expect(m2.andThen(() => Maybe.of('abc')), isA<Nothing>());
    });

    test('plus', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe<int>.nothing();
      m1.plus(Maybe.of(0)).match((just) => expect(just, 10), () => null);
      m2.plus(Maybe.of(0)).match((just) => expect(just, 0), () => null);
    });

    test('prepend', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe<int>.nothing();
      m1.prepend(0).match((just) => expect(just, 0), () => null);
      m2.prepend(0).match((just) => expect(just, 0), () => null);
    });

    test('append', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe<int>.nothing();
      m1.append(0).match((just) => expect(just, 10), () => null);
      m2.append(0).match((just) => expect(just, 0), () => null);
    });

    test('match', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe<int>.nothing();
      expect(m1.match((just) => 'just', () => 'none'), 'just');
      expect(m2.match((just) => 'just', () => 'none'), 'none');
    });

    test('elem', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe<int>.nothing();
      final eq = Eq.instance<int>((a1, a2) => a1 == a2);
      expect(m1.elem(10, eq), true);
      expect(m1.elem(9, eq), false);
      expect(m2.elem(10, eq), false);
    });

    test('nothing()', () {
      final m = Maybe<int>.nothing();
      expect(m, isA<Nothing<int>>());
    });

    test('of()', () {
      final m = Maybe.of(10);
      expect(m, isA<Just<int>>());
    });

    test('getFirstMonoid', () {
      final m = Maybe.getFirstMonoid<int>();
      expect(m.empty, isA<Nothing<int>>());
      m
          .combine(Maybe.of(10), Maybe.of(0))
          .match((just) => expect(just, 10), () => null);
      m
          .combine(Maybe.nothing(), Maybe.of(0))
          .match((just) => expect(just, 0), () => null);
    });

    test('getLastMonoid', () {
      final m = Maybe.getLastMonoid<int>();
      expect(m.empty, isA<Nothing<int>>());
      m
          .combine(Maybe.of(10), Maybe.of(0))
          .match((just) => expect(just, 0), () => null);
      m
          .combine(Maybe.of(10), Maybe.nothing())
          .match((just) => expect(just, 10), () => null);
    });

    test('getMonoid', () {
      final m = Maybe.getMonoid<int>(Semigroup.instance((a1, a2) => a1 + a2));
      expect(m.empty, isA<Nothing<int>>());
      m
          .combine(Maybe.of(10), Maybe.of(20))
          .match((just) => expect(just, 30), () => null);
      expect(m.combine(Maybe.of(10), Maybe.nothing()), isA<Nothing<int>>());
      expect(m.combine(Maybe.nothing(), Maybe.of(10)), isA<Nothing<int>>());
    });

    group('toString', () {
      test('Just', () {
        final m = Maybe.of(10);
        expect(m.toString(), 'Just(10)');
      });

      test('Nothing', () {
        final m = Maybe<int>.nothing();
        expect(m.toString(), 'Nothing');
      });
    });

    test('Just value', () {
      const m = Just(10);
      expect(m.value, 10);
    });

    test('Just == Just', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe.of(9);
      final m3 = Maybe<int>.nothing();
      final m4 = Maybe.of(10);
      final map1 = <String, Maybe>{'m1': m1, 'm2': m4};
      final map2 = <String, Maybe>{'m1': m1, 'm2': m2};
      final map3 = <String, Maybe>{'m1': m1, 'm2': m4};
      expect(m1, m1);
      expect(m2, m2);
      expect(m1, m4);
      expect(m1 == m2, false);
      expect(m4 == m2, false);
      expect(m1 == m3, false);
      expect(m2 == m3, false);
      expect(map1, map1);
      expect(map1, map3);
      expect(map1 == map2, false);
    });

    test('Nothing == Nothing', () {
      final m1 = Maybe.of(10);
      final m2 = Maybe.of(9);
      final m3 = Maybe<int>.nothing();
      final m4 = Maybe<int>.nothing();
      final m5 = Maybe<String>.nothing();
      final map1 = <String, Maybe>{'m1': m3, 'm2': m3};
      final map2 = <String, Maybe>{'m1': m3, 'm2': m4};
      final map3 = <String, Maybe>{'m1': m3, 'm2': m5};
      final map4 = <String, Maybe>{'m1': m3, 'm2': m1};
      expect(m3, m3);
      expect(m3, m4);
      expect(m5, m5);
      expect(m3 == m5, true);
      expect(m1 == m3, false);
      expect(m2 == m3, false);
      expect(map1, map1);
      expect(map1, map2);
      expect(map1, map3);
      expect(map1 == map4, false);
    });
  });
}
