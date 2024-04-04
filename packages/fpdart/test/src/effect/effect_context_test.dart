import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

import "../test_extension.dart";

class CustomError implements Exception {
  const CustomError();
}

void main() {
  group(
    "Effect context",
    () {
      group('provideEnv', () {
        test('handle throw in closing scope', () async {
          final main = Effect<Null, String, int>.succeed(10)
              .addFinalizer(Effect.succeedLazy(
                () => throw const CustomError(),
              ))
              .provideEnv(Scope.withEnv(null));

          final result = await main.runFutureExit();

          result.expectLeft((value) {
            expect(value, isA<Die>());
            if (value is Die) {
              expect(value.error, isA<CustomError>());
            }
          });
        });

        test('handle failure in closing scope', () async {
          final main = Effect<Null, String, int>.succeed(10)
              .addFinalizer(Effect.die(const CustomError()))
              .provideEnv(Scope.withEnv(null));

          final result = await main.runFutureExit();

          result.expectLeft((value) {
            expect(value, isA<Die>());
            if (value is Die) {
              expect(value.error, isA<CustomError>());
            }
          });
        });
      });

      group('provideScope', () {
        test('handle throw in closing scope', () async {
          final main = Effect<Null, String, int>.succeed(10)
              .addFinalizer(Effect.succeedLazy(
                () => throw const CustomError(),
              ))
              .provideScope;

          final result = await main.runFutureExit();

          result.expectLeft((value) {
            expect(value, isA<Die>());
            if (value is Die) {
              expect(value.error, isA<CustomError>());
            }
          });
        });

        test('handle failure in closing scope', () async {
          final main = Effect<Null, String, int>.succeed(10)
              .addFinalizer(Effect.die(const CustomError()))
              .provideScope;

          final result = await main.runFutureExit();

          result.expectLeft((value) {
            expect(value, isA<Die>());
            if (value is Die) {
              expect(value.error, isA<CustomError>());
            }
          });
        });
      });
    },
  );
}
