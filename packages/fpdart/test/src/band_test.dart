import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Band', () {
    group('is a', () {
      final instance = Band.instance<int>((a1, a2) => a1 + a2);

      test('Semigroup', () {
        expect(instance, isA<Semigroup>());
      });
    });

    test('combineN', () {
      final instance = Band.instance<int>((a1, a2) => a1 + a2);
      expect(instance.combineN(1, 1), 1);
      expect(instance.combineN(1, 10), 2);
    });
  });
}
