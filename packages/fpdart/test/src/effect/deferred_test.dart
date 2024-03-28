import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Deferred', () {
    group('future', () {
      test('suspends and awaits future', () async {
        final main = Effect<Null, String, int>.gen(($) async {
          final deferred = $.sync(Deferred.make<String, int>());
          await $.async(Effect.raceAll([
            Effect.sleep<Null, String>(Duration(milliseconds: 100))
                .zipRight(deferred.completeExit(Right(1))),
            Effect.sleep<Null, String>(Duration(milliseconds: 150))
                .zipRight(deferred.completeExit(Right(2))),
          ]));

          final value = await $.async(deferred.future());
          return value;
        });

        final result = await main.runFuture();
        expect(result, 1);
      });
    });
  });
}
