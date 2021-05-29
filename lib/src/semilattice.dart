import 'band.dart';
import 'commutative_semigroup.dart';

/// Semilattices are commutative semigroups ([CommutativeSemigroup]) whose operation
/// (i.e. `combine`) is also [**idempotent**](https://en.wikipedia.org/wiki/Idempotence) ([Bind]).
abstract class Semilattice<T> extends Band<T> with CommutativeSemigroup<T> {
  /// Create a `Semilattice` instance from the given function.
  static Semilattice<A> instance<A>(A Function(A a1, A a2) f) =>
      _Semilattice(f);
}

class _Semilattice<T> extends Semilattice<T> {
  final T Function(T x, T y) comb;

  _Semilattice(this.comb);

  @override
  T combine(T x, T y) => comb(x, y);
}
