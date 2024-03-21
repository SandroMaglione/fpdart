import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Effect constructors",
    () {
      test('zipLeft', () {
        final main = Effect.succeed(10).zipLeft(Effect.succeed("10"));
        final result = main.runSync(null);
        expect(result, 10);
      });

      test('zipRight', () {
        final main = Effect.succeed(10).zipRight(Effect.succeed("10"));
        final result = main.runSync(null);
        expect(result, "10");
      });

      test('tap', () {
        var mutable = 0;
        final main = Effect.succeed(10).tap(
          (_) => Effect.function(() {
            mutable += 1;
          }),
        );

        expect(mutable, 0);
        final result = main.runSync(null);
        expect(result, 10);
        expect(mutable, 1);
      });
    },
  );
}