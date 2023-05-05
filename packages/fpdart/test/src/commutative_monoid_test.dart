import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('CommutativeMonoid', () {
    group('is a', () {
      final instance = CommutativeMonoid.instance<int>(0, (a1, a2) => a1 + a2);

      test('Semigroup', () {
        expect(instance, isA<Semigroup>());
      });

      test('CommutativeSemigroup', () {
        expect(instance, isA<CommutativeSemigroup>());
      });

      test('Monoid', () {
        expect(instance, isA<Monoid>());
      });
    });
  });
}
