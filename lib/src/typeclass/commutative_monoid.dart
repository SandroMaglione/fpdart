import 'commutative_semigroup.dart';
import 'monoid.dart';
import 'semigroup.dart';

/// `CommutativeMonoid` represents a commutative monoid.
///
/// A monoid is [**commutative**](https://en.wikipedia.org/wiki/Commutative_property)
/// if for all `x` and `y`, `combine(x, y) == combine(y, x)`.
mixin CommutativeMonoid<T> on Monoid<T>, CommutativeSemigroup<T> {
  /// Return a `CommutativeMonoid` that reverses the order.
  @override
  CommutativeMonoid<T> reverse() =>
      _CommutativeMonoid(empty, (x, y) => combine(y, x));

  /// Create a `CommutativeMonoid` instance from the given function and empty value.
  static CommutativeMonoid<A> instance<A>(
          A emptyValue, A Function(A a1, A a2) f) =>
      _CommutativeMonoid(emptyValue, f);
}

class _CommutativeMonoid<T>
    with
        Semigroup<T>,
        CommutativeSemigroup<T>,
        Monoid<T>,
        CommutativeMonoid<T> {
  final T emp;
  final T Function(T x, T y) comb;

  _CommutativeMonoid(this.emp, this.comb);

  @override
  T combine(T x, T y) => comb(x, y);

  @override
  T get empty => emp;
}
