import '../either.dart';
import '../option.dart';
import 'nullable_extension.dart';

/// Functional programming functions on dart [String] using `fpdart`.
extension FpdartOnString on String {
  /// Convert this [String] to [num], returns [None] for invalid inputs.
  Option<num> get toNumOption => num.tryParse(this).toOption();

  /// Convert this [String] to [int], returns [None] for invalid inputs.
  Option<int> get toIntOption => int.tryParse(this).toOption();

  /// Convert this [String] to [double], returns [None] for invalid inputs.
  Option<double> get toDoubleOption => double.tryParse(this).toOption();

  /// Convert this [String] to [bool], returns [None] for invalid inputs.
  Option<bool> get toBooleanOption => bool.tryParse(this).toOption();

  /// Convert this [String] to [num], returns the result of `onLeft` for invalid inputs.
  Either<L, num> toNumEither<L>(L Function() onLeft) =>
      num.tryParse(this).toEither(onLeft);

  /// Convert this [String] to [int], returns the result of `onLeft` for invalid inputs.
  Either<L, int> toIntEither<L>(L Function() onLeft) =>
      int.tryParse(this).toEither(onLeft);

  /// Convert this [String] to [double], returns the result of `onLeft` for invalid inputs.
  Either<L, double> toDoubleEither<L>(L Function() onLeft) =>
      double.tryParse(this).toEither(onLeft);

  /// Convert this [String] to [bool], returns the result of `onLeft` for invalid inputs.
  Either<L, bool> toBooleanEither<L>(L Function() onLeft) =>
      bool.tryParse(this).toEither(onLeft);
}
