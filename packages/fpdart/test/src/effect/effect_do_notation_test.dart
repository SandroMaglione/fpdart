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
          final result = program.runSync();
          expect(result, 3);
        });
      });

      group('provideEffect', () {
        test('valid dependency', () {
          final main = Effect<int, String, int>.gen(($) {
            final env = $.sync(Effect.env());
            return env + 1;
          });

          final program =
              main.provideEffect(Effect<Null, String, int>.succeed(10));
          final result = program.runSync();
          expect(result, 11);
        });

        test('invalid dependency', () {
          final main = Effect<int, String, int>.gen(($) {
            final env = $.sync(Effect.env());
            return env + 1;
          });

          final program =
              main.provideEffect(Effect<Null, String, int>.fail("error"));
          final result = program.flip().runSync();
          expect(result, "error");
        });
      });

      group('mapEnv', () {
        test('adapt dependency from another program', () {
          final subMain = Effect<int, String, int>.from(
              (context) => Right(context.env + 1));
          final main = Effect<String, String, int>.gen(($) {
            final value = $.sync(
                subMain.mapEnv((context) => Context.env(context.env.length)));
            return value;
          });

          final result = main.provide("abc").runSync();
          expect(result, 4);
        });
      });
    },
  );
}
