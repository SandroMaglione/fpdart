import 'either.dart';
import 'extension/string_extension.dart';
import 'option.dart';

/// Returns the given `a`.
///
/// Same as `id`.
///
/// Shortcut function to return the input parameter:
/// ```dart
/// final either = Either<String, int>.of(10);
///
/// /// Without using `identity`, you must write a function to return
/// /// the input parameter `(l) => l`.
/// final noId = either.match((l) => l, (r) => '$r');
///
/// /// Using `identity`/`id`, the function just returns its input parameter.
/// final withIdentity = either.match(identity, (r) => '$r');
/// final withId = either.match(id, (r) => '$r');
/// ```
T identity<T>(T a) => a;

/// Returns the given `a`.
///
/// Same as `identity`.
///
/// Shortcut function to return the input parameter:
/// ```dart
/// final either = Either<String, int>.of(10);
///
/// /// Without using `identity`, you must write a function to return
/// /// the input parameter `(l) => l`.
/// final noId = either.match((l) => l, (r) => '$r');
///
/// /// Using `identity`/`id`, the function just returns its input parameter.
/// final withIdentity = either.match(identity, (r) => '$r');
/// final withId = either.match(id, (r) => '$r');
/// ```
T id<T>(T a) => a;

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
/// /// Using `identityFuture`/`idFuture`, the function just returns its input parameter.
/// final withIdentityFuture = either.match(identityFuture, (r) async => '$r');
/// final withIdFuture = await either.match(idFuture, (r) async => '$r');
/// ```
Future<T> identityFuture<T>(T a) => Future.value(a);

/// Returns the given `a`, wrapped in `Future.value`.
///
/// Same as `identityFuture`.
///
/// Shortcut function to return the input parameter:
/// ```dart
/// final either = Either<String, int>.of(10);
///
/// /// Without using `idFuture`, you must write a function to return
/// /// the input parameter `(l) async => l`.
/// final noId = await either.match((l) async => l, (r) async => '$r');
///
/// /// Using `identityFuture`/`idFuture`, the function just returns its input parameter.
/// final withIdentity = either.match(identityFuture, (r) async => '$r');
/// final withId = await either.match(idFuture, (r) async => '$r');
/// ```
Future<T> idFuture<T>(T a) => Future.value(a);

/// Returns the **first parameter** from a function that takes two parameters as input.
T1 idFirst<T1, T2>(T1 t1, T2 t2) => t1;

/// Returns the **second parameter** from a function that takes two parameters as input.
T2 idSecond<T1, T2>(T1 t1, T2 t2) => t2;

/// `constf a` is a unary function which evaluates to `a` for all inputs.
/// ```dart
/// final c = constF<int>(10);
/// print(c('none')); // -> 10
/// print(c('any')); // -> 10
/// print(c(112.12)); // -> 10
/// ```
A Function(dynamic b) constF<A>(A a) => (dynamic b) => a;

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
Either<L, bool> Function(String) toBoolEither<L>(L Function() onLeft) =>
    (str) => str.toBoolEither(onLeft);
