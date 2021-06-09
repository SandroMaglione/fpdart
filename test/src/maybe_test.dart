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

      test('Alt', () {
        final maybe = Just(10);
        expect(maybe, isA<Alt>());
      });

      test('Extend', () {
        final maybe = Just(10);
        expect(maybe, isA<Extend>());
      });

      test('Filterable', () {
        final maybe = Just(10);
        expect(maybe, isA<Filterable>());
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

    group('filter', () {
      test('Just (true)', () {
        final maybe = Just(10);
        final value = maybe.filter((a) => a > 5);
        value.match((just) => expect(just, 10), () => null);
      });

      test('Just (false)', () {
        final maybe = Just(10);
        final value = maybe.filter((a) => a < 5);
        expect(value, isA<Nothing>());
      });

      test('Nothing', () {
        final maybe = Nothing<int>();
        final value = maybe.filter((a) => a > 5);
        expect(value, isA<Nothing>());
      });
    });

    group('filterMap', () {
      test('Just', () {
        final maybe = Just(10);
        final value = maybe.filterMap<String>((a) => Just('$a'));
        value.match((just) => expect(just, '10'), () => null);
      });

      test('Nothing', () {
        final maybe = Nothing<int>();
        final value = maybe.filterMap<String>((a) => Just('$a'));
        expect(value, isA<Nothing>());
      });
    });

    group('partition', () {
      test('Just', () {
        final maybe = Just(10);
        final value = maybe.partition((a) => a > 5);
        expect(value.value1, isA<Nothing>());
        value.value2.match((just) => expect(just, 10), () => null);
      });

      test('Nothing', () {
        final maybe = Nothing<int>();
        final value = maybe.partition((a) => a > 5);
        expect(value.value1, isA<Nothing>());
        expect(value.value2, isA<Nothing>());
      });
    });

    group('partitionMap', () {
      test('Just (right)', () {
        final maybe = Just(10);
        final value =
            maybe.partitionMap<String, double>((a) => Either.of(a / 2));
        expect(value.value1, isA<Nothing>());
        value.value2.match((just) => expect(just, 5.0), () => null);
      });

      test('Just (left)', () {
        final maybe = Just(10);
        final value =
            maybe.partitionMap<String, double>((a) => Either.left('$a'));
        value.value1.match((just) => expect(just, '10'), () => null);
        expect(value.value2, isA<Nothing>());
      });

      test('Nothing', () {
        final maybe = Nothing<int>();
        final value =
            maybe.partitionMap<String, double>((a) => Either.of(a / 2));
        expect(value.value1, isA<Nothing>());
        expect(value.value2, isA<Nothing>());
      });
    });
  });
}
