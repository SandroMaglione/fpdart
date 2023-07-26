import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

class _Parent {
  final int value1;
  final double value2;
  const _Parent(this.value1, this.value2);
}

void main() {
  group('Eq', () {
    test('.instance (int)', () {
      final instance = Eq.instance<int>((a1, a2) => a1 == (a2 + 1));

      // eqv
      expect(instance.eqv(1, 1), false);
      expect(instance.eqv(2, 1), true);
      expect(instance.eqv(3, 1), false);

      // neqv
      expect(instance.neqv(1, 1), true);
      expect(instance.neqv(2, 1), false);
      expect(instance.neqv(3, 1), true);
    });

    test('.instance (String)', () {
      final instance = Eq.instance<String>(
          (a1, a2) => a1.substring(0, 2) == a2.substring(0, 2));
      expect(instance.eqv('abc', 'abc'), true);
      expect(instance.eqv('abc', 'acb'), false);
    });

    test('and', () {
      final instance1 = Eq.instance<String>(
          (a1, a2) => a1.substring(0, 2) == a2.substring(0, 2));
      final instance2 = Eq.instance<String>(
          (a1, a2) => a1.substring(2, 4) == a2.substring(2, 4));
      final and = instance1.and(instance2);
      expect(instance1.eqv('abef', 'abcd'), true);
      expect(instance2.eqv('abef', 'zxef'), true);
      expect(and.eqv('abcd', 'abcd'), true);
      expect(and.eqv('abdc', 'abcd'), false);
      expect(and.eqv('bacd', 'abcd'), false);
    });

    test('or', () {
      final instance1 = Eq.instance<int>((a1, a2) => a1 == (a2 + 2));
      final instance2 = Eq.instance<int>((a1, a2) => a1 == (a2 + 3));
      final or = instance1.or(instance2);
      expect(or.eqv(2, 1), false);
      expect(or.eqv(3, 1), true);
      expect(or.eqv(4, 1), true);
      expect(or.eqv(5, 1), false);
    });

    test('xor', () {
      final instance1 = Eq.instance<int>((a1, a2) => a1 == (a2 + 2));
      final instance2 = Eq.instance<int>((a1, a2) => a1 == (a2 + 3));
      final xor = instance1.xor(instance2);
      final xorSame = instance1.xor(instance1);
      expect(xor.eqv(2, 1), false);
      expect(xor.eqv(3, 1), true);
      expect(xor.eqv(4, 1), true);
      expect(xorSame.eqv(3, 1), false);
    });

    test('.fromUniversalEquals', () {
      final instance = Eq.fromUniversalEquals<int>();
      expect(instance.eqv(1, 1), true);
      expect(instance.eqv(1, 2), false);
    });

    test('.allEqual', () {
      final instance = Eq.allEqual<int>();
      expect(instance.eqv(1, 1), true);
      expect(instance.eqv(1, 2), true);
      expect(instance.eqv(2, 1), true);
    });

    test('.by', () {
      final instance = Eq.instance<int>((a1, a2) => a1 == a2);
      final by = Eq.by<String, int>((a) => a.length, instance);
      expect(by.eqv('abc', 'abc'), true);
      expect(by.eqv('abc', 'ab'), false);
    });

    test('.eqNum', () {
      final eq = Eq.eqNum;
      expect(eq.eqv(10, 10), true);
      expect(eq.eqv(10.0, 10), true);
      expect(eq.eqv(10.5, 10.5), true);
      expect(eq.eqv(-10, -10.0), true);
      expect(eq.eqv(10, 10.5), false);
    });

    test('.eqInt', () {
      final eq = Eq.eqInt;
      expect(eq.eqv(10, 10), true);
      expect(eq.eqv(11, 10), false);
      expect(eq.eqv(-10, -10), true);
      expect(eq.eqv(10, 11), false);
    });

    test('.eqDouble', () {
      final eq = Eq.eqDouble;
      expect(eq.eqv(10, 10), true);
      expect(eq.eqv(10.0, 10), true);
      expect(eq.eqv(10.5, 10.5), true);
      expect(eq.eqv(-10, -10.0), true);
      expect(eq.eqv(10, 10.5), false);
    });

    test('.eqString', () {
      final eq = Eq.eqString;
      expect(eq.eqv("abc", "abc"), true);
      expect(eq.eqv("abc", "abd"), false);
      expect(eq.eqv("abc", "ab"), false);
      expect(eq.eqv("a", "a"), true);
      expect(eq.eqv("a", "ab"), false);
    });

    test('.eqBool', () {
      final eq = Eq.eqBool;
      expect(eq.eqv(true, true), true);
      expect(eq.eqv(false, true), false);
      expect(eq.eqv(true, false), false);
      expect(eq.eqv(false, false), true);
    });

    group('contramap', () {
      test('int', () {
        final eqParentInt = Eq.eqInt.contramap<_Parent>(
          (p) => p.value1,
        );

        expect(
          eqParentInt.eqv(
            _Parent(1, 2.5),
            _Parent(1, 12.5),
          ),
          true,
        );
        expect(
          eqParentInt.eqv(
            _Parent(1, 2.5),
            _Parent(4, 2.5),
          ),
          false,
        );
        expect(
          eqParentInt.eqv(
            _Parent(-1, 2.5),
            _Parent(1, 12.5),
          ),
          false,
        );
      });

      test('double', () {
        final eqParentDouble = Eq.eqDouble.contramap<_Parent>(
          (p) => p.value2,
        );

        expect(
          eqParentDouble.eqv(
            _Parent(1, 2.5),
            _Parent(1, 2.5),
          ),
          true,
        );
        expect(
          eqParentDouble.eqv(
            _Parent(1, 2.5),
            _Parent(1, 12.5),
          ),
          false,
        );
        expect(
          eqParentDouble.eqv(
            _Parent(-1, 2.5),
            _Parent(1, 2),
          ),
          false,
        );
      });
    });
  });
}
