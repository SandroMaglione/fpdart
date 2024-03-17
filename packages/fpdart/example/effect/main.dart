import 'package:fpdart/fpdart.dart';

void main() async {
  final effect = Effect<Never, String, int>.tryCatch(
    () => Future.value(10),
    (error, stackTrace) => "10",
  );

  final effect1 = Effect<Never, String, int>.function(() => 10);

  final main = Effect<int, String, int>.gen(
    (_) async {
      final env = await _(Effect.env());
      final beforeEnv = await _(effect.withEnv());
      final e1 = await _(effect1.mapError((l) => "null").withEnv());

      final mapped = await _(effect.map((r) => r + 10).withEnv());
      final asEither = await _(Right<String, int>(10).provide<int>());
      final asOption = await _(Some<int>(10).provide(() => "Some"));
      return beforeEnv + mapped + asEither + asOption + e1;
    },
  );

  print(main);

  final run = await main(10);
  print(run);
}
