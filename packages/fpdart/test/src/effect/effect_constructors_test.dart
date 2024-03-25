import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Effect constructors",
    () {
      test('succeed', () {
        final main = Effect<Null, String, int>.succeed(10);
        final result = main.runSync();
        expect(result, 10);
      });

      test('fail', () {
        final main = Effect<Null, String, int>.fail("error");
        final result = main.flip().runSync();
        expect(result, "error");
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

          main.runSync();
          expect(mutable, 1);
        });

        test('async', () async {
          final main = Effect<Null, void, int>.tryCatch(
            execute: () async => 10,
            onError: (error, stackTrace) {},
          );
          final result = await main.runFuture();
          expect(result, 10);
        });

        test('sync', () {
          final main = Effect<Null, void, int>.tryCatch(
            execute: () => 10,
            onError: (error, stackTrace) {},
          );
          final result = main.runSync();
          expect(result, 10);
        });
      });

      group('gen', () {
        test('sync succeed', () {
          final main = Effect<Null, Never, int>.gen(($) {
            final value = $.sync(Effect.succeed(10));
            return value;
          });
          final result = main.runSync();
          expect(result, 10);
        });

        test('sync fail', () {
          final main = Effect<Null, String, int>.gen(($) {
            final value = $.sync(Effect.fail("abc"));
            return value;
          });
          final result = main.flip().runSync();
          expect(result, "abc");
        });

        test('async succeed', () async {
          final main = Effect<Null, Never, int>.gen(($) async {
            final value =
                await $.async(Effect.functionSucceed(() => Future.value(10)));
            return value;
          });
          final result = await main.runFuture();
          expect(result, 10);
        });

        test('fail when running async as sync', () async {
          final main = Effect<Null, Never, int>.gen(($) {
            final value = $.sync(Effect.functionSucceed(
              () async => Future.value(10),
            ));
            return value;
          });

          expect(() => main.runSync(), throwsA(isA<Die>()));
        });
      });
    },
  );
}
