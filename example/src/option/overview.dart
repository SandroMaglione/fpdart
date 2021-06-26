import 'package:fpdart/fpdart.dart';

/// Don't do that! ⚠
double divideI(int x, int y) {
  if (y == 0) {
    throw Exception('Cannot divide by 0!');
  }

  return x / y;
}

/// Error handling using [Option] 🎉
Option<double> divideF(int x, int y) {
  if (y == 0) {
    return none();
  }

  return some(x / y);
}

void main() {
  /// Create an instance of [Some]
  final option = Option.of(10);

  /// Create an instance of [None]
  final none = Option<int>.none();

  /// Map [int] to [String]
  final map = option.map((a) => '$a');

  /// Extract the value from [Option]
  final value = option.getOrElse(() => -1);

  /// Pattern matching
  final match = option.match(
    (a) => print('Some($a)'),
    () => print('None'),
  );

  /// Convert to [Either]
  final either = option.toEither(() => 'missing');

  /// Chain computations
  final flatMap = option.flatMap((a) => Option.of(a + 10));

  /// Return [None] if the function throws an error
  final tryCatch = Option.tryCatch(() => int.parse('invalid'));
}
