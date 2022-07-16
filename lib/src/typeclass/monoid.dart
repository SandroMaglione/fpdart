import 'package:fpdart/src/function.dart';

import 'eq.dart';
import 'semigroup.dart';

/// A monoid is a semigroup with an identity (`empty`).
///
/// A monoid is a specialization of a
/// semigroup, so its operation must be **associative**.
///
/// Additionally, `combine(x, empty) == combine(empty, x) == x`.
///
/// For example, if we have `Monoid<String>`,
/// with `combine` as string concatenation, then `empty = ""`:
///
/// ```dart
/// final instance = Monoid.instance<String>('', (a1, a2) => '$a1$a2');
///
/// expect(instance.combine('abc', instance.empty), instance.combine(instance.empty, 'abc'));
/// expect(instance.combine('abc', instance.empty), 'abc');
/// ```
mixin Monoid<T> on Semigroup<T> {
  /// Return the identity element for this monoid.
  T get empty;

  /// Tests if `a` is the identity (`empty`).
  bool isEmpty(T a, Eq<T> eq) => eq.eqv(a, empty);

  /// Return `a` appended to itself `n` times.
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

    return _repeatedCombineN(a, n);
  }

  /// Return `a` combined with itself more than once.
  T _repeatedCombineN(T a, int n) =>
      n == 1 ? a : _repeatedCombineNLoop(a, a, n - 1);

  T _repeatedCombineNLoop(T acc, T source, int k) => k == 1
      ? combine(acc, source)
      : _repeatedCombineNLoop(combine(acc, source), source, k - 1);

  // TODO: [Monoid] combineAll
  // /**
  //  * Given a sequence of `as`, sum them using the monoid and return the total.
  //  *
  //  * Example:
  //  * {{{
  //  * scala> import cats.kernel.instances.string._
  //  *
  //  * scala> Monoid[String].combineAll(List("One ", "Two ", "Three"))
  //  * res0: String = One Two Three
  //  *
  //  * scala> Monoid[String].combineAll(List.empty)
  //  * res1: String = ""
  //  * }}}
  //  */
  // def combineAll(as: IterableOnce[A]): A =
  //   as.iterator.foldLeft(empty)(combine)

  // TODO: [Monoid] combineAllOption
  // override def combineAllOption(as: IterableOnce[A]): Option[A] =
  //   if (as.iterator.isEmpty) None else Some(combineAll(as))

  /// Return a `Monoid` that reverses the order.
  @override
  Monoid<T> reverse() => _Monoid(empty, (x, y) => combine(y, x));

  /// Create a `Monoid` instance from the given function and empty value.
  static Monoid<A> instance<A>(A emptyValue, A Function(A a1, A a2) f) =>
      _Monoid(emptyValue, f);
}

class _Monoid<T> with Semigroup<T>, Monoid<T> {
  final T emp;
  final T Function(T x, T y) comb;

  _Monoid(this.emp, this.comb);

  @override
  T combine(T x, T y) => comb(x, y);

  @override
  T get empty => emp;
}

Monoid<Endo<A>> endoMonoid<A>() =>
    Monoid.instance<Endo<A>>(identity, (e1, e2) => (A a) => e1(e2(a)));

Monoid<Endo<A>> dualEndoMonoid<A>() =>
    Monoid.instance<Endo<A>>(identity, (e1, e2) => (A a) => e2(e1(a)));

Monoid<bool> boolOrMonoid() => Monoid.instance(false, (a1, a2) => a1 || a2);
Monoid<bool> boolAndMonoid() => Monoid.instance(true, (a1, a2) => a1 && a2);
