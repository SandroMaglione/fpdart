import 'package:fpdart/fpdart.dart';

typedef Env = (int, String);
typedef Error = String;
typedef Success = String;

void main(List<String> args) async {
  final rte = ReaderTaskEither<Env, Error, Success>.Do(($) async {
    final a = 10;
    final val = await $(ReaderTaskEither.rightReader(
      Reader(
        (env) => env.$1 + env.$2.length,
      ),
    ));
    final env = await $(ReaderTaskEither.ask());
    final env2 = await $(ReaderTaskEither.asks((dep) => dep.$2));

    return "$a and $val and $env and $env2";
  });

  final result = await rte.run((30, "abc"));
  print(result);
}
