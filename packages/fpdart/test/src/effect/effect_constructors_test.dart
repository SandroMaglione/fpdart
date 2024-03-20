import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Effect constructors",
    () {
      test('succeed', () {
        final main = Effect.succeed(10);
        final result = main.runSync(null);
        expect(result, 10);
      });

      test('fail', () {
        final main = Effect.fail(10);
        final result = main.flip.runSync(null);
        expect(result, 10);
      });

      group('tryCatch', () {
        test('executes once', () {
          var mutable = 0;
          final main = Effect.tryCatch(
            execute: () {
              mutable += 1;
              return 10;
            },
            onError: (error, stackTrace) {},
          );

          main.runSync(null);
          expect(mutable, 1);
        });

        test('async', () async {
          final main = Effect.tryCatch(
            execute: () async => 10,
            onError: (error, stackTrace) {},
          );
          final result = await main.runFuture(null);
          expect(result, 10);
        });

        test('sync', () {
          final main = Effect.tryCatch(
            execute: () => 10,
            onError: (error, stackTrace) {},
          );
          final result = main.runSync(null);
          expect(result, 10);
        });

        group('gen', () {
          test('sync succeed', () {
            final main = Effect.gen(($) {
              final value = $.sync(Effect.succeed(10));
              return value;
            });
            final result = main.runSyncNoEnv();
            expect(result, 10);
          });

          test('sync fail', () {
            final main = Effect<Never, String, int>.gen(($) {
              final value = $.sync(Effect.fail("10"));
              return value;
            });
            final result = main.flip.runSyncNoEnv();
            expect(result, "10");
          });

          test('async succeed', () async {
            final main = Effect.gen(($) async {
              final value =
                  await $.async(Effect.function(() => Future.value(10)));
              return value;
            });
            final result = await main.runFutureNoEnv();
            expect(result, 10);
          });

          test('fail when running async as sync', () async {
            final main = Effect.gen(($) {
              final value = $.sync(Effect.function(
                () async => Future.value(10),
              ));
              return value;
            });

            expect(() => main.runSyncNoEnv(), throwsA(isA<Die>()));
          });
        });
      });
    },
  );
}
