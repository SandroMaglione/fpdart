import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Effect error handling",
    () {
      group('catchCause', () {
        test('recover from throw', () {
          final result = Effect<Null, Never, String>.functionSucceed(() {
            throw "fail";
          })
              .catchCause(
                (cause) => Effect.succeed("abc"),
              )
              .runSync();

          expect(result, "abc");
        });
      });
    },
  );
}
