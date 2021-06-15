import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/tuple.dart';
import 'package:test/test.dart';

void main() {
  group('Tuple', () {
    test('first', () {
      const tuple = Tuple2('abc', 10);
      expect(tuple.first, 'abc');
    });

    test('second', () {
      const tuple = Tuple2('abc', 10);
      expect(tuple.second, 10);
    });

    test('mapFirst', () {
      const tuple = Tuple2('abc', 10);
      final map = tuple.mapFirst((v1) => v1.length);
      expect(map.first, 3);
    });

    test('mapSecond', () {
      const tuple = Tuple2('abc', 10);
      final map = tuple.mapSecond((v2) => '$v2');
      expect(map.second, '10');
    });

    test('map', () {
      const tuple = Tuple2('abc', 10);
      final map = tuple.map((v2) => '$v2');
      expect(map.second, '10');
    });

    test('apply', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.apply((v1, v2) => v1.length + v2);
      expect(ap, 13);
    });

    test('extend', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.extend((t) => t.second * 2 + t.first.length);
      expect(ap.first, 'abc');
      expect(ap.second, 23);
    });

    test('extendFirst', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.extendFirst((t) => t.second * 2 + t.first.length);
      expect(ap.first, 23);
      expect(ap.second, 10);
    });

    test('duplicate', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.duplicate();
      expect(ap.first, 'abc');
      expect(ap.second.first, 'abc');
      expect(ap.second.second, 10);
    });

    test('foldRight', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.foldRight<int>(10, (acc, a) => acc + a);
      expect(ap, 20);
    });

    test('foldLeft', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.foldLeft<int>(10, (acc, a) => acc + a);
      expect(ap, 20);
    });

    test('foldRightFirst', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.foldRightFirst<int>(10, (acc, a) => acc + a.length);
      expect(ap, 13);
    });

    test('foldLeftFirst', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.foldLeftFirst<int>(10, (acc, a) => acc + a.length);
      expect(ap, 13);
    });

    test('foldRightWithIndex', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.foldRightWithIndex<int>(10, (i, acc, a) => acc + a);
      expect(ap, 20);
    });

    test('foldLeftWithIndex', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.foldLeftWithIndex<int>(10, (i, acc, a) => acc + a);
      expect(ap, 20);
    });

    test('foldRightFirstWithIndex', () {
      const tuple = Tuple2('abc', 10);
      final ap =
          tuple.foldRightFirstWithIndex<int>(10, (i, acc, a) => acc + a.length);
      expect(ap, 13);
    });

    test('foldLeftFirstWithIndex', () {
      const tuple = Tuple2('abc', 10);
      final ap =
          tuple.foldLeftFirstWithIndex<int>(10, (i, acc, a) => acc + a.length);
      expect(ap, 13);
    });

    test('foldMap', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.foldMap<int>(
          Monoid.instance(0, (a1, a2) => a1 + a2), (a) => a + 10);
      expect(ap, 20);
    });

    test('foldMapFirst', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.foldMapFirst<int>(
          Monoid.instance(0, (a1, a2) => a1 + a2), (a) => a.length + 10);
      expect(ap, 13);
    });

    test('length', () {
      const tuple1 = Tuple2('abc', 10);
      const tuple2 = Tuple2(0.4, 'ab');
      const tuple3 = Tuple2(10, 0.2);
      expect(tuple1.length(), 1);
      expect(tuple2.length(), 1);
      expect(tuple3.length(), 1);
    });

    test('all', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.all((a) => a > 5);
      expect(ap, true);
    });

    test('any', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.any((a) => a > 5);
      expect(ap, true);
    });

    test('swap', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.swap();
      expect(ap.first, 10);
      expect(ap.second, 'abc');
    });

    test('concatenate', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.concatenate(Monoid.instance(0, (a1, a2) => a1 + a2));
      expect(ap, 10);
    });

    test('toString', () {
      const tuple = Tuple2('abc', 10);
      expect(tuple.toString(), 'Tuple2(abc, 10)');
    });

    test('copyWith', () {
      const tuple = Tuple2('abc', 10);
      final c1 = tuple.copyWith(value1: 'def');
      final c2 = tuple.copyWith(value2: 11);
      final cb = tuple.copyWith(value1: '0', value2: 0);
      expect(c1.first, 'def');
      expect(c2.second, 11);
      expect(cb.first, '0');
      expect(cb.second, 0);
    });

    test('Tuple2 == Tuple2', () {
      const t1 = Tuple2('abc', 10);
      const t2 = Tuple2('abc', 10);
      const t3 = Tuple2('abc', 9);
      const t4 = Tuple2(0.4, 'abc');
      const map1 = <String, Tuple2>{'t1': t1, 't2': t1};
      const map2 = <String, Tuple2>{'t1': t1, 't2': t2};
      const map3 = <String, Tuple2>{'t1': t1, 't2': t3};
      const map4 = <String, Tuple2>{'t1': t1, 't2': t4};
      expect(t1, t1);
      expect(t1, t2);
      expect(t1 == t3, false);
      expect(t1 == t4, false);
      expect(map1, map1);
      expect(map1, map2);
      expect(map1 == map3, false);
      expect(map1 == map4, false);
    });
  });
}
