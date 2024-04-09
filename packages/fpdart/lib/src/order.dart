import 'ordering.dart';

class Order<T> {
  final Ordering Function(T x, T y) compare;
  const Order(this.compare);

  static Order<T> comparable<T extends Comparable<dynamic>>() => Order(
        (x, y) => Ordering.fromOrder(x.compareTo(y)),
      );

  /// If `x < y`, return `x`, else return `y`.
  T min(T x, T y) => lessThan(x, y) ? x : y;

  /// If `x > y`, return `x`, else return `y`.
  T max(T x, T y) => greaterThan(x, y) ? x : y;

  /// Test whether `value` is between `min` and `max` (**inclusive**)
  bool between(T min, T max, T value) =>
      greaterOrEqual(value, min) && lessOrEqual(value, max);

  /// Clamp `value` between `min` and `max`
  T clamp(T min, T max, T value) => this.max(this.min(value, max), min);

  Order<A> mapInput<A>(T Function(A) map) => Order<A>(
        (a1, a2) => compare(map(a1), map(a2)),
      );

  /// Return an [Order] reversed.
  Order<T> get reverse => Order((x, y) => compare(y, x));

  bool equal(T x, T y) => compare(x, y) == Ordering.equal;

  bool lessThan(T x, T y) => compare(x, y) == Ordering.lessThan;

  bool greaterThan(T x, T y) => compare(x, y) == Ordering.greaterThan;

  bool lessOrEqual(T x, T y) {
    if (compare(x, y) case Ordering.lessThan || Ordering.equal) return true;
    return false;
  }

  bool greaterOrEqual(T x, T y) {
    if (compare(x, y) case Ordering.equal || Ordering.greaterThan) return true;
    return false;
  }

  /// Convert `Order<B>` to an `Order<A>` using `f`
  static Order<A> by<A, B>(B Function(A a) f, Order<B> ord) =>
      Order((x, y) => ord.compare(f(x), f(y)));

  /// Order using `first` and if two elements are equal falls back to `second`
  static Order<A> whenEqual<A>(Order<A> first, Order<A> second) => Order(
        (x, y) {
          final ord = first.compare(x, y);
          return ord == Ordering.equal ? second.compare(x, y) : ord;
        },
      );

  /// An `Order` instance that considers all instances to be equal
  static Order<A> allEqual<A>() => Order((x, y) => Ordering.equal);
}
