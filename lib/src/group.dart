import 'package:fpdart/fpdart.dart';

const int _int64MaxValue = 9223372036854775807;

/// A group is a monoid where each element has an [**inverse**](https://en.wikipedia.org/wiki/Inverse_element).
abstract class Group<T> extends Monoid<T> {
  /// Find the inverse of `a`.
  ///
  /// `combine(a, inverse(a))` == `combine(inverse(a), a)` == `empty`
  T inverse(T a);

  /// Remove the element `b` from `a`.
  ///
  /// Equivalent to `combine(a, inverse(b))`.
  T remove(T a, T b) => combine(a, inverse(b));

  /// Return `a` appended to itself `n` times. If `n` is negative, then
  /// this returns `inverse(a)` appended to itself `n` times.
  @override
  T combineN(T a, int n) {
    if (n > 0) {
      return _repeatedCombineN(a, n);
    } else if (n == 0) {
      return empty;
    } else if (n == _int64MaxValue) {
      // Stack Overflow!
      return combineN(inverse(combine(a, a)), _int64MaxValue ~/ 2);
    }

    return _repeatedCombineN(inverse(a), -n);
  }

  /// Return `a` combined with itself more than once.
  T _repeatedCombineN(T a, int n) =>
      n == 1 ? a : _repeatedCombineNLoop(a, a, n - 1);

  T _repeatedCombineNLoop(T acc, T source, int k) => k == 1
      ? combine(acc, source)
      : _repeatedCombineNLoop(combine(acc, source), source, k - 1);

  /// Create a `Group` instance from the given function, empty value, and inverse function.
  static Group<A> instance<A>(
          A emptyValue, A Function(A a1, A a2) f, A Function(A a) inv) =>
      _Group(emptyValue, f, inv);
}

class _Group<T> extends Group<T> {
  final T Function(T a) inv;
  final T emp;
  final T Function(T x, T y) comb;

  _Group(this.emp, this.comb, this.inv);

  @override
  T combine(T x, T y) => comb(x, y);

  @override
  T get empty => emp;

  @override
  T inverse(T a) => inv(a);
}
