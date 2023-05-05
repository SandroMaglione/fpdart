import 'package:fpdart/fpdart.dart';

int? getNoEither(int index, List<int> list) {
  if (index < 0 || index >= list.length) {
    return null;
  }

  return list[index];
}

Either<String, int> getEither(int index, List<int> list) {
  if (index < 0 || index >= list.length) {
    return Either.left('index not valid');
  }

  return Either.of(list[index]);
}

int multiply(int value) => value * 2;

void main() {
  const list = [1, 2, 3];

  /// Without [Either], you must check that the value is not null.
  /// You must also remember to handle the case in which the value is null,
  /// what would happen then?
  final noEither = getNoEither(-1, list);
  if (noEither != null) {
    print(multiply(noEither));
  }

  /// With [Either], you are required to handle all cases. You will never run
  /// in unspecified edge cases.
  final withEither = getEither(-1, list);
  withEither.match((l) => print(l), (r) => print(multiply(r)));
}
