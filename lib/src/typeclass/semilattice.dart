import 'band.dart';
import 'commutative_semigroup.dart';
import 'eq.dart';
import 'partial_order.dart';
import 'semigroup.dart';

/// [**Semilattices**](https://en.wikipedia.org/wiki/Semilattice)
/// are commutative semigroups whose operation
/// (i.e. `combine`) is also [**idempotent**](https://en.wikipedia.org/wiki/Idempotence).
///
/// **Meet-semilattice**
/// > For all elements `x` and `y` of `A`, the [**greatest lower bound**](https://en.wikipedia.org/wiki/Infimum_and_supremum)
/// > of the set `{x, y}` exists.
///
/// **Join-semilattice**
/// > For all elements `x` and `y` of `A`, the [**least upper bound**](https://en.wikipedia.org/wiki/Infimum_and_supremum)
/// > of the set `{x, y}` exists.
///
/// See also [CommutativeSemigroup], [Bind].
mixin Semilattice<T> on Band<T>, CommutativeSemigroup<T> {
  /// Given `Eq<T>`, return a `PartialOrder<T>` using the `combine`
  /// operator of `Semilattice` to determine the partial ordering. This method assumes
  /// `combine` functions as `meet` (that is, as a **lower bound**).
  ///
  /// This method returns:
  /// - 0.0 if `x == y`
  /// - -1.0 if `x == combine(x, y)`
  /// - 1.0 if `y == combine(x, y)`
  /// - `null` otherwise
  PartialOrder<T> asMeetPartialOrder(Eq<T> eq) => PartialOrder.from(
        (x, y) {
          if (eq.eqv(x, y)) {
            return 0;
          }

          final z = combine(x, y);
          return eq.eqv(x, z)
              ? -1
              : eq.eqv(y, z)
                  ? 1
                  : null;
        },
      );

  /// Given `Eq<T>`, return a `PartialOrder<T>` using the `combine`
  /// operator of `Semilattice` to determine the partial ordering. This method assumes
  /// `combine` functions as `join` (that is, as an **upper bound**).
  ///
  /// This method returns:
  /// - 0.0 if `x == y`
  /// - -1.0 if `y == combine(x, y)`
  /// - 1.0 if `x == combine(x, y)`
  /// - `null` otherwise
  PartialOrder<T> asJoinPartialOrder(Eq<T> eq) => PartialOrder.from(
        (x, y) {
          if (eq.eqv(x, y)) {
            return 0;
          }

          final z = combine(x, y);
          return eq.eqv(y, z)
              ? -1
              : eq.eqv(x, z)
                  ? 1
                  : null;
        },
      );

  /// Create a `Semilattice` instance from the given function.
  static Semilattice<A> instance<A>(A Function(A a1, A a2) f) =>
      _Semilattice(f);
}

class _Semilattice<T>
    with Semigroup<T>, CommutativeSemigroup<T>, Band<T>, Semilattice<T> {
  final T Function(T x, T y) comb;

  _Semilattice(this.comb);

  @override
  T combine(T x, T y) => comb(x, y);
}
