import 'package:fpdart/fpdart.dart';

import './utils/utils.dart';

void main() {
  group('Option', () {
    group('[Property-based testing]', () {
      group("safeCast", () {
        Glados2(any.int, any.letterOrDigits)
            .test('always returns Some without typed parameter',
                (intValue, stringValue) {
          final castInt = Option.safeCast(intValue);
          final castString = Option.safeCast(stringValue);
          expect(castInt, isA<Some<dynamic>>());
          expect(castString, isA<Some<dynamic>>());
        });
      });

      group('map', () {
        Glados(any.optionInt).test('should keep the same type (Some or None)',
            (option) {
          final r = option.map(constF);
          expect(option.isSome(), r.isSome());
          expect(option.isNone(), r.isNone());
        });

        Glados2(any.optionInt, any.int)
            .test('should updated the value inside Some, or stay None',
                (option, value) {
          final r = option.map((n) => n + value);
          option.match(
            () {
              expect(option, r);
            },
            (val1) {
              r.matchTestSome((val2) {
                expect(val2, val1 + value);
              });
            },
          );
        });
      });

      group('traverseList', () {
        Glados(any.list(any.int)).test(
            'should keep the same structure and content of the original list',
            (input) {
          final result = Option.traverseList(input, Option<int>.of);
          result.matchTestSome((t) {
            expect(t, input);
          });
        });
      });
    });

    group('is a', () {
      final option = Option.of(10);

      test('Monad', () {
        expect(option, isA<Monad>());
      });

      test('Applicative', () {
        expect(option, isA<Applicative>());
      });

      test('Functor', () {
        expect(option, isA<Functor>());
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
      map.matchTestSome((some) => expect(some, 11));
    });

    test('map2', () {
      final option = Option.of(10);
      final map =
          option.map2<String, int>(Option.of('abc'), (a, b) => a + b.length);
      map.matchTestSome((some) => expect(some, 13));
    });

    test('map3', () {
      final option = Option.of(10);
      final map = option.map3<String, double, double>(
          Option.of('abc'), Option.of(2.0), (a, b, c) => (a + b.length) / c);
      map.matchTestSome((some) => expect(some, 6.5));
    });

    group('ap', () {
      test('Some', () {
        final option = Option.of(10);
        final pure = option.ap(Option.of((int i) => i + 1));
        pure.matchTestSome((some) => expect(some, 11));
      });

      test('Some (curried)', () {
        final ap = Option.of((int a) => (int b) => a + b)
            .ap(
              Option.of((f) => f(3)),
            )
            .ap(
              Option.of((f) => f(5)),
            );
        ap.matchTestSome((some) => expect(some, 8));
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
        flatMap.matchTestSome((some) => expect(some, 11));
      });

      test('None', () {
        final option = Option<int>.none();
        final flatMap = option.flatMap<int>((a) => Option.of(a + 1));
        expect(flatMap, isA<None>());
      });
    });

    group('flatMapNullable', () {
      test('not null', () {
        final option = Option.of(10);
        final flatMap = option.flatMapNullable((a) => a + 1);
        flatMap.matchTestSome((some) => expect(some, 11));
      });

      test('null', () {
        final option = Option.of(10);
        final flatMap = option.flatMapNullable<int>((a) => null);
        expect(flatMap, isA<None>());
      });
    });

    group('flatMapThrowable', () {
      test('happy path', () {
        final option = Option.of(10);
        final flatMap = option.flatMapThrowable((a) => a + 1);
        flatMap.matchTestSome((some) => expect(some, 11));
      });

      test('throws', () {
        final option = Option.of(10);
        final flatMap = option.flatMapThrowable<int>((a) => throw "fail");
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
        value.matchTestSome((some) => expect(some, 10));
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.alt(() => Option.of(0));
        value.matchTestSome((some) => expect(some, 0));
      });
    });

    group('extend', () {
      test('Some', () {
        final option = Option.of(10);
        final value = option.extend((t) => t.isSome() ? 'valid' : 'invalid');
        value.matchTestSome((some) => expect(some, 'valid'));
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.extend((t) => t.isSome() ? 'valid' : 'invalid');
        expect(value, isA<None>());
      });
    });

    group('duplicate', () {
      test('Some', () {
        final option = Option.of(10);
        final value = option.duplicate();
        value.matchTestSome((some) => expect(some, isA<Some>()));
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
        value.matchTestSome((some) => expect(some, 10));
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
        value.matchTestSome((some) => expect(some, '10'));
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
        value.second.matchTestSome((some) => expect(some, 10));
      });

      test('Some (false)', () {
        final option = Option.of(10);
        final value = option.partition((a) => a < 5);
        value.first.matchTestSome((some) => expect(some, 10));
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
        value.second.matchTestSome((some) => expect(some, 5.0));
      });

      test('Some (left)', () {
        final option = Option.of(10);
        final value =
            option.partitionMap<String, double>((a) => Either.left('$a'));
        value.first.matchTestSome((some) => expect(some, '10'));
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
        option.matchTestSome((some) => expect(some, 10));
      });

      test('Left', () {
        final option = Option.fromEither<String, int>(Either.left('none'));
        expect(option, isA<None>());
      });
    });

    group('fromJson', () {
      test('int', () {
        final option = Option<int>.fromJson(10, (a) => a as int);
        option.matchTestSome((some) => expect(some, 10));
      });

      test('DateTime', () {
        final now = DateTime.now();
        final option = Option<DateTime>.fromJson(
            now.toIso8601String(), (a) => DateTime.parse(a as String));
        option.matchTestSome((some) => expect(some, now));
      });

      test('DateTime failure', () {
        final option = Option<DateTime>.fromJson(
            "fail", (a) => DateTime.parse(a as String));
        expect(option, isA<None>());
      });

      test('null', () {
        final option = Option<int>.fromJson(null, (a) => a as int);
        expect(option, isA<None>());
      });
    });

    group('fromPredicate', () {
      test('Some', () {
        final option = Option<int>.fromPredicate(10, (a) => a > 5);
        option.matchTestSome((some) => expect(some, 10));
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
        option.matchTestSome((some) => expect(some, '10'));
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
        option.matchTestSome((some) => expect(some, 10));
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
        option.second.matchTestSome((some) => expect(some, 10));
      });

      test('Left', () {
        final option =
            Option.separate<String, int>(Option.of(Either.left('none')));
        option.first.matchTestSome((some) => expect(some, 'none'));
        expect(option.second, isA<None>());
      });
    });

    test('None', () {
      final option = Option<int>.none();
      expect(option, isA<None>());
    });

    test('of', () {
      final option = Option.of(10);
      option.matchTestSome((some) => expect(some, 10));
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
      e1.match((_) {
        fail('should be right');
      }, (r) => expect(r, 10));
      e2.match((l) => expect(l, 'left'), (_) {
        fail('should be left');
      });
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
      m1.pure('abc').matchTestSome((some) => expect(some, 'abc'));
      m2.pure('abc').matchTestSome((some) => expect(some, 'abc'));
    });

    test('andThen', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      m1
          .andThen(() => Option.of('abc'))
          .matchTestSome((some) => expect(some, 'abc'));
      expect(m2.andThen(() => Option.of('abc')), isA<None>());
    });

    test('call', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      m1(Option.of('abc')).matchTestSome((some) => expect(some, 'abc'));
      expect(m2(Option.of('abc')), isA<None>());
    });

    test('match', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      expect(m1.match(() => 'none', (some) => 'some'), 'some');
      expect(m2.match(() => 'none', (some) => 'some'), 'none');
    });

    test('match', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      expect(m1.fold(() => 'none', (some) => 'some'), 'some');
      expect(m2.fold(() => 'none', (some) => 'some'), 'none');
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
      expect(m, isA<None>());
    });

    test('of()', () {
      final m = Option.of(10);
      expect(m, isA<Some<int>>());
    });

    test('getFirstMonoid', () {
      final m = Option.getFirstMonoid<int>();
      expect(m.empty, isA<None>());
      m
          .combine(Option.of(10), Option.of(0))
          .matchTestSome((some) => expect(some, 10));
      m
          .combine(Option.none(), Option.of(0))
          .matchTestSome((some) => expect(some, 0));
    });

    test('getLastMonoid', () {
      final m = Option.getLastMonoid<int>();
      expect(m.empty, isA<None>());
      m
          .combine(Option.of(10), Option.of(0))
          .matchTestSome((some) => expect(some, 0));
      m
          .combine(Option.of(10), Option.none())
          .matchTestSome((some) => expect(some, 10));
    });

    test('getMonoid', () {
      final m = Option.getMonoid<int>(Semigroup.instance((a1, a2) => a1 + a2));
      expect(m.empty, isA<None>());
      m
          .combine(Option.of(10), Option.of(20))
          .matchTestSome((some) => expect(some, 30));
      expect(m.combine(Option.of(10), Option.none()), isA<None>());
      expect(m.combine(Option.none(), Option.of(10)), isA<None>());
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

    group('sequenceList', () {
      test('Some', () {
        final list = [some(1), some(2), some(3), some(4)];
        final result = Option.sequenceList(list);
        result.matchTestSome((t) {
          expect(t, [1, 2, 3, 4]);
        });
      });

      test('None', () {
        final list = [some(1), none<int>(), some(3), some(4)];
        final result = Option.sequenceList(list);
        expect(result, isA<None>());
      });
    });

    group('traverseList', () {
      test('Some', () {
        final list = [1, 2, 3, 4, 5, 6];
        final result =
            Option.traverseList<int, String>(list, (a) => some("$a"));
        result.matchTestSome((t) {
          expect(t, ["1", "2", "3", "4", "5", "6"]);
        });
      });

      test('None', () {
        final list = [1, 2, 3, 4, 5, 6];
        final result = Option.traverseList<int, String>(
          list,
          (a) => a % 2 == 0 ? some("$a") : none(),
        );
        expect(result, isA<None>());
      });
    });

    group('traverseListWithIndex', () {
      test('Some', () {
        final list = [1, 2, 3, 4, 5, 6];
        final result = Option.traverseListWithIndex<int, String>(
            list, (a, i) => some("$a$i"));
        result.matchTestSome((t) {
          expect(t, ["10", "21", "32", "43", "54", "65"]);
        });
      });

      test('None', () {
        final list = [1, 2, 3, 4, 5, 6];
        final result = Option.traverseListWithIndex<int, String>(
          list,
          (a, i) => i % 2 == 0 ? some("$a$i") : none(),
        );
        expect(result, isA<None>());
      });
    });

    group('toTaskOption', () {
      test('Some', () async {
        final m = Option.of(10);
        final taskOption = m.toTaskOption();
        final result = await taskOption.run();
        expect(result, m);
      });

      test('None', () async {
        final m = Option<int>.none();
        final taskOption = m.toTaskOption();
        final result = await taskOption.run();
        expect(result, m);
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

  group('safeCast', () {
    test('dynamic', () {
      final castInt = Option.safeCast(10);
      final castString = Option.safeCast('abc');
      expect(castInt, isA<Some<dynamic>>());
      expect(castString, isA<Some<dynamic>>());
    });

    test('Some', () {
      final cast = Option<int>.safeCast(10);
      cast.matchTestSome((r) {
        expect(r, 10);
      });
    });

    test('None', () {
      final cast = Option<int>.safeCast('abc');
      expect(cast, isA<None>());
    });
  });

  group('safeCastStrict', () {
    test('Some', () {
      final cast = Option.safeCastStrict<int, int>(10);
      cast.matchTestSome((r) {
        expect(r, 10);
      });
    });

    test('None', () {
      final cast = Option.safeCastStrict<int, String>('abc');
      expect(cast, isA<None>());
    });
  });
}
