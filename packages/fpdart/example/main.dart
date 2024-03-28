import 'package:fpdart/fpdart.dart';

typedef Env = ({String url, int seed});
typedef Error = String;
typedef Success = int;

final either = Right<Error, Success>(10);
final option = Some(10);

final effect = Effect<Env, Error, Success>.gen(($) async {
  final eitherValue = $.sync(either);
  final optionValue = $.sync(option);
  final deferred = $.sync(Deferred.make<Error, Success>().withEnv());
  final value = await $.async(deferred.future());
  return eitherValue + optionValue;
});
