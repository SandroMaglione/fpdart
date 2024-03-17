import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Effect collecting",
    () {
      test('all', () {
        final main = Effect.all([
          Effect.succeed(10),
          Effect.succeed(20),
        ]);
        final result = main.runSync(null);
        expect(result, [10, 20]);
      });
    },
  );
}
