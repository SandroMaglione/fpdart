/// A semigroup is any set `A` with an [**associative operation**](https://en.wikipedia.org/wiki/Associative_property) (`combine`).
///
/// `(xy)z = x(yz) = xyz` for all `x`, `y`, `z` in `A`
mixin Semigroup<T> {
  /// Associative operation which combines two values.
  ///
  /// ```dart
  /// final instance = Semigroup.instance<String>((a1, a2) => '$a1$a2');
  ///
  /// expect(instance.combine('a', 'b'), 'ab');
  /// ```
  T combine(T x, T y);

  /// Return `a` combined with itself `n` times.
  T combineN(T a, int n) {
    if (n <= 0) {
      throw const FormatException(
          "Repeated combining for semigroups must have n > 0");
    }

    return _repeatedCombineN(a, n);
  }

  /// Return `a` combined with itself more than once.
  T _repeatedCombineN(T a, int n) =>
      n == 1 ? a : _repeatedCombineNLoop(a, a, n - 1);

  T _repeatedCombineNLoop(T acc, T source, int k) => k == 1
      ? combine(acc, source)
      : _repeatedCombineNLoop(combine(acc, source), source, k - 1);

  // TODO: [Semigroup] combineAllOption
  // /**
  //  * Given a sequence of `as`, combine them and return the total.
  //  *
  //  * If the sequence is empty, returns None. Otherwise, returns Some(total).
  //  *
  //  * Example:
  //  * {{{
  //  * scala> import cats.kernel.instances.string._
  //  *
  //  * scala> Semigroup[String].combineAllOption(List("One ", "Two ", "Three"))
  //  * res0: Option[String] = Some(One Two Three)
  //  *
  //  * scala> Semigroup[String].combineAllOption(List.empty)
  //  * res1: Option[String] = None
  //  * }}}
  //  */
  // def combineAllOption(as: IterableOnce[A]): Option[A] =
  //   as.reduceOption(combine)

  /// Return a `Semigroup` that reverses the order.
  ///
  /// ```dart
  /// final instance = Semigroup.instance<String>((a1, a2) => '$a1$a2');
  /// final reverse = instance.reverse();
  ///
  /// expect(reverse.combine('a', 'b'), 'ba');
  /// expect(reverse.combine('a', 'b'), instance.combine('b', 'a'));
  /// ```
  Semigroup<T> reverse() => _Semigroup((x, y) => combine(y, x));

  /// Return a `Semigroup` which inserts `middle` between each pair of elements.
  ///
  /// ```dart
  /// final instance = Semigroup.instance<String>((a1, a2) => '$a1$a2');
  /// final intercalate = instance.intercalate('-');
  ///
  /// expect(intercalate.combine('a', 'b'), 'a-b');
  /// expect(intercalate.combineN('a', 3), 'a-a-a');
  /// ```
  Semigroup<T> intercalate(T middle) =>
      _Semigroup((x, y) => combine(x, combine(middle, y)));

  /// Create a `Semigroup` instance from the given function.
  static Semigroup<A> instance<A>(A Function(A a1, A a2) f) => _Semigroup(f);

  /// Create a `Semigroup` instance that always returns the lefthand side.
  static Semigroup<A> first<A>() => _Semigroup((x, y) => x);

  /// Create a `Semigroup` instance that always returns the righthand side.
  static Semigroup<A> last<A>() => _Semigroup((x, y) => y);
}

class _Semigroup<T> with Semigroup<T> {
  final T Function(T x, T y) comb;

  _Semigroup(this.comb);

  @override
  T combine(T x, T y) => comb(x, y);
}
