import 'package:fpdart/fpdart.dart';
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

    group('flatMap', () {
      test('Just', () {
        final maybe = Just(10);
        final flatMap = maybe.flatMap<int>((a) => Just(a + 1));
        flatMap.match((just) => expect(just, 11), () => null);
      });

      test('Nothing', () {
        final maybe = Nothing<int>();
        final flatMap = maybe.flatMap<int>((a) => Just(a + 1));
        expect(flatMap, isA<Nothing>());
      });
    });

    group('getOrElse', () {
      test('Just', () {
        final maybe = Just(10);
        final value = maybe.getOrElse(() => 0);
        expect(value, 10);
      });

      test('Nothing', () {
        final maybe = Nothing<int>();
        final value = maybe.getOrElse(() => 0);
        expect(value, 0);
      });
    });

    group('alt', () {
      test('Just', () {
        final maybe = Just(10);
        final value = maybe.alt(() => Just(0));
        value.match((just) => expect(just, 10), () => null);
      });

      test('Nothing', () {
        final maybe = Nothing<int>();
        final value = maybe.alt(() => Just(0));
        value.match((just) => expect(just, 0), () => null);
      });
    });

    group('extend', () {
      test('Just', () {
        final maybe = Just(10);
        final value = maybe.extend((t) => t.isJust() ? 'valid' : 'invalid');
        value.match((just) => expect(just, 'valid'), () => null);
      });

      test('Nothing', () {
        final maybe = Nothing<int>();
        final value = maybe.extend((t) => t.isJust() ? 'valid' : 'invalid');
        value.match((just) => expect(just, 'invalid'), () => null);
      });
    });
  });
}
