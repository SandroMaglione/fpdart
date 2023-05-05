import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Semigroup', () {
    test('.instance', () {
      final instance = Semigroup.instance<String>((a1, a2) => '$a1$a2');
      expect(instance.combine('a', 'b'), 'ab');
      expect(instance.combine('a', instance.combine('b', 'c')),
          instance.combine(instance.combine('a', 'b'), 'c'));
      expect(instance.combineN('a', 3), 'aaa');
    });

    test('.first', () {
      final instance = Semigroup.first<String>();
      expect(instance.combine('a', 'b'), 'a');
      expect(instance.combine('a', instance.combine('b', 'c')),
          instance.combine(instance.combine('a', 'b'), 'c'));
      expect(instance.combineN('a', 3), 'a');
    });

    test('.last', () {
      final instance = Semigroup.last<String>();
      expect(instance.combine('a', 'b'), 'b');
      expect(instance.combine('a', instance.combine('b', 'c')),
          instance.combine(instance.combine('a', 'b'), 'c'));
      expect(instance.combineN('a', 3), 'a');
    });

    test('.combineN', () {
      final instance = Semigroup.instance<int>((a1, a2) => a1 + a2);
      expect(instance.combineN(1, 10), 10);
    });

    test('.intercalate', () {
      final instance = Semigroup.instance<String>((a1, a2) => '$a1$a2');
      final intercalate = instance.intercalate('-');
      expect(intercalate.combine('a', 'b'), 'a-b');
      expect(intercalate.combineN('a', 3), 'a-a-a');
    });

    test('.reverse', () {
      final instance = Semigroup.instance<String>((a1, a2) => '$a1$a2');
      final reverse = instance.reverse();
      expect(reverse.combine('a', 'b'), 'ba');
      expect(reverse.combine('a', 'b'), instance.combine('b', 'a'));
    });
  });
}
