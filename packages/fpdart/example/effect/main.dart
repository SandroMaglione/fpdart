import 'package:fpdart/fpdart.dart';

void main() async {
  final effect = Effect.tryFuture(
    () => Future.value(10),
    (error, stackTrace) => "10",
  );

  final doing = doEffect<int, String, int>(
    (_) async {
      final env = await _(Effect.ask());
      final beforeEnv = await _(effect.withEnv(identity));
      final mapped = await _(effect.map((r) => r + 10).withEnv(identity));
      final asEither = await _(NRight<String, int>(10).withEnv<int>());
      return beforeEnv + mapped + asEither;
    },
  );

  print(doing);

  final run = await doing(10);
  print(run);
}
