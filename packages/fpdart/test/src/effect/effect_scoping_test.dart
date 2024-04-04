import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

class CustomError implements Exception {}

void main() {
  group(
    "Effect scoping",
    () {
      test('add and release Scope finalizer', () async {
        var mutable = 0;
        final main = Effect<Null, String, int>.succeed(10).addFinalizer(
          Effect.succeedLazy(() {
            mutable += 1;
            return unit;
          }),
        ).provideScope;

        await main.runFuture();
        expect(mutable, 1);
      });

      test('closable Scope', () async {
        final scope = Scope.withEnv(true, closable: true);
        var mutable = 0;
        final main = Effect<bool, String, int>.succeed(10).addFinalizer(
          Effect.succeedLazy(() {
            mutable += 1;
            return unit;
          }),
        );

        await main.provide(Context.env(scope)).runFuture();
        expect(mutable, 0);
        scope.closeScope<Null, Never>().runSync();
        expect(mutable, 1);
      });

      group('acquireRelease', () {
        test('release when successful', () async {
          var mutable = 0;
          final main = Effect<Null, String, int>.succeed(10)
              .acquireRelease(
                (r) => Effect.succeedLazy(() {
                  mutable = r;
                  return unit;
                }),
              )
              .provideScope;

          await main.runFuture();
          expect(mutable, 10);
        });

        test('no release when failed', () async {
          var mutable = 0;
          final main = Effect<Null, String, int>.fail("error")
              .acquireRelease(
                (r) => Effect.succeedLazy(() {
                  mutable = r;
                  return unit;
                }),
              )
              .provideScope;

          await main.flip().runFuture();
          expect(mutable, 0);
        });
      });
    },
  );
}
