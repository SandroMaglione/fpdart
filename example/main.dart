import 'package:fpdart/fpdart.dart';

void main() {}

void overview() {
  /// [Option]
  const int? a = null;
  final Option<int> b = none<int>();

  /// You must manually handle missing values
  int resultI = 0;
  if (a != null) {
    resultI = a * 2;
  }

  /// No need to check for `null`
  final resultF = b.getOrElse(() => 0) * 2;
}

void imperativeVSfunctional() {
  /// Sum elements of a list
  const List<int> list = [1, 2, 3, 4];

  /// Imperative solution
  int sumI = 0;
  for (int i = 0; i < list.length; ++i) {
    sumI = sumI + list[i];
  }

  /// Functional solution
  final sumF = list.fold<int>(0, (p, c) => p + c);

  /// Composability
  /// Sum all elements of a list that are greater than 2
  /// Imperative solution
  int sum2I = 0;
  for (int i = 0; i < list.length; ++i) {
    final value = list[i];
    if (value > 2) {
      sum2I = sum2I + value;
    }
  }

  /// Functional solution
  final sum2F = list.where((e) => e > 2).fold<int>(0, (p, c) => p + c);

  /// Extreme example
  ///
  /// How can you achieve the same result with Imperative code?
  /// Is it even possible? 🤷‍♂️
  final result = list
      .where((e) => e > 2)
      .plus([1, 2, 3])
      .drop(2)
      .intersect([1, 2, 3])
      .map((e) => e * 2)
      .take(3)
      .first;
}

void option() {
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

  /// Convert to [Option]
  final option = right.toOption();
}
