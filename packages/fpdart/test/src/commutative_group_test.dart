import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('CommutativeGroup', () {
    group('is a', () {
      final instance =
          CommutativeGroup.instance<int>(0, (a1, a2) => a1 + a2, (a) => -a);

      test('Semigroup', () {
        expect(instance, isA<Semigroup>());
      });

      test('CommutativeSemigroup', () {
        expect(instance, isA<CommutativeSemigroup>());
      });

      test('CommutativeMonoid', () {
        expect(instance, isA<CommutativeMonoid>());
      });

      test('Monoid', () {
        expect(instance, isA<Monoid>());
      });

      test('Group', () {
        expect(instance, isA<Group>());
      });
    });
  });
}
