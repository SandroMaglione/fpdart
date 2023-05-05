import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Predicate', () {
    test('not (factory)', () {
      final ap = Predicate<int>.not((a) => a > 10);
      expect(ap(12), false);
      expect(ap(9), true);
      expect(ap(21), false);
    });

    test('and', () {
      final pr = Predicate<int>((a) => a > 10);
      final ap = pr.and(Predicate((a) => a < 20));
      expect(ap(12), true);
      expect(ap(9), false);
      expect(ap(21), false);
    });

    test('&', () {
      final pr = Predicate<int>((a) => a > 10);
      final ap = pr & Predicate((a) => a < 20);
      expect(ap(12), true);
      expect(ap(9), false);
      expect(ap(21), false);
    });

    test('or', () {
      final pr = Predicate<int>((a) => a > 10);
      final ap = pr.or(Predicate((a) => a == 2));
      expect(ap(12), true);
      expect(ap(9), false);
      expect(ap(2), true);
    });

    test('|', () {
      final pr = Predicate<int>((a) => a > 10);
      final ap = pr | Predicate((a) => a == 2);
      expect(ap(12), true);
      expect(ap(9), false);
      expect(ap(2), true);
    });

    test('not', () {
      final pr = Predicate<int>((a) => a > 10);
      final ap = pr.not;
      expect(ap(12), false);
      expect(ap(9), true);
      expect(ap(2), true);
    });

    test('~', () {
      final pr = Predicate<int>((a) => a > 10);
      final ap = ~pr;
      expect(ap(12), false);
      expect(ap(9), true);
      expect(ap(2), true);
    });

    test('xor', () {
      final pr = Predicate<int>((a) => a > 10);
      final ap = pr.xor(Predicate((a) => a < 20));
      expect(ap(12), false);
      expect(ap(9), true);
      expect(ap(21), true);
    });

    test('^', () {
      final pr = Predicate<int>((a) => a > 10);
      final ap = pr ^ Predicate((a) => a < 20);
      expect(ap(12), false);
      expect(ap(9), true);
      expect(ap(21), true);
    });
  });
}
