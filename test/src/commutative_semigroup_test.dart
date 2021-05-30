import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('CommutativeSemigroup', () {
    group('is a', () {
      final instance = CommutativeSemigroup.instance<int>((a1, a2) => a1 + a2);

      test('Semigroup', () {
        expect(instance, isA<Semigroup>());
      });
    });
  });
}
