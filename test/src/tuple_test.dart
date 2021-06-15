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
      expect(c1.first, 'def');
      expect(c2.second, 11);
      expect(cb.first, '0');
      expect(cb.second, 0);
    });
  });
}
