import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Order', () {
    group('is a', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));

      test('Eq', () {
        expect(instance, isA<Eq>());
      });

      test('PartialOrder', () {
        expect(instance, isA<PartialOrder>());
      });
    });

    test('.from', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      expect(instance.compare(1, 1), 0);
      expect(instance.compare(1, 2), -1);
      expect(instance.compare(2, 1), 1);
    });

    test('.reverse', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      final reverse = Order.reverse(instance);
      expect(reverse.compare(1, 1), 0);
      expect(reverse.compare(1, 2), 1);
      expect(reverse.compare(2, 1), -1);
    });

    test('.fromLessThan', () {
      final instance = Order.fromLessThan<int>((a1, a2) => a1 < a2);
      expect(instance.compare(1, 1), 0);
      expect(instance.compare(1, 2), -1);
      expect(instance.compare(2, 1), 1);
    });

    test('.allEqual', () {
      final instance = Order.allEqual<int>();
      expect(instance.compare(1, 1), 0);
      expect(instance.compare(1, 2), 0);
      expect(instance.compare(2, 1), 0);
    });

    test('.whenEqual', () {
      final instance1 =
          Order.fromLessThan<String>((a1, a2) => a1.length < a2.length);
      final instance2 = Order.from<String>(
          (a1, a2) => a1.substring(0, 1).compareTo(a2.substring(0, 1)));
      final whenEqual = Order.whenEqual(instance1, instance2);
      expect(whenEqual.compare('abc', 'abcd'), -1);
      expect(whenEqual.compare('abcd', 'abc'), 1);
      expect(whenEqual.compare('abc', 'ebc'), -1);
      expect(whenEqual.compare('ebc', 'abc'), 1);
      expect(whenEqual.compare('abc', 'abc'), 0);
    });

    test('.by', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      final by = Order.by<String, int>((a1) => a1.length, instance);
      expect(by.compare('abc', 'abc'), 0);
      expect(by.compare('abc', 'abcd'), -1);
      expect(by.compare('abcd', 'abc'), 1);
    });

    test('min', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      expect(instance.min(0, 10), 0);
      expect(instance.min(10, 0), 0);
    });

    test('max', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      expect(instance.max(0, 10), 10);
      expect(instance.max(10, 0), 10);
    });

    test('eqv', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      expect(instance.eqv(0, 10), false);
      expect(instance.eqv(0, 0), true);
    });

    test('neqv', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      expect(instance.neqv(0, 10), true);
      expect(instance.neqv(0, 0), false);
    });

    test('lteqv', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      expect(instance.lteqv(0, 10), true);
      expect(instance.lteqv(0, 0), true);
      expect(instance.lteqv(0, -1), false);
    });

    test('lt', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      expect(instance.lt(0, 10), true);
      expect(instance.lt(0, 0), false);
      expect(instance.lt(0, -1), false);
    });

    test('gteqv', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      expect(instance.gteqv(0, 10), false);
      expect(instance.gteqv(0, 0), true);
      expect(instance.gteqv(0, -1), true);
    });

    test('gt', () {
      final instance = Order.from<int>((a1, a2) => a1.compareTo(a2));
      expect(instance.gt(0, 10), false);
      expect(instance.gt(0, 0), false);
      expect(instance.gt(0, -1), true);
    });
  });
}
