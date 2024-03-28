import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Effect interruption",
    () {
      group('interrupt', () {
        test('fail with Cause.Interrupted', () {
          final main = Effect<Null, String, int>.succeed(10).interrupt().map(
                (r) => r + 10,
              );

          final result = main.runSyncExit();
          switch (result) {
            case Right():
              fail("Either expected to be Left: $result");
            case Left(value: final value):
              expect(value, isA<Interrupted>());
          }
        });
      });
    },
  );
}
