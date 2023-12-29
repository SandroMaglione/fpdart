import 'package:fpdart_effect/src/effect.dart';
import 'package:test/test.dart';

void main() {
  group('Effect', () {
    group('[Create]', () {
      group('succeed', () {
        test('should return the given success value', () {
          final effect = Effect.succeed(10);
          final result = effect.runSync(null);
          expect(result, 10);
        });
      });

      group('fail', () {
        test('should throw with a Failure', () {
          final effect = Effect.fail(10);
          final exec = () => effect.runSync(null);
          expect(exec, throwsA(isA<Exception>()));
        });
      });
    });
  });
}
