import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Monoid', () {
    group('is a', () {
      final instance = Monoid.instance<int>(0, (a1, a2) => a1 + a2);

      test('Semigroup', () {
        expect(instance, isA<Semigroup>());
      });
    });

    test('.instance (int)', () {
      final instance = Monoid.instance<int>(0, (a1, a2) => a1 + a2);
      expect(instance.combine(10, instance.empty),
          instance.combine(instance.empty, 10));
      expect(instance.combine(10, instance.empty), 10);
    });

    test('.instance (String)', () {
      final instance = Monoid.instance<String>('', (a1, a2) => '$a1$a2');
      expect(instance.combine('abc', instance.empty),
          instance.combine(instance.empty, 'abc'));
      expect(instance.combine('abc', instance.empty), 'abc');
    });

    test('.isEmpty', () {
      final instance = Monoid.instance<int>(0, (a1, a2) => a1 + a2);
      final eq = Eq.instance<int>((a1, a2) => a1 == a2);
      expect(instance.isEmpty(instance.empty, eq), true);
      expect(instance.isEmpty(0, eq), true);
      expect(instance.isEmpty(1, eq), false);
    });

    test('.combineN', () {
      final instance = Monoid.instance<int>(0, (a1, a2) => a1 + a2);
      expect(instance.combineN(0, 10), 0);
      expect(instance.combineN(1, 10), 10);
    });

    test('.reverse', () {
      final instance = Monoid.instance<String>('', (a1, a2) => '$a1$a2');
      final reverse = instance.reverse();
      expect(reverse.combine('a', 'b'), 'ba');
      expect(reverse.combine('a', 'b'), instance.combine('b', 'a'));
    });
  });
}
