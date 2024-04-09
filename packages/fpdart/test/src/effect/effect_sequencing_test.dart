import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Effect constructors",
    () {
      test('zipLeft', () {
        final main =
            Effect<Null, String, int>.succeed(10).zipLeft(Effect.succeed("10"));
        final result = main.runSyncOrThrow();
        expect(result, 10);
      });

      test('zipRight', () {
        final main = Effect<Null, String, int>.succeed(10)
            .zipRight(Effect.succeed("10"));
        final result = main.runSyncOrThrow();
        expect(result, "10");
      });

      test('tap', () {
        var mutable = 0;
        final main = Effect<Null, String, int>.succeed(10).tap(
          (_) => Effect.succeedLazy(() {
            mutable += 1;
          }),
        );

        expect(mutable, 0);
        final result = main.runSyncOrThrow();
        expect(result, 10);
        expect(mutable, 1);
      });

      group('race', () {
        test('first wins', () async {
          final first = Effect.sleep<Null, String>(Duration(milliseconds: 50))
              .map((_) => 1);
          final second = Effect.sleep<Null, String>(Duration(milliseconds: 100))
              .map((_) => 2);

          final result = await first.race(second).runFutureOrThrow();
          expect(result, 1);
        });

        test('second wins', () async {
          final first = Effect.sleep<Null, String>(Duration(milliseconds: 100))
              .map((_) => 1);
          final second = Effect.sleep<Null, String>(Duration(milliseconds: 50))
              .map((_) => 2);

          final result = await first.race(second).runFutureOrThrow();
          expect(result, 2);
        });
      });
    },
  );
}
