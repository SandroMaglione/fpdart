import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/either.dart';
import 'package:test/test.dart';

void main() {
  group('Either', () {
    group('map', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final map = value.map((a) => a + 1);
        map.match((l) => null, (r) => expect(r, 11));
      });

      test('Left', () {
        final value = Left<String, int>('abc');
        final map = value.map((a) => a + 1);
        map.match((l) => expect(l, 'abc'), (r) => null);
      });
    });

    group('mapLeft', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final map = value.mapLeft((a) => 'pre-$a');
        map.match((l) => null, (r) => expect(r, 10));
      });

      test('Left', () {
        final value = Left<String, int>('abc');
        final map = value.mapLeft((a) => 'pre-$a');
        map.match((l) => expect(l, 'pre-abc'), (r) => null);
      });
    });

    group('foldRight', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final fold = value.foldRight<int>(10, (a, b) => a + b);
        expect(fold, 20);
      });

      test('Left', () {
        final value = Left<String, int>('abc');
        final fold = value.foldRight<int>(10, (a, b) => a + b);
        expect(fold, 10);
      });
    });

    group('fold', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final fold = value.fold<int>(10, (a, b) => a + b);
        expect(fold, 20);
      });

      test('Left', () {
        final value = Left<String, int>('abc');
        final fold = value.fold<int>(10, (a, b) => a + b);
        expect(fold, 10);
      });
    });

    group('foldMap', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final fold = value.foldMap<int>(
            Monoid.instance(0, (a1, a2) => a1 + a2), (a) => a);
        expect(fold, 10);
      });

      test('Left', () {
        final value = Left<String, int>('abc');
        final fold = value.foldMap<int>(
            Monoid.instance(0, (a1, a2) => a1 + a2), (a) => a);
        expect(fold, 0);
      });
    });

    group('ap', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final ap = value.ap(Right<String, int Function(int)>((n) => n + 1));
        ap.match((l) => null, (r) => expect(r, 11));
      });

      test('Left', () {
        final value = Right<String, int>(10);
        final ap = value.ap(Left<String, int Function(int)>('none'));
        ap.match((l) => expect(l, 'none'), (r) => null);
      });
    });

    group('flatMap', () {
      group('Right', () {
        test('then Right', () {
          final value = Right<String, int>(10);
          final ap = value.flatMap<String>((a) => Right('$a'));
          ap.match((l) => null, (r) => expect(r, '10'));
        });

        test('then Left', () {
          final value = Right<String, int>(10);
          final ap = value.flatMap<String>((a) => Left('none'));
          ap.match((l) => expect(l, 'none'), (r) => null);
        });
      });

      group('Left', () {
        test('then Right', () {
          final value = Left<String, int>('0');
          final ap = value.flatMap<String>((a) => Right('$a'));
          ap.match((l) => expect(l, '0'), (r) => null);
        });

        test('then Left', () {
          final value = Left<String, int>('0');
          final ap = value.flatMap<String>((a) => Left('none'));
          ap.match((l) => expect(l, '0'), (r) => null);
        });
      });
    });

    group('toMaybe', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final ap = value.toMaybe();
        ap.match((just) => expect(just, 10), () => null);
      });

      test('Left', () {
        final value = Left<String, int>('none');
        final ap = value.toMaybe();
        expect(ap, isA<Nothing>());
      });
    });

    group('isLeft', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final ap = value.isLeft();
        expect(ap, false);
      });

      test('Left', () {
        final value = Left<String, int>('none');
        final ap = value.isLeft();
        expect(ap, true);
      });
    });

    group('isRight', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final ap = value.isRight();
        expect(ap, true);
      });

      test('Left', () {
        final value = Left<String, int>('none');
        final ap = value.isRight();
        expect(ap, false);
      });
    });

    group('swap', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final ap = value.swap();
        ap.match((l) => expect(l, 10), (r) => null);
      });

      test('Left', () {
        final value = Left<String, int>('none');
        final ap = value.swap();
        ap.match((l) => null, (r) => expect(r, 'none'));
      });
    });

    group('andThen', () {
      test('Right', () {
        final value = Right<String, int>(10);
        final ap = value.andThen(() => Right('10'));
        ap.match((l) => null, (r) => expect(r, '10'));
      });

      test('Left', () {
        final value = Left<String, int>('none');
        final ap = value.andThen(() => Right('10'));
        ap.match((l) => expect(l, 'none'), (r) => null);
      });
    });

    group('toString', () {
      test('Right', () {
        final value = Right<String, int>(10);
        expect(value.toString(), 'Right(10)');
      });

      test('Left', () {
        final value = Left<String, int>('none');
        expect(value.toString(), 'Left(none)');
      });
    });
  });
}
