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
  });
}
