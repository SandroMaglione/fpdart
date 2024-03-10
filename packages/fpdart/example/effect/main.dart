import 'package:fpdart/fpdart.dart';

void main() async {
  final effect = Effect.tryCatch(
    () => Future.value(10),
    (error, stackTrace) => "10",
  );

  final effect1 = Effect.function(() => 10);

  final doing = doEffect<int, String, int>(
    (_) async {
      final env = await _(Effect.ask());
      final beforeEnv = await _(effect.withEnv(identity));
      final e1 = await _(effect1.mapLeft((l) => "null").withEnv(identity));

      final mapped = await _(effect.map((r) => r + 10).withEnv(identity));
      final asEither = await _(NRight<String, int>(10).withEnv<int>());
      final asOption = await _(NSome<int>(10).withEnv(() => "Some"));
      return beforeEnv + mapped + asEither + asOption + e1;
    },
  );

  print(doing);

  final run = await doing(10);
  print(run);
}
