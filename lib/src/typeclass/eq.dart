/// A type class used to determine equality between 2 instances **of the same type `T`**.
/// Any 2 instances `x` and `y` are equal if `eqv(x, y)` is `true`.
///
/// Moreover, `eqv` should form an [equivalence relation](https://en.wikipedia.org/wiki/Equivalence_relation)
/// (a binary relation that is reflexive, symmetric, and transitive).
abstract class Eq<T> {
  const Eq();

  /// Returns `true` if `x` and `y` are equivalent, `false` otherwise.
  bool eqv(T x, T y);

  /// Returns `false` if `x` and `y` are equivalent, `true` otherwise.
  bool neqv(T x, T y) => !eqv(x, y);

  /// Convert an implicit `Eq<B>` to an `Eq<A>` using the given function `f`.
  ///
  /// ```dart
  /// /// Convert an `Eq` on `int` to an `Eq` to check `String` length
  /// final instance = Eq.instance<int>((a1, a2) => a1 == a2);
  /// final by = Eq.by<String, int>((a) => a.length, instance);
  ///
  /// expect(by.eqv('abc', 'abc'), true); // Same length
  /// expect(by.eqv('abc', 'ab'), false); // Different length
  /// ```
  static Eq<A> by<A, B>(B Function(A a) f, Eq<B> eq) =>
      _Eq((x, y) => eq.eqv(f(x), f(y)));

  /// Return an `Eq` that gives the result of the **and** of `eq1` and `eq2`.
  ///
  /// Note this is idempotent.
  static Eq<A> and<A>(Eq<A> eq1, Eq<A> eq2) =>
      _Eq((x, y) => eq1.eqv(x, y) && eq2.eqv(x, y));

  /// Return an `Eq` that gives the result of the **or** of `eq1` and `eq2`.
  ///
  /// Note this is idempotent.
  static Eq<A> or<A>(Eq<A> eq1, Eq<A> eq2) =>
      _Eq((x, y) => eq1.eqv(x, y) || eq2.eqv(x, y));

  /// Create an `Eq` instance from an `eqv` implementation.
  ///
  /// ```dart
  /// final instance = Eq.instance<String>((a1, a2) => a1.substring(0, 2) == a2.substring(0, 2));
  ///
  /// expect(instance.eqv('abc', 'abc'), true); // Same 2 characters prefix
  /// expect(instance.eqv('abc', 'acb'), false); // Different 2 characters prefix
  /// ```
  static Eq<A> instance<A>(bool Function(A a1, A a2) f) => _Eq(f);

  /// An `Eq<A>` that delegates to universal equality (`==`).
  static Eq<A> fromUniversalEquals<A>() => _Eq((x, y) => x == y);

  /// An `Eq<A>` in which everything is the same
  /// (calling `eqv` returns always `true`).
  static Eq<A> allEqual<A>() => _Eq((x, y) => true);
}

class _Eq<T> extends Eq<T> {
  final bool Function(T x, T y) eq;
  _Eq(this.eq);

  @override
  bool eqv(T x, T y) => eq(x, y);
}
