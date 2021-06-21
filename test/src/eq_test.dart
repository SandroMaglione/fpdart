import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

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

    test('.and', () {
      final instance1 = Eq.instance<String>(
          (a1, a2) => a1.substring(0, 2) == a2.substring(0, 2));
      final instance2 = Eq.instance<String>(
          (a1, a2) => a1.substring(2, 4) == a2.substring(2, 4));
      final and = Eq.and(instance1, instance2);
      expect(instance1.eqv('abef', 'abcd'), true);
      expect(instance2.eqv('abef', 'zxef'), true);
      expect(and.eqv('abcd', 'abcd'), true);
      expect(and.eqv('abdc', 'abcd'), false);
      expect(and.eqv('bacd', 'abcd'), false);
    });

    test('.or', () {
      final instance1 = Eq.instance<int>((a1, a2) => a1 == (a2 + 2));
      final instance2 = Eq.instance<int>((a1, a2) => a1 == (a2 + 3));
      final or = Eq.or(instance1, instance2);
      expect(or.eqv(2, 1), false);
      expect(or.eqv(3, 1), true);
      expect(or.eqv(4, 1), true);
      expect(or.eqv(5, 1), false);
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
  });
}
