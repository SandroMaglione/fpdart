import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

import "../test_extension.dart";

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

          result.expectLeft((value) {
            expect(value, isA<Interrupted>());
          });
        });
      });
    },
  );
}
