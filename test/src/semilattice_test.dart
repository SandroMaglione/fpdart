import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Semilattice', () {
    group('is a', () {
      final instance = Semilattice.instance<int>((a1, a2) => a1 + a2);

      test('Semigroup', () {
        expect(instance, isA<Semigroup>());
      });

      test('Band', () {
        expect(instance, isA<Band>());
      });

      test('CommutativeSemigroup', () {
        expect(instance, isA<CommutativeSemigroup>());
      });
    });

    test('combineN (from Band)', () {
      final instance = Semilattice.instance<int>((a1, a2) => a1 + a2);
      expect(instance.combineN(1, 1), 1);
      expect(instance.combineN(1, 10), 2);
    });

    test('asMeetPartialOrder', () {
      final instance = Semilattice.instance<int>((a1, a2) => a1 + a2);
      final eq = Eq.instance<int>((a1, a2) => a1 == a2);
      final partialOrder = instance.asMeetPartialOrder(eq);
      expect(partialOrder.partialCompare(1, 1), 0);
      expect(partialOrder.partialCompare(1, 0), -1);
      expect(partialOrder.partialCompare(0, 1), 1);
      expect(partialOrder.partialCompare(2, 1), null);
    });

    test('asJoinPartialOrder', () {
      final instance = Semilattice.instance<int>((a1, a2) => a1 + a2);
      final eq = Eq.instance<int>((a1, a2) => a1 == a2);
      final partialOrder = instance.asJoinPartialOrder(eq);
      expect(partialOrder.partialCompare(1, 1), 0);
      expect(partialOrder.partialCompare(1, 0), 1);
      expect(partialOrder.partialCompare(0, 1), -1);
      expect(partialOrder.partialCompare(2, 1), null);
    });
  });
}
