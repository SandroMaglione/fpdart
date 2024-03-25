import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Effect collecting",
    () {
      group('all', () {
        test('succeeded all', () {
          final main = Effect.all<Null, String, int>([
            Effect.succeed(10),
            Effect.succeed(20),
          ]);
          final result = main.runSync();
          expect(result, [10, 20]);
        });

        test('fail and stop execution', () {
          var mutable = 0;
          final main = Effect.all<Null, String, int>([
            Effect.succeed(10),
            Effect.fail("10"),
            Effect.functionSucceed(() => mutable += 1),
            Effect.fail("0"),
          ]);
          final result = main.flip().runSync();
          expect(mutable, 0);
          expect(result, "10");
        });
      });
    },
  );
}
