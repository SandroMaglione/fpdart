// ignore_for_file: avoid_print, unused_local_variable

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
  // --- Initialize an Option 👇 --- //
  const someInit = Some(10);
  const noneInit = None<int>();

  final someInit2 = some(10);
  final noneInit2 = none<int>();

  /// Create an instance of [Some]
  final option = Option.of(10);

  /// Create an instance of [None]
  final noneInit3 = Option<int>.none();

  /// If the predicate is `true`, then [Some], otherwise [None]
  final predicate = Option<int>.fromPredicate(10, (a) => a > 5);

  /// If no exception, then [Some], otherwise [None]
  final tryCatchInit = Option<int>.tryCatch(() => int.parse('10'));

  /// When the value is not `null`, then [Some], otherwise [None]
  final nullable = Option<int>.fromNullable(10);

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
