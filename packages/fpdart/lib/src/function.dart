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
