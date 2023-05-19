import '../either.dart';
import '../option.dart';
import 'nullable_extension.dart';

/// Functional programming functions on dart [String] using `fpdart`.
extension FpdartOnString on String {
  /// {@macro fpdart_string_extension_to_num_option}
  Option<num> get toNumOption => num.tryParse(this).toOption();

  /// {@macro fpdart_string_extension_to_int_option}
  Option<int> get toIntOption => int.tryParse(this).toOption();

  /// {@macro fpdart_string_extension_to_double_option}
  Option<double> get toDoubleOption => double.tryParse(this).toOption();

  /// {@macro fpdart_string_extension_to_bool_option}
  Option<bool> get toBoolOption => bool.tryParse(this).toOption();

  /// {@macro fpdart_string_extension_to_num_either}
  Either<L, num> toNumEither<L>(L Function() onLeft) =>
      num.tryParse(this).toEither(onLeft);

  /// {@macro fpdart_string_extension_to_int_either}
  Either<L, int> toIntEither<L>(L Function() onLeft) =>
      int.tryParse(this).toEither(onLeft);

  /// {@macro fpdart_string_extension_to_double_either}
  Either<L, double> toDoubleEither<L>(L Function() onLeft) =>
      double.tryParse(this).toEither(onLeft);

  /// {@macro fpdart_string_extension_to_bool_either}
  Either<L, bool> toBoolEither<L>(L Function() onLeft) =>
      bool.tryParse(this).toEither(onLeft);
}
