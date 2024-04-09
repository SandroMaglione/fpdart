import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Effect constructors",
    () {
      test('succeed', () {
        final main = Effect<Null, String, int>.succeed(10);
        final result = main.runSyncOrThrow();
        expect(result, 10);
      });

      test('fail', () {
        final main = Effect<Null, String, int>.fail("error");
        final result = main.flip().runSyncOrThrow();
        expect(result, "error");
      });

      group('async', () {
        test('succeed callback', () async {
          final main = Effect<Null, String, int>.async(
            (resume) => resume.succeed(10),
          );
          final result = await main.runFutureOrThrow();
          expect(result, 10);
        });

        test('fail callback', () async {
          final main = Effect<Null, String, int>.async(
            (resume) => resume.fail("error"),
          );
          final result = await main.flip().runFutureOrThrow();
          expect(result, "error");
        });

        test('succeed async callback', () async {
          final main = Effect<Null, String, int>.async(
            (resume) => Future.delayed(Duration(milliseconds: 100)).then(
              (_) => resume.succeed(10),
            ),
          );
          final result = await main.runFutureOrThrow();
          expect(result, 10);
        });

        test('fail async callback', () async {
          final main = Effect<Null, String, int>.async(
            (resume) => Future.delayed(Duration(milliseconds: 100)).then(
              (_) => resume.fail("error"),
            ),
          );
          final result = await main.flip().runFutureOrThrow();
          expect(result, "error");
        });
      });

      group('tryCatch', () {
        test('executes once', () {
          var mutable = 0;
          final main = Effect<Null, void, int>.tryCatch(
            execute: () {
              mutable += 1;
              return 10;
            },
            onError: (error, stackTrace) {},
          );

          main.runSyncOrThrow();
          expect(mutable, 1);
        });

        test('async', () async {
          final main = Effect<Null, void, int>.tryCatch(
            execute: () async => 10,
            onError: (error, stackTrace) {},
          );
          final result = await main.runFutureOrThrow();
          expect(result, 10);
        });

        test('sync', () {
          final main = Effect<Null, void, int>.tryCatch(
            execute: () => 10,
            onError: (error, stackTrace) {},
          );
          final result = main.runSyncOrThrow();
          expect(result, 10);
        });
      });

      group('gen', () {
        test('sync succeed', () {
          final main = Effect<Null, Never, int>.gen(($) {
            final value = $.sync(Effect.succeed(10));
            return value;
          });
          final result = main.runSyncOrThrow();
          expect(result, 10);
        });

        test('sync fail', () {
          final main = Effect<Null, String, int>.gen(($) {
            final value = $.sync(Effect.fail("abc"));
            return value;
          });
          final result = main.flip().runSyncOrThrow();
          expect(result, "abc");
        });

        test('async succeed', () async {
          final main = Effect<Null, Never, int>.gen(($) async {
            final value =
                await $.async(Effect.succeedLazy(() => Future.value(10)));
            return value;
          });
          final result = await main.runFutureOrThrow();
          expect(result, 10);
        });

        test('fail when running async as sync', () async {
          final main = Effect<Null, Never, int>.gen(($) {
            final value = $.sync(Effect.succeedLazy(
              () async => Future.value(10),
            ));
            return value;
          });

          expect(() => main.runSyncOrThrow(), throwsA(isA<Die>()));
        });
      });
    },
  );
}
