import 'package:fpdart/fpdart.dart';

/// Don't do that! ⚠
int divideI(int x, int y) => x ~/ y; // this will throw if y == 0

/// Error handling without exceptions using [Option] 🎉
Option<int> divideF(int x, int y) {
  if (y == 0) {
    return none();
  }
  return some(x ~/ y);
}

/// Error handling with exceptions using [Option] 🎉
Option<int> divide2F(int x, int y) => Option.tryCatch(() => x ~/ y);

void main() {
  // --- Initialize an Option 👇 --- //
  const someInit = Some(10);
  const noneInit = None();

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
    () => print('None'),
    (a) => print('Some($a)'),
  );

  /// or use Dart's pattern matching as well 🤝
  final dartMatch = switch (option) {
    None() => 'None',
    Some(value: final a) => 'Some($a)',
  };

  /// Convert to [Either]
  final either = option.toEither(() => 'missing');

  /// Chain computations
  final flatMap = option.flatMap((a) => Option.of(a + 10));

  /// Return [None] if the function throws an error
  final tryCatch = Option.tryCatch(() => int.parse('invalid'));
}
