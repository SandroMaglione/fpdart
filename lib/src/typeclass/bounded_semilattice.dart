import 'package:fpdart/fpdart.dart';

/// A semilattice in which:
///
/// > For all elements `x` and `y` of `A`, both the
/// > [**least upper bound**](https://en.wikipedia.org/wiki/Infimum_and_supremum) and
/// > [**greatest lower bound**](https://en.wikipedia.org/wiki/Infimum_and_supremum)
/// > of the set `{x, y}` exist.
///
/// See also [Semilattice]
mixin BoundedSemilattice<T> on CommutativeMonoid<T>, Semilattice<T> {
  /// Return a `BoundedSemilattice` that reverses the order.
  @override
  BoundedSemilattice<T> reverse() =>
      _BoundedSemilattice(empty, (x, y) => combine(y, x));

  /// Return `a`, since `combine(a, a) == a` for a semilattice (idempotent).
  ///
  /// Return `empty` if `n == 0`.
  @override
  T combineN(T a, int n) {
    if (n < 0) {
      throw const FormatException(
          "Repeated combining for monoids must have n >= 0");
    } else if (n == 0) {
      return empty;
    }

    return a;
  }

  /// Create a `BoundedSemilattice` instance from the given function and empty value.
  static BoundedSemilattice<A> instance<A>(
          A emptyValue, A Function(A a1, A a2) f) =>
      _BoundedSemilattice(emptyValue, f);
}

class _BoundedSemilattice<T>
    with
        Semigroup<T>,
        Monoid<T>,
        CommutativeSemigroup<T>,
        Band<T>,
        Semilattice<T>,
        CommutativeMonoid<T>,
        BoundedSemilattice<T> {
  final T emp;
  final T Function(T x, T y) comb;

  _BoundedSemilattice(this.emp, this.comb);

  @override
  T combine(T x, T y) => comb(x, y);

  @override
  T get empty => emp;
}
