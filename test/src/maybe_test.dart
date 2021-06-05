import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/maybe.dart';
import 'package:test/test.dart';

void main() {
  group('Maybe', () {
    test('map', () {
      final maybe = Just(10);
      final map = maybe.map((a) => a + 1);
      map.match((just) => expect(just, 11), () => null);
    });

    test('foldRight', () {
      final maybe = Just(10);
      final foldRight = maybe.foldRight<int>(1, (a, b) => a + b);
      expect(foldRight, 11);
    });

    test('fold', () {
      final maybe = Just(10);
      final fold = maybe.fold<int>(1, (a, b) => a + b);
      expect(fold, 11);
    });

    test('foldMap', () {
      final maybe = Just(10);
      final foldMap =
          maybe.foldMap<int>(Monoid.instance(0, (a1, a2) => a1 + a2), (a) => a);
      expect(foldMap, 10);
    });
  });
}
