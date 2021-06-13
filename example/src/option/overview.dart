import 'package:fpdart/fpdart.dart';

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
