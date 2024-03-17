import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

class CustomError implements Exception {}

void main() {
  group(
    "Effect alternatives",
    () {
      group('orDie', () {
        test('succeed', () {
          final main = Effect.succeed(10).orDie;
          final result = main.runSync(null);
          expect(result, 10);
        });

        test('fail', () {
          final main = Effect.fail(10).orDie;
          expect(() => main.runSync(null), throwsA(isA<Die>()));
        });
      });

      group('orDieWith', () {
        test('succeed', () {
          final main = Effect.succeed(10).orDieWith((_) => CustomError());
          final result = main.runSync(null);
          expect(result, 10);
        });

        test('fail', () {
          final main = Effect.fail(10).orDieWith((_) => CustomError());
          expect(() => main.runSync(null), throwsA(isA<Die>()));
        });
      });
    },
  );
}
