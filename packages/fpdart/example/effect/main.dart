import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/effect.dart';

void main() async {
  final asyncEither = AsyncEither.tryFuture(
    () async => 10,
    (_, __) => "",
  );

  final syncEither = SyncEither.trySync(
    () => 10,
    (_, __) => "",
  );

  final syncC = Sync.make(() => 10).flatMap(
    (r) => Sync.value(r + 20),
  );

  final asyncC = Async.make(() => 10).flatMap(
    (r) => Async.value(r + 20),
  );

  final doing = doEffect<void, String, int>(
    (_) async {
      final asyncEV = await _(asyncEither);
      // await _(NLeft("10"));
      final syncEV = await _(syncEither);
      final syncV = await _(syncC);
      final asyncV = await _(asyncC);
      final eitherV = await _(NRight(10));
      return asyncEV + syncEV + syncV + eitherV + asyncV;
    },
  );

  print(doing);

  final run = await doing(null);
  print(run);
}
