import 'package:fpdart/fpdart.dart';

/// Don't do that! ⚠
double divideI(int x, int y) {
  if (y == 0) {
    throw Exception('Cannot divide by 0!');
  }

  return x / y;
}

/// Error handling using [Either] 🎉
Either<String, double> divideF(int x, int y) {
  if (y == 0) {
    return left('Cannot divide by 0');
  }

  return right(x / y);
}

void main() {
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

  /// Convert to [Option]
  final option = right.toOption();
}
