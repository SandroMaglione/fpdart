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
    },
  );
}
