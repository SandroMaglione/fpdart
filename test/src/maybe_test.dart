import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/applicative.dart';
import 'package:fpdart/src/foldable.dart';
import 'package:fpdart/src/maybe.dart';
import 'package:test/test.dart';

void main() {
  group('Maybe', () {
    group('is a', () {
      test('Applicative', () {
        final maybe = Just(10);
        expect(maybe, isA<Applicative>());
      });

      test('Foldable', () {
        final maybe = Just(10);
        expect(maybe, isA<Foldable>());
      });
    });

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

    group('ap', () {
      test('Just', () {
        final maybe = Just(10);
        final pure = maybe.ap(Just((int i) => i + 1));
        pure.match((just) => expect(just, 11), () => null);
      });

      test('Just (curried)', () {
        final ap = Just((int a) => (int b) => a + b)
            .ap(
              Just((f) => f(3)),
            )
            .ap(
              Just((f) => f(5)),
            );
        ap.match((just) => expect(just, 8), () => null);
      });

      test('Nothing', () {
        final maybe = Nothing<int>();
        final pure = maybe.ap(Just((int i) => i + 1));
        expect(pure, isA<Nothing>());
      });
    });
  });
}
