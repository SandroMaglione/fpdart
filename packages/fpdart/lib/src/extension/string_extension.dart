import '../either.dart';
import '../option.dart';

/// Functional programming functions on dart [String] using `fpdart`.
extension FpdartOnString on String {
  /// {@macro fpdart_string_extension_to_num_option}
  Option<num> get toNumOption => Option.fromNullable(num.tryParse(this));

  /// {@macro fpdart_string_extension_to_int_option}
  Option<int> get toIntOption => Option.fromNullable(int.tryParse(this));

  /// {@macro fpdart_string_extension_to_double_option}
  Option<double> get toDoubleOption =>
      Option.fromNullable(double.tryParse(this));

  /// {@macro fpdart_string_extension_to_bool_option}
  Option<bool> get toBoolOption => Option.fromNullable(bool.tryParse(this));

  /// {@macro fpdart_string_extension_to_num_either}
  Either<L, num> toNumEither<L>(L Function() onLeft) =>
      Either.fromNullable(num.tryParse(this), onLeft);

  /// {@macro fpdart_string_extension_to_int_either}
  Either<L, int> toIntEither<L>(L Function() onLeft) =>
      Either.fromNullable(int.tryParse(this), onLeft);

  /// {@macro fpdart_string_extension_to_double_either}
  Either<L, double> toDoubleEither<L>(L Function() onLeft) =>
      Either.fromNullable(double.tryParse(this), onLeft);

  /// {@macro fpdart_string_extension_to_bool_either}
  Either<L, bool> toBoolEither<L>(L Function() onLeft) =>
      Either.fromNullable(bool.tryParse(this), onLeft);
}
