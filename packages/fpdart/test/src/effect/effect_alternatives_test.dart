import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

class CustomError implements Exception {}

void main() {
  group(
    "Effect alternatives",
    () {
      group('orDie', () {
        test('succeed', () {
          final main = Effect<Null, String, int>.succeed(10).orDie;
          final result = main.runSyncOrThrow();
          expect(result, 10);
        });

        test('fail', () {
          final main = Effect<Null, String, int>.fail("error").orDie;
          expect(() => main.runSyncOrThrow(), throwsA(isA<Die>()));
        });
      });

      group('orDieWith', () {
        test('succeed', () {
          final main = Effect<Null, String, int>.succeed(10)
              .orDieWith((_) => CustomError());
          final result = main.runSyncOrThrow();
          expect(result, 10);
        });

        test('fail', () {
          final main = Effect<Null, String, int>.fail("error")
              .orDieWith((_) => CustomError());
          expect(() => main.runSyncOrThrow(), throwsA(isA<Die>()));
        });
      });
    },
  );
}
