import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Option', () {
    group('is a', () {
      final option = Option.of(10);

      test('Monad', () {
        expect(option, isA<Monad>());
      });

      test('Applicative', () {
        expect(option, isA<Applicative>());
      });

      test('Foldable', () {
        expect(option, isA<Foldable>());
      });

      test('Alt', () {
        expect(option, isA<Alt>());
      });

      test('Extend', () {
        expect(option, isA<Extend>());
      });

      test('Filterable', () {
        expect(option, isA<Filterable>());
      });
    });

    test('map', () {
      final option = Option.of(10);
      final map = option.map((a) => a + 1);
      map.match((some) => expect(some, 11), () => null);
    });

    test('map2', () {
      final option = Option.of(10);
      final map =
          option.map2<String, int>(Option.of('abc'), (a, b) => a + b.length);
      map.match((some) => expect(some, 13), () => null);
    });

    test('map3', () {
      final option = Option.of(10);
      final map = option.map3<String, double, double>(
          Option.of('abc'), Option.of(2.0), (a, b, c) => (a + b.length) / c);
      map.match((some) => expect(some, 6.5), () => null);
    });

    test('foldRight', () {
      final option = Option.of(10);
      final foldRight = option.foldRight<int>(1, (a, b) => a + b);
      expect(foldRight, 11);
    });

    test('foldLeft', () {
      final option = Option.of(10);
      final fold = option.foldLeft<int>(1, (a, b) => a + b);
      expect(fold, 11);
    });

    test('foldRightWithIndex', () {
      final option = Option.of(10);
      final foldRight = option.foldRightWithIndex<int>(1, (i, a, b) => a + b);
      expect(foldRight, 11);
    });

    test('foldLeftWithIndex', () {
      final option = Option.of(10);
      final fold = option.foldLeftWithIndex<int>(1, (i, a, b) => a + b);
      expect(fold, 11);
    });

    test('foldMap', () {
      final option = Option.of(10);
      final foldMap = option.foldMap<int>(
          Monoid.instance(0, (a1, a2) => a1 + a2), (a) => a);
      expect(foldMap, 10);
    });

    group('ap', () {
      test('Some', () {
        final option = Option.of(10);
        final pure = option.ap(Option.of((int i) => i + 1));
        pure.match((some) => expect(some, 11), () => null);
      });

      test('Some (curried)', () {
        final ap = Option.of((int a) => (int b) => a + b)
            .ap(
              Option.of((f) => f(3)),
            )
            .ap(
              Option.of((f) => f(5)),
            );
        ap.match((some) => expect(some, 8), () => null);
      });

      test('None', () {
        final option = Option<int>.none();
        final pure = option.ap(Option.of((int i) => i + 1));
        expect(pure, isA<None>());
      });
    });

    group('flatMap', () {
      test('Some', () {
        final option = Option.of(10);
        final flatMap = option.flatMap<int>((a) => Option.of(a + 1));
        flatMap.match((some) => expect(some, 11), () => null);
      });

      test('None', () {
        final option = Option<int>.none();
        final flatMap = option.flatMap<int>((a) => Option.of(a + 1));
        expect(flatMap, isA<None>());
      });
    });

    group('getOrElse', () {
      test('Some', () {
        final option = Option.of(10);
        final value = option.getOrElse(() => 0);
        expect(value, 10);
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.getOrElse(() => 0);
        expect(value, 0);
      });
    });

    group('alt', () {
      test('Some', () {
        final option = Option.of(10);
        final value = option.alt(() => Option.of(0));
        value.match((some) => expect(some, 10), () => null);
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.alt(() => Option.of(0));
        value.match((some) => expect(some, 0), () => null);
      });
    });

    group('extend', () {
      test('Some', () {
        final option = Option.of(10);
        final value = option.extend((t) => t.isSome() ? 'valid' : 'invalid');
        value.match((some) => expect(some, 'valid'), () => null);
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.extend((t) => t.isSome() ? 'valid' : 'invalid');
        value.match((some) => expect(some, 'invalid'), () => null);
      });
    });

    group('duplicate', () {
      test('Some', () {
        final option = Option.of(10);
        final value = option.duplicate();
        value.match((some) => expect(some, isA<Some>()), () => null);
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.duplicate();
        expect(value, isA<None>());
      });
    });

    group('filter', () {
      test('Some (true)', () {
        final option = Option.of(10);
        final value = option.filter((a) => a > 5);
        value.match((some) => expect(some, 10), () => null);
      });

      test('Some (false)', () {
        final option = Option.of(10);
        final value = option.filter((a) => a < 5);
        expect(value, isA<None>());
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.filter((a) => a > 5);
        expect(value, isA<None>());
      });
    });

    group('filterMap', () {
      test('Some', () {
        final option = Option.of(10);
        final value = option.filterMap<String>((a) => Option.of('$a'));
        value.match((some) => expect(some, '10'), () => null);
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.filterMap<String>((a) => Option.of('$a'));
        expect(value, isA<None>());
      });
    });

    group('partition', () {
      test('Some (true)', () {
        final option = Option.of(10);
        final value = option.partition((a) => a > 5);
        expect(value.first, isA<None>());
        value.second.match((some) => expect(some, 10), () => null);
      });

      test('Some (false)', () {
        final option = Option.of(10);
        final value = option.partition((a) => a < 5);
        value.first.match((some) => expect(some, 10), () => null);
        expect(value.second, isA<None>());
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.partition((a) => a > 5);
        expect(value.first, isA<None>());
        expect(value.second, isA<None>());
      });
    });

    group('partitionMap', () {
      test('Some (right)', () {
        final option = Option.of(10);
        final value =
            option.partitionMap<String, double>((a) => Either.of(a / 2));
        expect(value.first, isA<None>());
        value.second.match((some) => expect(some, 5.0), () => null);
      });

      test('Some (left)', () {
        final option = Option.of(10);
        final value =
            option.partitionMap<String, double>((a) => Either.left('$a'));
        value.first.match((some) => expect(some, '10'), () => null);
        expect(value.second, isA<None>());
      });

      test('None', () {
        final option = Option<int>.none();
        final value =
            option.partitionMap<String, double>((a) => Either.of(a / 2));
        expect(value.first, isA<None>());
        expect(value.second, isA<None>());
      });
    });

    group('fromEither', () {
      test('Right', () {
        final option = Option.fromEither<String, int>(Either.of(10));
        option.match((some) => expect(some, 10), () => null);
      });

      test('Left', () {
        final option = Option.fromEither<String, int>(Either.left('none'));
        expect(option, isA<None>());
      });
    });

    group('fromPredicate', () {
      test('Some', () {
        final option = Option<int>.fromPredicate(10, (a) => a > 5);
        option.match((some) => expect(some, 10), () => null);
      });

      test('None', () {
        final option = Option<int>.fromPredicate(10, (a) => a < 5);
        expect(option, isA<None>());
      });
    });

    group('fromPredicateMap', () {
      test('Some', () {
        final option =
            Option.fromPredicateMap<int, String>(10, (a) => a > 5, (a) => '$a');
        option.match((some) => expect(some, '10'), () => null);
      });

      test('None', () {
        final option =
            Option.fromPredicateMap<int, String>(10, (a) => a < 5, (a) => '$a');
        expect(option, isA<None>());
      });
    });

    group('flatten', () {
      test('Right', () {
        final option = Option.flatten(Option.of(Option.of(10)));
        option.match((some) => expect(some, 10), () => null);
      });

      test('Left', () {
        final option = Option.flatten(Option.of(Option<int>.none()));
        expect(option, isA<None>());
      });
    });

    group('separate', () {
      test('Right', () {
        final option = Option.separate<String, int>(Option.of(Either.of(10)));
        expect(option.first, isA<None>());
        option.second.match((some) => expect(some, 10), () => null);
      });

      test('Left', () {
        final option =
            Option.separate<String, int>(Option.of(Either.left('none')));
        option.first.match((some) => expect(some, 'none'), () => null);
        expect(option.second, isA<None>());
      });
    });

    test('None', () {
      final option = Option<int>.none();
      expect(option, isA<None>());
    });

    test('of', () {
      final option = Option.of(10);
      option.match((some) => expect(some, 10), () => null);
    });

    test('isSome', () {
      final option = Option.of(10);
      expect(option.isSome(), true);
      expect(option.isNone(), false);
    });

    test('isNone', () {
      final option = Option<int>.none();
      expect(option.isNone(), true);
      expect(option.isSome(), false);
    });

    test('getEq', () {
      final eq = Option.getEq<int>(Eq.instance((a1, a2) => a1 == a2));
      expect(eq.eqv(Option.of(10), Option.of(10)), true);
      expect(eq.eqv(Option.of(10), Option.of(9)), false);
      expect(eq.eqv(Option.of(10), Option<int>.none()), false);
      expect(eq.eqv(Option<int>.none(), Option<int>.none()), true);
    });

    test('getOrder', () {
      final order =
          Option.getOrder<int>(Order.from((a1, a2) => a1.compareTo(a2)));
      final option1 = Option.of(10);
      final option2 = Option.of(9);
      final option3 = Option<int>.none();
      expect(order.compare(option1, option1), 0);
      expect(order.compare(option3, option3), 0);
      expect(order.compare(option1, option2), 1);
      expect(order.compare(option2, option1), -1);
      expect(order.compare(option1, option3), 1);
      expect(order.compare(option3, option1), -1);
    });

    test('fromNullable', () {
      final m1 = Option<int>.fromNullable(10);
      final m2 = Option<int>.fromNullable(null);
      expect(m1, isA<Some>());
      expect(m2, isA<None>());
    });

    test('tryCatch', () {
      final m1 = Option.tryCatch(() => 10);
      final m2 = Option.tryCatch(() => throw UnimplementedError());
      expect(m1, isA<Some>());
      expect(m2, isA<None>());
    });

    test('toEither', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      final e1 = m1.toEither(() => 'left');
      final e2 = m2.toEither(() => 'left');
      e1.match((l) => null, (r) => expect(r, 10));
      e2.match((l) => expect(l, 'left'), (r) => null);
    });

    test('toNullable', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      expect(m1.toNullable(), 10);
      expect(m1.toNullable(), isA<int?>());
      expect(m2.toNullable(), null);
    });

    test('pure', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      m1.pure('abc').match((some) => expect(some, 'abc'), () => null);
      m2.pure('abc').match((some) => expect(some, 'abc'), () => null);
    });

    test('length', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      expect(m1.length(), 1);
      expect(m2.length(), 0);
    });

    group('any', () {
      test('Some (true)', () {
        final m1 = Option.of(10);
        final ap = m1.any((a) => a > 5);
        expect(ap, true);
      });

      test('Some (false)', () {
        final m1 = Option.of(10);
        final ap = m1.any((a) => a < 5);
        expect(ap, false);
      });

      test('None', () {
        final m1 = Option<int>.none();
        final ap = m1.any((a) => a > 5);
        expect(ap, false);
      });
    });

    group('all', () {
      test('Some (true)', () {
        final m1 = Option.of(10);
        final ap = m1.all((a) => a > 5);
        expect(ap, true);
      });

      test('Some (false)', () {
        final m1 = Option.of(10);
        final ap = m1.all((a) => a < 5);
        expect(ap, false);
      });

      test('None', () {
        final m1 = Option<int>.none();
        final ap = m1.all((a) => a > 5);
        expect(ap, true);
      });
    });

    test('concatenate', () {
      final m1 = Option.of(10);
      final ap = m1.concatenate(Monoid.instance(0, (a1, a2) => a1 + a2));
      expect(ap, 10);
    });

    test('andThen', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      m1
          .andThen(() => Option.of('abc'))
          .match((some) => expect(some, 'abc'), () => null);
      expect(m2.andThen(() => Option.of('abc')), isA<None>());
    });

    test('plus', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      m1.plus(Option.of(0)).match((some) => expect(some, 10), () => null);
      m2.plus(Option.of(0)).match((some) => expect(some, 0), () => null);
    });

    test('prepend', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      m1.prepend(0).match((some) => expect(some, 0), () => null);
      m2.prepend(0).match((some) => expect(some, 0), () => null);
    });

    test('append', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      m1.append(0).match((some) => expect(some, 10), () => null);
      m2.append(0).match((some) => expect(some, 0), () => null);
    });

    test('match', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      expect(m1.match((some) => 'some', () => 'none'), 'some');
      expect(m2.match((some) => 'some', () => 'none'), 'none');
    });

    test('elem', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      final eq = Eq.instance<int>((a1, a2) => a1 == a2);
      expect(m1.elem(10, eq), true);
      expect(m1.elem(9, eq), false);
      expect(m2.elem(10, eq), false);
    });

    test('none()', () {
      final m = Option<int>.none();
      expect(m, isA<None<int>>());
    });

    test('of()', () {
      final m = Option.of(10);
      expect(m, isA<Some<int>>());
    });

    test('getFirstMonoid', () {
      final m = Option.getFirstMonoid<int>();
      expect(m.empty, isA<None<int>>());
      m
          .combine(Option.of(10), Option.of(0))
          .match((some) => expect(some, 10), () => null);
      m
          .combine(Option.none(), Option.of(0))
          .match((some) => expect(some, 0), () => null);
    });

    test('getLastMonoid', () {
      final m = Option.getLastMonoid<int>();
      expect(m.empty, isA<None<int>>());
      m
          .combine(Option.of(10), Option.of(0))
          .match((some) => expect(some, 0), () => null);
      m
          .combine(Option.of(10), Option.none())
          .match((some) => expect(some, 10), () => null);
    });

    test('getMonoid', () {
      final m = Option.getMonoid<int>(Semigroup.instance((a1, a2) => a1 + a2));
      expect(m.empty, isA<None<int>>());
      m
          .combine(Option.of(10), Option.of(20))
          .match((some) => expect(some, 30), () => null);
      expect(m.combine(Option.of(10), Option.none()), isA<None<int>>());
      expect(m.combine(Option.none(), Option.of(10)), isA<None<int>>());
    });

    group('toString', () {
      test('Some', () {
        final m = Option.of(10);
        expect(m.toString(), 'Some(10)');
      });

      test('None', () {
        final m = Option<int>.none();
        expect(m.toString(), 'None');
      });
    });

    test('Some value', () {
      const m = Some(10);
      expect(m.value, 10);
    });

    test('Some == Some', () {
      final m1 = Option.of(10);
      final m2 = Option.of(9);
      final m3 = Option<int>.none();
      final m4 = Option.of(10);
      final map1 = <String, Option>{'m1': m1, 'm2': m4};
      final map2 = <String, Option>{'m1': m1, 'm2': m2};
      final map3 = <String, Option>{'m1': m1, 'm2': m4};
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

    test('None == None', () {
      final m1 = Option.of(10);
      final m2 = Option.of(9);
      final m3 = Option<int>.none();
      final m4 = Option<int>.none();
      final m5 = Option<String>.none();
      final map1 = <String, Option>{'m1': m3, 'm2': m3};
      final map2 = <String, Option>{'m1': m3, 'm2': m4};
      final map3 = <String, Option>{'m1': m3, 'm2': m5};
      final map4 = <String, Option>{'m1': m3, 'm2': m1};
      expect(m3, m3);
      expect(m3, m4);
      expect(m5, m5);
      expect(m3, m5);
      expect(m1 == m3, false);
      expect(m2 == m3, false);
      expect(map1, map1);
      expect(map1, map2);
      expect(map1, map3);
      expect(map1 == map4, false);
    });
  });
}
