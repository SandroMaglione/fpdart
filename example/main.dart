import 'package:fpdart/fpdart.dart';

void main() {}

void maybe() {
  /// Create an instance of [Just]
  final maybe = Maybe.of(10);

  /// Create an instance of [Nothing]
  final nothing = Maybe<int>.nothing();

  /// Map [int] to [String]
  final map = maybe.map((a) => '$a');

  /// Extract the value from [Maybe]
  final value = maybe.getOrElse(() => -1);

  /// Pattern matching
  final match = maybe.match(
    (just) => print('Just($just)'),
    () => print('Nothing'),
  );

  /// Convert to [Either]
  final either = maybe.toEither(() => 'missing');

  /// Chain computations
  final flatMap = maybe.flatMap((a) => Maybe.of(a + 10));

  /// Return [Nothing] if the function throws an error
  final tryCatch = Maybe.tryCatch(() => int.parse('invalid'));
}

void either() {
  /// Create an instance of [Right]
  final right = Either<String, int>.of(10);

  /// Create an instance of [Left]
  final left = Either<String, int>.left('none');

  /// Map the right value to a [String]
  final mapRight = right.map((a) => '$a');

  /// Map the left value to a [int]
  final mapLeft = right.mapLeft((a) => a.length);

  /// Return [Left] if the function throws an error.
  /// Otherwise return [Right].
  final tryCatch = Either.tryCatch(
    () => int.parse('invalid'),
    (e, s) => 'Error: $e',
  );

  /// Extract the value from [Either]
  final value = right.getOrElse((l) => -1);

  /// Chain computations
  final flatMap = right.flatMap((a) => Either.of(a + 10));

  /// Pattern matching
  final match = right.match(
    (l) => print('Left($l)'),
    (r) => print('Right($r)'),
  );

  /// Convert to [Maybe]
  final maybe = right.toMaybe();
}
