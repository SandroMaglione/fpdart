import 'either.dart';
import 'extension/string_extension.dart';
import 'option.dart';

/// Returns the given `a`.
///
/// Shortcut function to return the input parameter:
/// ```dart
/// final either = Either<String, int>.of(10);
///
/// /// Without using `identity`, you must write a function to return
/// /// the input parameter `(l) => l`.
/// final noId = either.match((l) => l, (r) => '$r');
///
/// /// Using `identity`, the function just returns its input parameter.
/// final withIdentity = either.match(identity, (r) => '$r');
/// ```
T identity<T>(T a) => a;

/// Returns the given `a`, wrapped in `Future.value`.
///
/// Same as `idFuture`.
///
/// Shortcut function to return the input parameter:
/// ```dart
/// final either = Either<String, int>.of(10);
///
/// /// Without using `identityFuture`, you must write a function to return
/// /// the input parameter `(l) async => l`.
/// final noId = await either.match((l) async => l, (r) async => '$r');
///
/// /// Using `identityFuture`, the function just returns its input parameter.
/// final withIdentityFuture = either.match(identityFuture, (r) async => '$r');
/// ```
Future<T> identityFuture<T>(T a) => Future.value(a);

/// `constf a` is a unary function which evaluates to `a` for all inputs.
/// ```dart
/// final c = constF<int>(10);
/// print(c('none')); // -> 10
/// print(c('any')); // -> 10
/// print(c(112.12)); // -> 10
/// ```
A Function(dynamic b) constF<A>(A a) => <B>(B b) => a;

/// {@template fpdart_string_extension_to_num_option}
/// Convert this [String] to [num], returns [None] for invalid inputs.
/// {@endtemplate}
Option<num> toNumOption(String str) => str.toNumOption;

/// {@template fpdart_string_extension_to_int_option}
/// Convert this [String] to [int], returns [None] for invalid inputs.
/// {@endtemplate}
Option<int> toIntOption(String str) => str.toIntOption;

/// {@template fpdart_string_extension_to_double_option}
/// Convert this [String] to [double], returns [None] for invalid inputs.
/// {@endtemplate}
Option<double> toDoubleOption(String str) => str.toDoubleOption;

/// {@template fpdart_string_extension_to_bool_option}
/// Convert this [String] to [bool], returns [None] for invalid inputs.
/// {@endtemplate}
Option<bool> toBoolOption(String str) => str.toBoolOption;

/// {@template fpdart_string_extension_to_num_either}
/// Convert this [String] to [num], returns the result of `onLeft` for invalid inputs.
/// {@endtemplate}
Either<L, num> Function(String) toNumEither<L>(L Function() onLeft) =>
    (str) => str.toNumEither(onLeft);

/// {@template fpdart_string_extension_to_int_either}
/// Convert this [String] to [int], returns the result of `onLeft` for invalid inputs.
/// {@endtemplate}
Either<L, int> Function(String) toIntEither<L>(L Function() onLeft) =>
    (str) => str.toIntEither(onLeft);

/// {@template fpdart_string_extension_to_double_either}
/// Convert this [String] to [double], returns the result of `onLeft` for invalid inputs.
/// {@endtemplate}
Either<L, double> Function(String) toDoubleEither<L>(L Function() onLeft) =>
    (str) => str.toDoubleEither(onLeft);

/// {@template fpdart_string_extension_to_bool_either}
/// Convert this [String] to [bool], returns the result of `onLeft` for invalid inputs.
/// {@endtemplate}
Either<L, bool> toBoolEither<L>(String str, L Function() onLeft) =>
    str.toBoolEither(onLeft);
