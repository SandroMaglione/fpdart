import 'partial_order.dart';

/// The `Order` type class is used to define a [total ordering](https://en.wikipedia.org/wiki/Total_order)
/// on some type `A`.
///
/// An order is defined by a relation <=, which obeys the following laws:
///
/// - either `x <= y` or `y <= x` (totality)
/// - if `x <= y` and `y <= x`, then `x == y` (antisymmetry)
/// - if `x <= y` and `y <= z`, then `x <= z` (transitivity)
///
/// The truth table for compare is defined as follows:
///
/// | x <= y  |  x >= y   | int    |     |
/// | :--     | :--       | --:    | :-- |
/// | true    | true      | = 0    | (corresponds to x == y) |
/// | true    | false     | < 0    | (corresponds to x < y) |
/// | false   | true      | > 0    | (corresponds to x > y) |
///
/// **By the totality law, `x <= y` and `y <= x` cannot be both false**.
abstract class Order<T> extends PartialOrder<T> {
  const Order();

  /// Result of comparing `x` with `y`. Returns an Int whose sign is:
  /// - negative iff `x < y`
  /// - zero     iff `x == y`
  /// - positive iff `x > y`
  int compare(T x, T y);

  @override
  double partialCompare(T x, T y) => compare(x, y).toDouble();

  /// If `x < y`, return `x`, else return `y`.
  T min(T x, T y) => lt(x, y) ? x : y;

  /// If `x > y`, return `x`, else return `y`.
  T max(T x, T y) => gt(x, y) ? x : y;

  @override
  bool eqv(T x, T y) => compare(x, y) == 0;

  @override
  bool lteqv(T x, T y) => compare(x, y) <= 0;

  @override
  bool lt(T x, T y) => compare(x, y) < 0;

  @override
  bool gteqv(T x, T y) => compare(x, y) >= 0;

  @override
  bool gt(T x, T y) => compare(x, y) > 0;

  /// Convert an implicit `Order<B>` to an `Order<A>` using the given
  /// function `f`.
  static Order<A> by<A, B>(B Function(A a) f, Order<B> ord) =>
      _Order((x, y) => ord.compare(f(x), f(y)));

  /// Defines an ordering on `A` from the given order such that all arrows switch direction.
  static Order<A> reverse<A>(Order<A> ord) =>
      _Order((x, y) => ord.compare(y, x));

  /// Returns a new `Order<A>` instance that first compares by the first
  /// `Order` instance and uses the second `Order` instance to "break ties".
  ///
  /// That is, `Order.whenEqual(x, y)` creates an `Order` that first orders by `x` and
  /// then (if two elements are equal) falls back to `y` for the comparison.
  static Order<A> whenEqual<A>(Order<A> first, Order<A> second) =>
      _Order((x, y) {
        final ord = first.compare(x, y);
        return ord == 0 ? second.compare(x, y) : ord;
      });

  /// Define an `Order<A>` using the given function `f`.
  static Order<A> from<A>(int Function(A a1, A a2) f) => _Order(f);

  /// Define an `Order<A>` using the given 'less than' function `f`.
  static Order<A> fromLessThan<A>(bool Function(A a1, A a2) f) =>
      _Order((x, y) => f(x, y)
          ? -1
          : f(y, x)
              ? 1
              : 0);

  /// An `Order` instance that considers all `A` instances to be equal
  /// (`compare` always returns `0`).
  static Order<A> allEqual<A>() => _Order((x, y) => 0);
}

class _Order<T> extends Order<T> {
  final int Function(T x, T y) comp;

  const _Order(this.comp);

  @override
  int compare(T x, T y) => comp(x, y);
}
