import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/effect.dart';

void main() async {
  final effect = Effect.tryFuture(
    () => Future.value(10),
    (error, stackTrace) => "10",
  );

  final doing = doEffect<void, String, int>(
    (_) async {
      final eitherV = await _(NRight(10));
      final eV = await _(effect);
      return eitherV + eV;
    },
  );

  print(doing);

  final run = await doing(null);
  print(run);
}
