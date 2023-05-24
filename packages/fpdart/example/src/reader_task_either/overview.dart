import 'package:fpdart/fpdart.dart';

typedef Env = (int, String);
typedef Error = String;
typedef Success = int;

void main(List<String> args) async {
  final rte = ReaderTaskEither<Env, Error, Success>.Do(($) async {
    final a = 10;
    final val = await $(ReaderTaskEither.rightReader(
      Reader(
        (env) => env.$1 + env.$2.length,
      ),
    ));

    return a + val;
  });

  final result = await rte.run((30, "abc"));
  print(result);
}
