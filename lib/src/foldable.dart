import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/function.dart';
import 'package:fpdart/src/hkt.dart';

abstract class Foldable<G, A> extends HKT<G, A> {
  B foldRight<B>(B b, B Function(A a, B b) f);

  B fold<B>(B b, B Function(B b, A a) f) =>
      foldMap<Endo<B>>(dualEndoMonoid(), (a) => (B b) => f(b, a))(b);

  /// Fold implemented by mapping `A` values into `B` and then
  /// combining them using the given `Monoid<B>` instance.
  ///
  /// Use `Monoid<B>` to provide the initial value of the fold (`empty`) and
  /// the `combine` function to combine the accumulator `B` with the value of
  /// type `B` computed using the function `f` from type `A` (`f(a)`).
  B foldMap<B>(Monoid<B> monoid, B Function(A a) f) =>
      foldRight(monoid.empty, (a, b) => monoid.combine(b, f(a)));
}
