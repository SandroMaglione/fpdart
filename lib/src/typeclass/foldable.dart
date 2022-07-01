import '../function.dart';
import '../tuple.dart';
import 'hkt.dart';
import 'monoid.dart';

mixin Foldable<G, A> on HKT<G, A> {
  B foldRight<B>(B b, B Function(B acc, A a) f);

  B foldLeft<B>(B b, B Function(B acc, A a) f) =>
      foldMap<Endo<B>>(dualEndoMonoid(), (a) => (B b) => f(b, a))(b);

  /// Fold implemented by mapping `A` values into `B` and then
  /// combining them using the given `Monoid<B>` instance.
  ///
  /// Use `Monoid<B>` to provide the initial value of the fold (`empty`) and
  /// the `combine` function to combine the accumulator `B` with the value of
  /// type `B` computed using the function `f` from type `A` (`f(a)`).
  B foldMap<B>(Monoid<B> monoid, B Function(A a) f) =>
      foldRight(monoid.empty, (b, a) => monoid.combine(f(a), b));

  B foldRightWithIndex<B>(B b, B Function(int i, B acc, A a) f) =>
      foldRight<Tuple2<B, int>>(
        Tuple2(b, length() - 1),
        (t, a) => Tuple2(f(t.second, t.first, a), t.second - 1),
      ).first;

  B foldLeftWithIndex<B>(B b, B Function(int i, B acc, A a) f) =>
      foldLeft<Tuple2<B, int>>(
        Tuple2(b, 0),
        (t, a) => Tuple2(f(t.second, t.first, a), t.second + 1),
      ).first;

  int length() => foldLeft(0, (b, _) => b + 1);

  bool any(bool Function(A a) predicate) => foldMap(boolOrMonoid(), predicate);
  bool all(bool Function(A a) predicate) => foldMap(boolAndMonoid(), predicate);

  A concatenate(Monoid<A> monoid) => foldMap(monoid, identity);

  HKT<G, A> plus(HKT<G, A> v);

  /// Insert a new element `A` at the beginning.
  HKT<G, A> prepend(A t);

  /// Insert a new element `A` at the end.
  HKT<G, A> append(A t);
}

mixin Foldable2<G, A, B> on HKT2<G, A, B> {
  C foldRight<C>(C b, C Function(C acc, B b) f);

  C foldLeft<C>(C b, C Function(C acc, B b) f) =>
      foldMap<Endo<C>>(dualEndoMonoid(), (b) => (C c) => f(c, b))(b);

  C foldMap<C>(Monoid<C> monoid, C Function(B b) f) =>
      foldRight(monoid.empty, (c, b) => monoid.combine(f(b), c));

  C foldRightWithIndex<C>(C c, C Function(int i, C acc, B b) f) =>
      foldRight<Tuple2<C, int>>(
        Tuple2(c, length() - 1),
        (t, b) => Tuple2(f(t.second, t.first, b), t.second - 1),
      ).first;

  C foldLeftWithIndex<C>(C c, C Function(int i, C acc, B b) f) =>
      foldLeft<Tuple2<C, int>>(
        Tuple2(c, 0),
        (t, b) => Tuple2(f(t.second, t.first, b), t.second + 1),
      ).first;

  int length() => foldLeft(0, (b, _) => b + 1);

  bool any(bool Function(B a) predicate) => foldMap(boolOrMonoid(), predicate);
  bool all(bool Function(B a) predicate) => foldMap(boolAndMonoid(), predicate);

  B concatenate(Monoid<B> monoid) => foldMap(monoid, identity);
}
