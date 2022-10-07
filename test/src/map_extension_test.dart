import 'package:fpdart/fpdart.dart';

import './utils/utils.dart';

void main() {
  group('FpdartOnMutableMap', () {
    test('mapValue', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.mapValue((value) => '${value * 2}');
      expect(ap, {'a': '2', 'b': '4', 'c': '6', 'd': '8'});
    });

    test('mapWithIndex', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.mapWithIndex((value, index) => '${value + index}');
      expect(ap, {'a': '1', 'b': '3', 'c': '5', 'd': '7'});
    });

    test('filter', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.filter((t) => t > 2);
      expect(ap, {'c': 3, 'd': 4});
    });

    test('filterWithIndex', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.filterWithIndex((t, i) => t > 2 && i != 3);
      expect(ap, {'c': 3});
    });

    test('filterWithKey', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.filterWithKey((k, v) => v > 2 && k != 'd');
      expect(ap, {'c': 3});
    });

    test('filterWithKeyAndIndex', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap =
          map.filterWithKeyAndIndex((k, v, i) => v > 1 && i != 1 && k != 'd');
      expect(ap, {'c': 3});
    });

    group('lookup', () {
      test('Some', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.lookup('b');
        ap.matchTestSome((t) {
          expect(t, 2);
        });
      });

      test('None', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.lookup('e');
        expect(ap, isA<None>());
      });
    });

    group('lookupWithKey', () {
      test('Some', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.lookupWithKey('b');
        ap.matchTestSome((t) {
          expect(t.first, 'b');
          expect(t.second, 2);
        });
      });

      test('None', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.lookupWithKey('e');
        expect(ap, isA<None>());
      });
    });

    test('member', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.member('b');
      final ap2 = map.member('e');
      expect(ap, true);
      expect(ap2, false);
    });

    test('elem', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.elem(1);
      final ap2 = map.elem(0);
      expect(ap, true);
      expect(ap2, false);
    });

    group('modifyAt', () {
      test('Some', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap =
            map.modifyAt(Eq.instance((a1, a2) => a1 == a2))('b', (v) => v + 2);
        ap.matchTestSome((t) => t.lookup('b').matchTestSome((t) {
              expect(t, 4);
            }));
      });

      test('None', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap =
            map.modifyAt(Eq.instance((a1, a2) => a1 == a2))('e', (v) => v + 2);
        expect(ap, isA<None>());
      });
    });

    group('modifyAtIfPresent', () {
      test('found', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.modifyAtIfPresent(Eq.instance((a1, a2) => a1 == a2))(
            'b', (v) => v + 2);
        ap.lookup('b').matchTestSome((t) {
          expect(t, 4);
        });
      });

      test('not found', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.modifyAtIfPresent(Eq.instance((a1, a2) => a1 == a2))(
            'e', (v) => v + 2);
        ap.lookup('b').matchTestSome((t) {
          expect(t, 2);
        });
      });
    });

    group('updateAt', () {
      test('Some', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.updateAt(Eq.instance((a1, a2) => a1 == a2))('b', 10);
        ap.matchTestSome((t) => t.lookup('b').matchTestSome((t) {
              expect(t, 10);
            }));
      });

      test('None', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.updateAt(Eq.instance((a1, a2) => a1 == a2))('e', 10);
        expect(ap, isA<None>());
      });
    });

    group('updateAtIfPresent', () {
      test('found', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap =
            map.updateAtIfPresent(Eq.instance((a1, a2) => a1 == a2))('b', 10);
        ap.lookup('b').matchTestSome((t) {
          expect(t, 10);
        });
      });

      test('not found', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap =
            map.updateAtIfPresent(Eq.instance((a1, a2) => a1 == a2))('e', 10);
        ap.lookup('b').matchTestSome((t) {
          expect(t, 2);
        });
      });
    });

    test('deleteAt', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      expect(map.lookup('b'), isA<Some>());
      final ap = map.deleteAt(Eq.instance((a1, a2) => a1 == a2))('b');
      expect(map.lookup('b'), isA<Some>());
      expect(ap.lookup('b'), isA<None>());
    });

    group('upsertAt', () {
      test('insert', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        expect(map.lookup('e'), isA<None>());
        final ap = map.upsertAt(Eq.instance((a1, a2) => a1 == a2))('e', 10);
        expect(map.lookup('e'), isA<None>());
        ap.lookup('e').matchTestSome((t) {
          expect(t, 10);
        });
      });

      test('update', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        map.lookup('b').matchTestSome((t) {
          expect(t, 2);
        });
        final ap = map.upsertAt(Eq.instance((a1, a2) => a1 == a2))('b', 10);
        map.lookup('b').matchTestSome((t) {
          expect(t, 2);
        });
        ap.lookup('b').matchTestSome((t) {
          expect(t, 10);
        });
      });

      test('modify by eq date year', () {
        final d1 = DateTime(2001, 1, 1);
        final d2 = DateTime(2001, 1, 2);
        final map = <DateTime, int>{}
            .upsertAt(dateEqYear)(d1, 1)
            .upsertAt(dateEqYear)(d2, 2);

        expect(map.lookup(d1), isA<None>());
        expect(map.lookup(d2), isA<Some>());
        map.lookup(d2).matchTestSome((t) {
          expect(t, 2);
        });
      });
    });

    group('pop', () {
      test('Some', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.pop(Eq.instance((a1, a2) => a1 == a2))('b');
        expect(map.lookup('b'), isA<Some>());
        ap.matchTestSome((t) {
          expect(t.first, 2);
          expect(t.second.lookup('b'), isA<None>());
        });
      });

      test('None', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.pop(Eq.instance((a1, a2) => a1 == a2))('e');
        expect(ap, isA<None>());
      });
    });

    test('foldLeft', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap =
          map.foldLeft<String>(Order.allEqual())('', (acc, a) => '$acc$a');
      expect(ap, '1234');
    });

    test('foldLeftWithIndex', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.foldLeftWithIndex<String>(Order.allEqual())(
          '', (acc, a, i) => '$acc$a$i');
      expect(ap, '10213243');
    });

    test('foldLeftWithKey', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.foldLeftWithKey<String>(Order.allEqual())(
          '', (acc, k, v) => '$acc$k$v');
      expect(ap, 'a1b2c3d4');
    });

    test('foldLeftWithKeyAndIndex', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.foldLeftWithKeyAndIndex<String>(Order.allEqual())(
          '', (acc, k, v, i) => '$acc$k$v$i');
      expect(ap, 'a10b21c32d43');
    });

    test('foldRight', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap =
          map.foldRight<String>(Order.allEqual())('', (a, acc) => '$acc$a');
      expect(ap, '4321');
    });

    test('foldRightWithIndex', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.foldRightWithIndex<String>(Order.allEqual())(
          '', (a, acc, i) => '$acc$a$i');
      expect(ap, '40312213');
    });

    test('foldRightWithKey', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.foldRightWithKey<String>(Order.allEqual())(
          '', (k, v, acc) => '$acc$k$v');
      expect(ap, 'd4c3b2a1');
    });

    test('foldRightWithKeyAndIndex', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.foldRightWithKeyAndIndex<String>(Order.allEqual())(
          '', (k, v, acc, i) => '$acc$k$v$i');
      expect(ap, 'd40c31b22a13');
    });

    test('size', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.size;
      expect(ap, 4);
    });

    test('toIterable', () {
      final map = <String, int>{'c': 3, 'd': 4, 'a': 1, 'b': 2};
      final ap = map.toIterable(Order.from((a1, a2) => a1.compareTo(a2)));
      expect(ap.elementAt(0).value, 1);
      expect(ap.elementAt(1).value, 2);
      expect(ap.elementAt(2).value, 3);
      expect(ap.elementAt(3).value, 4);
      expect(ap.elementAt(0).key, 'a');
      expect(ap.elementAt(1).key, 'b');
      expect(ap.elementAt(2).key, 'c');
      expect(ap.elementAt(3).key, 'd');
    });

    test('union', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final map1 = <String, int>{'c': 20, 'e': 10};
      final ap =
          map.union(Eq.instance((a1, a2) => a1 == a2), (x, y) => x + y)(map1);
      expect(ap['a'], 1);
      expect(ap['b'], 2);
      expect(ap['c'], 23);
      expect(ap['d'], 4);
      expect(ap['e'], 10);
    });

    test('intersection', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final map1 = <String, int>{'c': 20, 'e': 10};
      final ap = map.intersection(
          Eq.instance((a1, a2) => a1 == a2), (x, y) => x + y)(map1);
      expect(ap['a'], null);
      expect(ap['b'], null);
      expect(ap['c'], 23);
      expect(ap['d'], null);
      expect(ap['e'], null);
    });

    group('isSubmap', () {
      test('true', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final map1 = <String, int>{'a': 1, 'c': 3};
        final ap = map1.isSubmap(Eq.instance((a1, a2) => a1 == a2))(
            Eq.instance((a1, a2) => a1 == a2))(map);
        expect(ap, true);
      });

      test('false (value)', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final map1 = <String, int>{'a': 1, 'c': 2};
        final ap = map1.isSubmap(Eq.instance((a1, a2) => a1 == a2))(
            Eq.instance((a1, a2) => a1 == a2))(map);
        expect(ap, false);
      });

      test('false (key)', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final map1 = <String, int>{'a': 1, 'd': 3};
        final ap = map1.isSubmap(Eq.instance((a1, a2) => a1 == a2))(
            Eq.instance((a1, a2) => a1 == a2))(map);
        expect(ap, false);
      });
    });

    test('collect', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.collect<String>(Order.from((a1, a2) => a1.compareTo(a2)))(
          (k, v) => '$k$v');
      expect(ap.elementAt(0), 'a1');
      expect(ap.elementAt(1), 'b2');
      expect(ap.elementAt(2), 'c3');
      expect(ap.elementAt(3), 'd4');
    });

    test('difference', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final map1 = <String, int>{'a': 1, 'c': 3};
      final ap = map.difference(Eq.instance((a1, a2) => a1 == a2))(map1);
      expect(ap['a'], null);
      expect(ap['b'], 2);
      expect(ap['c'], null);
      expect(ap['d'], 4);
    });
  });
}
