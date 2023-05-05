import 'eq.dart';

/// A type class used to represent a hashing scheme for objects of a given type.
///
/// For any two instances `x` and `y` that are considered equivalent under the
/// equivalence relation defined by this object, `hash(x)` should equal `hash(y)`.
abstract class Hash<T> extends Eq<T> {
  const Hash();

  /// Returns the hash code of the given object under this hashing scheme.
  int hash(T x);

  /// Constructs a `Hash` instance by using the universal `hashCode` function and the universal equality relation.
  static Hash<A> fromUniversalHashCode<A>() =>
      _Hash((x, y) => x == y, (x) => x.hashCode);
}

class _Hash<T> extends Hash<T> {
  final bool Function(T x, T y) eq;
  final int Function(T x) hs;

  const _Hash(this.eq, this.hs);

  @override
  bool eqv(T x, T y) => eq(x, y);

  @override
  int hash(T x) => hs(x);
}
