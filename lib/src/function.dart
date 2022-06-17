typedef Endo<A> = A Function(A a);

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

/// Converts a binary function into a unary function that returns a unary function.
///
/// Enables the use of partial application of functions.
/// This often leads to more concise function declarations.
/// ```dart
/// final addFunction = (int a, int b) => a + b;
/// final add = curry(addFunction);
///
/// [1, 2, 3].map(add(1))  // returns [2, 3, 4]
/// ```
C Function(B b) Function(A a) curry2<A, B, C>(C Function(A a, B b) function) {
  return (A a) => (B b) => function(a, b);
}

/// Converts a ternary function into unary functions.
D Function(C c) Function(B b) Function(A a) curry3<A, B, C, D>(
    D Function(A a, B b, C c) function) {
  return (A a) => (B b) => (C c) => function(a, b, c);
}

/// Converts a 4 parameters function into unary functions.
E Function(D d) Function(C c) Function(B b) Function(A a) curry4<A, B, C, D, E>(
    E Function(A a, B b, C c, D d) function) {
  return (A a) => (B b) => (C c) => (D d) => function(a, b, c, d);
}

/// Converts a 5 parameters function into unary functions.
F Function(E e) Function(D d) Function(C c) Function(B b) Function(A a)
    curry5<A, B, C, D, E, F>(F Function(A a, B b, C c, D d, E e) function) {
  return (A a) => (B b) => (C c) => (D d) => (E e) => function(a, b, c, d, e);
}

/// Converts a unary function that returns a unary function into a binary function.
/// ```dart
/// final function = (int a) => (int b) => a + b;
/// final uncurried = uncurry(function);
/// uncurried(2, 3)  // returns 5
/// ```
C Function(A a, B b) uncurry2<A, B, C>(C Function(B a) Function(A a) function) {
  return (A a, B b) => function(a)(b);
}

/// Converts a series of unary functions into a ternary function.
D Function(A a, B b, C c) uncurry3<A, B, C, D>(
    D Function(C c) Function(B b) Function(A a) function) {
  return (A a, B b, C c) => function(a)(b)(c);
}

/// Converts a series of unary functions into a 4 parameters function.
E Function(A a, B b, C c, D d) uncurry4<A, B, C, D, E>(
    E Function(D d) Function(C c) Function(B b) Function(A a) function) {
  return (A a, B b, C c, D d) => function(a)(b)(c)(d);
}

/// Converts a series of unary functions into a 5 parameters function.
F Function(A a, B b, C c, D d, E e) uncurry5<A, B, C, D, E, F>(
    F Function(E e) Function(D d) Function(C c) Function(B b) Function(A a)
        function) {
  return (A a, B b, C c, D d, E e) => function(a)(b)(c)(d)(e);
}

// --- Extensions below 👇 --- //

extension CurryExtension2<Input1, Input2, Output> on Output Function(
    Input1, Input2) {
  /// Convert this function from accepting two parameters to a function
  /// that returns another function both accepting one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input2) curry(Input1 input1) =>
      (input2) => this(input1, input2);
}

extension UncurryExtension2<Input1, Input2, Output> on Output Function(Input2)
    Function(Input1) {
  /// Convert a function that returns another function to a single function
  /// accepting two parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2) uncurry() =>
      (Input1 input1, Input2 input2) => this(input1)(input2);
}

extension CurryExtension3<Input1, Input2, Input3, Output> on Output Function(
    Input1, Input2, Input3) {
  /// Convert this function from accepting three parameters to a series
  /// of functions that all accept one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input3) Function(Input2) curry(Input1 input1) =>
      (input2) => (input3) => this(input1, input2, input3);
}

extension UncurryExtension3<Input1, Input2, Input3, Output>
    on Output Function(Input3) Function(Input2) Function(Input1) {
  /// Convert a function that returns a series of functions to a single function
  /// accepting three parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2, Input3) uncurry() =>
      (Input1 input1, Input2 input2, Input3 input3) =>
          this(input1)(input2)(input3);
}

extension CurryExtension4<Input1, Input2, Input3, Input4, Output> on Output
    Function(Input1, Input2, Input3, Input4) {
  /// Convert this function from accepting four parameters to a series
  /// of functions that all accept one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input4) Function(Input3) Function(Input2) curry(
          Input1 input1) =>
      (input2) => (input3) => (input4) => this(input1, input2, input3, input4);
}

extension UncurryExtension4<Input1, Input2, Input3, Input4, Output>
    on Output Function(Input4) Function(Input3) Function(Input2) Function(
        Input1) {
  /// Convert a function that returns a series of functions to a single function
  /// accepting four parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2, Input3, Input4) uncurry() =>
      (Input1 input1, Input2 input2, Input3 input3, Input4 input4) =>
          this(input1)(input2)(input3)(input4);
}

extension CurryExtension5<Input1, Input2, Input3, Input4, Input5, Output>
    on Output Function(Input1, Input2, Input3, Input4, Input5) {
  /// Convert this function from accepting five parameters to a series
  /// of functions that all accept one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input5) Function(Input4) Function(Input3) Function(Input2)
      curry(Input1 input1) => (input2) => (input3) =>
          (input4) => (input5) => this(input1, input2, input3, input4, input5);
}

extension UncurryExtension5<Input1, Input2, Input3, Input4, Input5, Output>
    on Output Function(Input5) Function(Input4) Function(Input3) Function(
            Input2)
        Function(Input1) {
  /// Convert a function that returns a series of functions to a single function
  /// accepting five parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2, Input3, Input4, Input5) uncurry() =>
      (Input1 input1, Input2 input2, Input3 input3, Input4 input4,
              Input5 input5) =>
          this(input1)(input2)(input3)(input4)(input5);
}
