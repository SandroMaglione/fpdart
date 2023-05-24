import 'package:fpdart/fpdart.dart';

import '../utils/utils.dart';

void main() {
  group('FpdartOnMutableMap', () {
    test('mapValue', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.mapValue((value) => '${value * 2}'),
          {'a': '2', 'b': '4', 'c': '6', 'd': '8'},
        );
      });
    });

    test('mapWithIndex', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.mapWithIndex((value, index) => '${value + index}'),
          {'a': '1', 'b': '3', 'c': '5', 'd': '7'},
        );
      });
    });

    test('filter', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.filter((t) => t > 2),
          {'c': 3, 'd': 4},
        );
      });
    });

    test('filterWithIndex', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.filterWithIndex((t, i) => t > 2 && i != 3),
          {'c': 3},
        );
      });
    });

    test('filterWithKey', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.filterWithKey((k, v) => v > 2 && k != 'd'),
          {'c': 3},
        );
      });
    });

    test('filterWithKeyAndIndex', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.filterWithKeyAndIndex((k, v, i) => v > 1 && i != 1 && k != 'd'),
          {'c': 3},
        );
      });
    });

    group('lookup', () {
      test('Some', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          value.lookup('b').matchTestSome((t) {
            expect(t, 2);
          });
        });
      });

      test('None', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          expect(value.lookup('e'), isA<None>());
        });
      });
    });

    group('lookupEq', () {
      test('Some', () {
        testImmutableMap({
          DateTime(2000, 1, 1): 1,
          DateTime(2001, 1, 1): 2,
        }, (value) {
          value.lookupEq(dateEqYear, DateTime(2000, 10, 10)).matchTestSome((t) {
            expect(t, 1);
          });
        });
      });

      test('None', () {
        testImmutableMap({
          DateTime(2000, 1, 1): 1,
          DateTime(2001, 1, 1): 2,
        }, (value) {
          expect(value.lookupEq(dateEqYear, DateTime(2002, 1, 1)), isA<None>());
        });
      });
    });

    group('lookupWithKeyEq', () {
      test('Some', () {
        testImmutableMap({
          DateTime(2000, 1, 1): 1,
          DateTime(2001, 1, 1): 2,
        }, (value) {
          value
              .lookupWithKeyEq(
            dateEqYear,
            DateTime(2000, 10, 10),
          )
              .matchTestSome((t) {
            expect(t, (DateTime(2000, 1, 1), 1));
          });
        });
      });

      test('None', () {
        testImmutableMap({
          DateTime(2000, 1, 1): 1,
          DateTime(2001, 1, 1): 2,
        }, (value) {
          expect(
            value.lookupWithKeyEq(dateEqYear, DateTime(2002, 1, 1)),
            isA<None>(),
          );
        });
      });
    });

    group('lookupWithKey', () {
      test('Some', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          value.lookupWithKey('b').matchTestSome((t) {
            expect(t.$1, 'b');
            expect(t.$2, 2);
          });
        });
      });

      test('None', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          expect(value.lookupWithKey('e'), isA<None>());
        });
      });
    });

    group('extract', () {
      test('valid', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          value.extract<int>('b').matchTestSome((t) {
            expect(t, 2);
          });
        });
      });

      test('wrong type', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          expect(value.extract<String>('b'), isA<None>());
        });
      });
    });

    group('extractMap', () {
      test('no map', () {
        testImmutableMap({'a': 1}, (value) {
          expect(value.extractMap('a'), isA<None>());
        });
      });

      test('one level', () {
        testImmutableMap({
          'a': {'b': 2}
        }, (value) {
          expect(value.extractMap('a').toNullable(), equals({'b': 2}));
        });
      });

      test('two levels', () {
        testImmutableMap({
          'a': {
            'b': {'c': 3}
          }
        }, (value) {
          expect(value.extractMap('a').extractMap('b').toNullable(),
              equals({'c': 3}));
        });
      });

      test('two levels with extract', () {
        testImmutableMap({
          'a': {
            'b': {'c': 3}
          }
        }, (value) {
          value
              .extractMap('a')
              .extractMap('b')
              .extract<int>('c')
              .matchTestSome((t) {
            expect(t, 3);
          });
        });
      });
    });

    group('modifyAt', () {
      test('Some', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          value
              .modifyAt(
                Eq.instance((a1, a2) => a1 == a2),
                (v) => v + 2,
                'b',
              )
              .matchTestSome(
                (t) => t.lookup('b').matchTestSome((t) {
                  expect(t, 4);
                }),
              );
        });
      });

      test('None', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          expect(
            value.modifyAt(
              Eq.instance((a1, a2) => a1 == a2),
              (v) => v + 2,
              'e',
            ),
            isA<None>(),
          );
        });
      });
    });

    group('modifyAtIfPresent', () {
      test('found', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          value
              .modifyAtIfPresent(
                Eq.instance((a1, a2) => a1 == a2),
                (v) => v + 2,
                'b',
              )
              .lookup('b')
              .matchTestSome((t) {
            expect(t, 4);
          });
        });
      });

      test('not found', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          value
              .modifyAtIfPresent(
                Eq.instance((a1, a2) => a1 == a2),
                (v) => v + 2,
                'e',
              )
              .lookup('b')
              .matchTestSome((t) {
            expect(t, 2);
          });
        });
      });
    });

    group('updateAt', () {
      test('Some', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          value.updateAt(Eq.eqString(), 'b', 10).matchTestSome(
                (t) => t.lookup('b').matchTestSome((t) {
                  expect(t, 10);
                }),
              );
        });
      });

      test('None', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          expect(value.updateAt(Eq.eqString(), 'e', 10), isA<None>());
        });
      });
    });

    group('updateAtIfPresent', () {
      test('found', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          value
              .updateAtIfPresent(Eq.instance((a1, a2) => a1 == a2), 'b', 10)
              .lookup('b')
              .matchTestSome((t) {
            expect(t, 10);
          });
        });
      });

      test('not found', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          value
              .updateAtIfPresent(Eq.instance((a1, a2) => a1 == a2), 'e', 10)
              .lookup('b')
              .matchTestSome((t) {
            expect(t, 2);
          });
        });
      });
    });

    test('deleteAt', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(value.lookup('b'), isA<Some>());

        final result = value.deleteAt(Eq.instance((a1, a2) => a1 == a2), 'b');
        expect(value.lookup('b'), isA<Some>());
        expect(result.lookup('b'), isA<None>());
      });
    });

    group('upsertAt', () {
      test('insert', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          expect(value.lookup('e'), isA<None>());

          final result =
              value.upsertAt(Eq.instance((a1, a2) => a1 == a2), 'e', 10);
          expect(value.lookup('e'), isA<None>());

          result.lookup('e').matchTestSome((t) {
            expect(t, 10);
          });
        });
      });

      test('update', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          value.lookupEq(Eq.eqString(), 'b').matchTestSome((t) {
            expect(t, 2);
          });

          final result = value.upsertAt(Eq.eqString(), 'b', 10);
          value.lookupEq(Eq.eqString(), 'b').matchTestSome((t) {
            expect(t, 2);
          });
          result.lookupEq(Eq.eqString(), 'b').matchTestSome((t) {
            expect(t, 10);
          });
        });
      });

      test('modify by eq date year', () {
        testImmutableMap(<DateTime, int>{}, (value) {
          final d1 = DateTime(2001, 1, 1);
          final d2 = DateTime(2001, 1, 2);

          final result = value
              .upsertAt(
                dateEqYear,
                d1,
                1,
              )
              .upsertAt(
                dateEqYear,
                d2,
                2,
              );

          result.lookupEq(dateEqYear, d1).matchTestSome((t) {
            expect(t, 2);
          });
          result.lookupEq(dateEqYear, d2).matchTestSome((t) {
            expect(t, 2);
          });
        });
      });
    });

    group('pop', () {
      test('Some', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          final result = value.pop(Eq.instance((a1, a2) => a1 == a2), 'b');
          expect(value.lookup('b'), isA<Some>());

          result.matchTestSome((t) {
            expect(t.$1, 2);
            expect(t.$2.lookup('b'), isA<None>());
          });
        });
      });

      test('None', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
          expect(
            value.pop(Eq.instance((a1, a2) => a1 == a2), 'e'),
            isA<None>(),
          );
        });
      });
    });

    test('foldLeft', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.foldLeft<String>(Order.allEqual(), '', (acc, a) => '$acc$a'),
          '1234',
        );
      });
    });

    test('foldLeftWithIndex', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.foldLeftWithIndex<String>(
              Order.allEqual(), '', (acc, a, i) => '$acc$a$i'),
          '10213243',
        );
      });
    });

    test('foldLeftWithKey', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.foldLeftWithKey<String>(
              Order.allEqual(), '', (acc, k, v) => '$acc$k$v'),
          'a1b2c3d4',
        );
      });
    });

    test('foldLeftWithKeyAndIndex', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.foldLeftWithKeyAndIndex<String>(
              Order.allEqual(), '', (acc, k, v, i) => '$acc$k$v$i'),
          'a10b21c32d43',
        );
      });
    });

    test('foldRight', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.foldRight<String>(Order.allEqual(), '', (a, acc) => '$acc$a'),
          '4321',
        );
      });
    });

    test('foldRightWithIndex', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.foldRightWithIndex<String>(
              Order.allEqual(), '', (a, acc, i) => '$acc$a$i'),
          '40312213',
        );
      });
    });

    test('foldRightWithKey', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.foldRightWithKey<String>(
              Order.allEqual(), '', (k, v, acc) => '$acc$k$v'),
          'd4c3b2a1',
        );
      });
    });

    test('foldRightWithKeyAndIndex', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(
          value.foldRightWithKeyAndIndex<String>(
              Order.allEqual(), '', (k, v, acc, i) => '$acc$k$v$i'),
          'd40c31b22a13',
        );
      });
    });

    test('size', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        expect(value.size, 4);
      });
    });

    test('toSortedList', () {
      testImmutableMap({'c': 3, 'd': 4, 'a': 1, 'b': 2}, (value) {
        final result =
            value.toSortedList(Order.from((a1, a2) => a1.compareTo(a2)));
        expect(result.elementAt(0).value, 1);
        expect(result.elementAt(1).value, 2);
        expect(result.elementAt(2).value, 3);
        expect(result.elementAt(3).value, 4);
        expect(result.elementAt(0).key, 'a');
        expect(result.elementAt(1).key, 'b');
        expect(result.elementAt(2).key, 'c');
        expect(result.elementAt(3).key, 'd');
      });
    });

    test('union', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value1) {
        testImmutableMap({'c': 20, 'e': 10}, (value2) {
          final ap = value1.union(
            Eq.instance((a1, a2) => a1 == a2),
            (x, y) => x + y,
            value2,
          );

          expect(ap['a'], 1);
          expect(ap['b'], 2);
          expect(ap['c'], 23);
          expect(ap['d'], 4);
          expect(ap['e'], 10);
        });
      });
    });

    test('intersection', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value1) {
        testImmutableMap({'c': 20, 'e': 10}, (value2) {
          final ap = value1.intersection(
            Eq.instance((a1, a2) => a1 == a2),
            (x, y) => x + y,
            value2,
          );

          expect(ap['a'], null);
          expect(ap['b'], null);
          expect(ap['c'], 23);
          expect(ap['d'], null);
          expect(ap['e'], null);
        });
      });
    });

    group('isSubmap', () {
      test('true', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value1) {
          testImmutableMap({'a': 1, 'c': 3}, (value2) {
            final result = value2.isSubmap(
              Eq.eqString(),
              Eq.eqInt(),
              value1,
            );

            expect(result, true);
          });
        });
      });

      test('false (value)', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value1) {
          testImmutableMap({'a': 1, 'c': 2}, (value2) {
            final result = value2.isSubmap(
              Eq.eqString(),
              Eq.eqInt(),
              value1,
            );

            expect(result, false);
          });
        });
      });

      test('false (key)', () {
        testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value1) {
          testImmutableMap({'a': 1, 'd': 3}, (value2) {
            final result = value2.isSubmap(
              Eq.eqString(),
              Eq.eqInt(),
              value1,
            );

            expect(result, false);
          });
        });
      });
    });

    test('collect', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value) {
        final result = value.collect<String>(
          Order.from(
            (a1, a2) => a1.compareTo(a2),
          ),
          (k, v) => '$k$v',
        );

        expect(result.elementAt(0), 'a1');
        expect(result.elementAt(1), 'b2');
        expect(result.elementAt(2), 'c3');
        expect(result.elementAt(3), 'd4');
      });
    });

    test('difference', () {
      testImmutableMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, (value1) {
        testImmutableMap({'a': 1, 'c': 3}, (value2) {
          final result = value1.difference(Eq.eqString(), value2);
          expect(result['a'], null);
          expect(result['b'], 2);
          expect(result['c'], null);
          expect(result['d'], 4);
        });
      });
    });
  });
}
