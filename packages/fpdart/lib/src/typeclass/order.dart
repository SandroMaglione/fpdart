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

  /// Test whether `value` is between `min` and `max` (**inclusive**).
  bool between(T min, T max, T value) => gteqv(value, min) && lteqv(value, max);

  /// Clamp `value` between `min` and `max`.
  T clamp(T min, T max, T value) => this.max(this.min(value, max), min);

  /// Return an [Order] instance based on a parameter of type `T` extracted from a class `A`.
  /// ```dart
  /// class Parent {
  ///   final int value1;
  ///   final double value2;
  ///   const Parent(this.value1, this.value2);
  /// }
  ///
  /// /// Order values of type [Parent] based on their `value1` ([int]).
  /// final orderParentInt = Order.orderInt.contramap<Parent>(
  ///   (p) => p.value1,
  /// );
  ///
  /// /// Order values of type [Parent] based on their `value2` ([double]).
  /// final orderParentDouble = Order.orderDouble.contramap<Parent>(
  ///   (p) => p.value2,
  /// );
  /// ```
  @override
  Order<A> contramap<A>(T Function(A) map) => Order.from<A>(
        (a1, a2) => compare(map(a1), map(a2)),
      );

  /// Return an [Order] reversed.
  Order<T> get reverse => _Order((x, y) => compare(y, x));

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

  /// Instance of `Order` for `int`.
  static Order<int> orderInt = _Order((x, y) => x == y
      ? 0
      : x > y
          ? 1
          : -1);

  /// Instance of `Order` for `num`.
  static Order<num> orderNum = _Order((x, y) => x == y
      ? 0
      : x > y
          ? 1
          : -1);

  /// Instance of `Order` for `double`.
  static Order<double> orderDouble = _Order((x, y) => x == y
      ? 0
      : x > y
          ? 1
          : -1);

  /// Instance of `Order` for [DateTime].
  static Order<DateTime> orderDate = _Order<DateTime>(
    (a1, a2) => a1.compareTo(a2),
  );
}

class _Order<T> extends Order<T> {
  final int Function(T x, T y) comp;

  const _Order(this.comp);

  @override
  int compare(T x, T y) => comp(x, y);
}
