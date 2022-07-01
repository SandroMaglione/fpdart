import 'package:fpdart/fpdart.dart';

/// Bands are semigroups whose operation
/// (i.e. `combine`) is also [**idempotent**](https://en.wikipedia.org/wiki/Idempotence)
/// (an operation that can be applied multiple times without changing the result beyond the initial application).
mixin Band<T> on Semigroup<T> {
  /// Only apply `combine` operation the first time:
  /// - `n == 1`, then return `a`
  /// - Otherwise return `combine(a, a)`
  @override
  T combineN(T a, int n) {
    if (n <= 0) {
      throw const FormatException(
          "Repeated combining for bands must have n > 0");
    }

    return n == 1 ? a : combine(a, a);
  }

  /// Create a `Band` instance from the given function.
  static Band<A> instance<A>(A Function(A a1, A a2) f) => _Band(f);
}

class _Band<T> with Semigroup<T>, Band<T> {
  final T Function(T x, T y) comb;

  _Band(this.comb);

  @override
  T combine(T x, T y) => comb(x, y);
}
