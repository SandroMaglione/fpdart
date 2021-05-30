import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('BoundedSemilattice', () {
    group('is a', () {
      final instance = BoundedSemilattice.instance<int>(0, (a1, a2) => a1 + a2);

      test('Semigroup', () {
        expect(instance, isA<Semigroup>());
      });

      test('Band', () {
        expect(instance, isA<Band>());
      });

      test('Semilattice', () {
        expect(instance, isA<Semilattice>());
      });

      test('CommutativeSemigroup', () {
        expect(instance, isA<CommutativeSemigroup>());
      });

      test('Monoid', () {
        expect(instance, isA<Monoid>());
      });

      test('CommutativeMonoid', () {
        expect(instance, isA<CommutativeMonoid>());
      });
    });

    test('combineN', () {
      final instance = BoundedSemilattice.instance<int>(0, (a1, a2) => a1 + a2);
      expect(instance.combineN(1, 1), 1);
      expect(instance.combineN(1, 10), 1);
    });
  });
}
