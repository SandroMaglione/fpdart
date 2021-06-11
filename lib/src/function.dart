typedef Endo<A> = A Function(A a);

/// Returns the given `a`.
T identity<T>(T a) => a;

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
