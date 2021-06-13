import 'package:fpdart/fpdart.dart';

void main() {
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
