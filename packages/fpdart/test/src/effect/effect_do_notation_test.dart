import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Effect do notation",
    () {
      group('provide', () {
        test('remove dependency', () {
          final main = Effect<String, String, int>.gen(($) {
            final env = $.sync(Effect.env());
            return env.length;
          });

          final program = main.provide("abc");
          final result = program.runSyncVoid();
          expect(result, 3);
        });
      });

      group('mapEnv', () {
        test('adapt dependency from another program', () {
          final subMain =
              Effect<int, String, int>.from((env) => Right(env + 1));
          final main = Effect<String, String, int>.gen(($) {
            final value = $.sync(subMain.mapEnv((env) => env.length));
            return value;
          });

          final result = main.runSync("abc");
          expect(result, 4);
        });
      });
    },
  );
}
