import 'package:fpdart/fpdart.dart';

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

  final doing = doEffect<void, String, int>(
    (_) async {
      final asyncEV = await _(asyncEither);
      final syncEV = await _(syncEither);
      final syncV = await _(syncC);
      return asyncEV + syncEV + syncV;
    },
  );

  print(doing);

  final run = await doing.runEffect(null);
  print(run);
}
