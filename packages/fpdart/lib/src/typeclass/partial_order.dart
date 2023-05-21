import 'eq.dart';

/// The `PartialOrder` type class is used to define a
/// [partial ordering](https://en.wikipedia.org/wiki/Partially_ordered_set) on some type `A`.
///
/// A partial order is defined by a relation <=, which obeys the following laws:
/// - x <= x (reflexivity)
/// - if x <= y and y <= x, then x == y (anti-symmetry)
/// - if x <= y and y <= z, then x <= z (transitivity)
///
/// To compute both <= and >= at the same time, we use a `double` number
/// to encode the result of the comparisons x <= y and x >= y.
///
/// The truth table is defined as follows:
///
/// | x <= y | x >= y | result | note |
/// | :--    | :--    | --:    | :-- |
/// | true   |true    | 0.0    | (corresponds to x == y) |
/// | false  |false   | null   | (x and y cannot be compared) |
/// | true   |false   | -1.0   | (corresponds to x < y) |
/// | false  |true    | 1.0    | (corresponds to x > y) |
///
/// **Note**: A partial order under which every pair of elements is comparable
/// is called a [total order](https://en.wikipedia.org/wiki/Total_order) ([Order]).
abstract class PartialOrder<T> extends Eq<T> {
  const PartialOrder();

  /// Result of comparing `x` with `y`.
  ///
  /// Returns `null` if operands are not comparable.
  /// If operands are comparable, returns a `double` whose
  /// sign is:
  /// - negative iff `x < y`
  /// - zero     iff `x == y`
  /// - positive iff `x > y`
  double? partialCompare(T x, T y);

  @override
  PartialOrder<A> contramap<A>(T Function(A) map) => PartialOrder.from<A>(
        (a1, a2) => partialCompare(map(a1), map(a2)),
      );

  /// Returns `true` if `x` == `y`, `false` otherwise.
  @override
  bool eqv(T x, T y) {
    final c = partialCompare(x, y);
    return c != null && c == 0;
  }

  /// Returns `true` if `x` <= `y`, `false` otherwise.
  bool lteqv(T x, T y) {
    final c = partialCompare(x, y);
    return c != null && c <= 0;
  }

  /// Returns `true` if `x` < `y`, `false` otherwise.
  bool lt(T x, T y) {
    final c = partialCompare(x, y);
    return c != null && c < 0;
  }

  /// Returns `true` if `x` >= `y`, `false` otherwise.
  bool gteqv(T x, T y) {
    final c = partialCompare(x, y);
    return c != null && c >= 0;
  }

  /// Returns `true` if `x` > `y`, `false` otherwise.
  bool gt(T x, T y) {
    final c = partialCompare(x, y);
    return c != null && c > 0;
  }

  /// Convert an implicit `PartialOrder[B]` to an `PartialOrder[A]` using the given
  /// function `f`.
  static PartialOrder<A> by<A, B>(B Function(A a) f, PartialOrder<B> po) =>
      _PartialOrder<A>((x, y) => po.partialCompare(f(x), f(y)));

  /// Defines a partial order on `A` from `p` where all arrows switch direction.
  static PartialOrder<A> reverse<A>(PartialOrder<A> p) =>
      _PartialOrder<A>((x, y) => p.partialCompare(y, x));

  /// Define a `PartialOrder[A]` using the given function `f`.
  static PartialOrder<A> from<A>(double? Function(A a1, A a2) f) =>
      _PartialOrder<A>(f);
}

class _PartialOrder<T> extends PartialOrder<T> {
  final double? Function(T x, T y) partialO;

  const _PartialOrder(this.partialO);

  @override
  double? partialCompare(T x, T y) => partialO(x, y);
}
