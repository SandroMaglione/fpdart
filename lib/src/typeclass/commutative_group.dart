import 'package:fpdart/fpdart.dart';

/// An commutative group (also known as an [**abelian group**](https://en.wikipedia.org/wiki/Abelian_group))
/// is a group whose combine operation is [**commutative**](https://en.wikipedia.org/wiki/Commutative_property).
///
/// See also [Group]
mixin CommutativeGroup<T> on Group<T>, CommutativeMonoid<T> {
  /// Create a `CommutativeGroup` instance from the given function, empty value, and inverse function.
  static CommutativeGroup<A> instance<A>(
          A emptyValue, A Function(A a1, A a2) f, A Function(A a) inv) =>
      _CommutativeGroup(emptyValue, f, inv);
}

class _CommutativeGroup<T>
    with
        Semigroup<T>,
        CommutativeSemigroup<T>,
        Monoid<T>,
        CommutativeMonoid<T>,
        Group<T>,
        CommutativeGroup<T> {
  final T Function(T a) inv;
  final T emp;
  final T Function(T x, T y) comb;

  _CommutativeGroup(this.emp, this.comb, this.inv);

  @override
  T combine(T x, T y) => comb(x, y);

  @override
  T get empty => emp;

  @override
  T inverse(T a) => inv(a);
}
