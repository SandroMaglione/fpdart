import 'package:fpdart/fpdart.dart';

/// `CommutativeSemigroup` represents a commutative semigroup.
///
/// A semigroup is [**commutative**](https://en.wikipedia.org/wiki/Commutative_property)
/// if for all `x` and `y`, `combine(x, y) == combine(y, x)`.
mixin CommutativeSemigroup<T> on Semigroup<T> {
  /// Create a `CommutativeSemigroup` instance from the given function.
  // ignore: library_private_types_in_public_api
  static _CommutativeSemigroup<A> instance<A>(A Function(A a1, A a2) f) =>
      _CommutativeSemigroup(f);
}

class _CommutativeSemigroup<T> with Semigroup<T>, CommutativeSemigroup<T> {
  final T Function(T x, T y) comb;

  _CommutativeSemigroup(this.comb);

  @override
  T combine(T x, T y) => comb(x, y);
}
