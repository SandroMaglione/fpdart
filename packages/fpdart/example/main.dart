import 'package:fpdart/fpdart.dart';

typedef Env = ({String url, int seed});
typedef Error = String;
typedef Success = int;

final either = Right<Error, Success>(10);
final option = Some(10);

final effect = Effect<Env, Error, Success>.gen(($) {
  final eitherValue = $.sync(either);
  final optionValue = $.sync(option);
  return eitherValue + optionValue;
});
