import 'package:fpdart/src/tuple.dart';
import 'package:test/test.dart';

void main() {
  group('Tuple', () {
    test('value1', () {
      const tuple = Tuple2('abc', 10);
      expect(tuple.value1, 'abc');
    });

    test('value2', () {
      const tuple = Tuple2('abc', 10);
      expect(tuple.value2, 10);
    });

    test('map1', () {
      const tuple = Tuple2('abc', 10);
      final map = tuple.map1((v1) => v1.length);
      expect(map.value1, 3);
    });

    test('map2', () {
      const tuple = Tuple2('abc', 10);
      final map = tuple.map2((v2) => '$v2');
      expect(map.value2, '10');
    });

    test('apply', () {
      const tuple = Tuple2('abc', 10);
      final ap = tuple.apply((v1, v2) => v1.length + v2);
      expect(ap, 13);
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
      expect(c1.value1, 'def');
      expect(c2.value2, 11);
      expect(cb.value1, '0');
      expect(cb.value2, 0);
    });
  });
}
