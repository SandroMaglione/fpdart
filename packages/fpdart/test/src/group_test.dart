import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Group', () {
    group('is a', () {
      final instance = Group.instance<int>(0, (a1, a2) => a1 + a2, (a) => -a);

      test('Semigroup', () {
        expect(instance, isA<Semigroup>());
      });

      test('Monoid', () {
        expect(instance, isA<Monoid>());
      });
    });

    test('inverse', () {
      final instance = Group.instance<int>(0, (a1, a2) => a1 + a2, (a) => -a);
      expect(instance.inverse(1), -1);
      expect(instance.combine(1, instance.inverse(1)), instance.empty);
      expect(instance.combine(instance.inverse(1), 1), instance.empty);
    });

    test('remove', () {
      final instance = Group.instance<int>(0, (a1, a2) => a1 + a2, (a) => -a);
      expect(instance.remove(1, 2), -1);
      expect(instance.remove(2, 1), 1);
      expect(instance.remove(1, 1), instance.empty);
      expect(instance.remove(1, 2), instance.combine(1, instance.inverse(2)));
    });

    test('combineN', () {
      final instance = Group.instance<int>(0, (a1, a2) => a1 + a2, (a) => -a);
      expect(instance.combineN(1, 2), 2);
      expect(instance.combineN(1, 1), 1);
      expect(instance.combineN(1, 0), instance.empty);
      expect(instance.combineN(1, -1), -1);
      expect(instance.combineN(1, -2), -2);

      // Stack Overflow!
      // expect(instance.combineN(2, 9223372036854775807), 2);
    });
  });
}
