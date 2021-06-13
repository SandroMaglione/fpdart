import '../function.dart';
import '../tuple.dart';
import 'hkt.dart';
import 'monoid.dart';

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
      foldRight(monoid.empty, (a, b) => monoid.combine(f(a), b));

  B foldRightWithIndex<B>(B b, B Function(int i, A a, B b) f) =>
      foldRight<Tuple2<B, int>>(
        Tuple2(b, length() - 1),
        (a, t) => Tuple2(f(t.value2, a, t.value1), t.value2 - 1),
      ).value1;

  B foldLeftWithIndex<B>(B b, B Function(int i, A a, B b) f) =>
      fold<Tuple2<B, int>>(
        Tuple2(b, 0),
        (t, a) => Tuple2(f(t.value2, a, t.value1), t.value2 + 1),
      ).value1;

  int length() => fold(0, (b, _) => b + 1);

  bool any(bool Function(A a) predicate) => foldMap(boolOrMonoid(), predicate);
  bool all(bool Function(A a) predicate) => foldMap(boolAndMonoid(), predicate);

  A concatenate(Monoid<A> monoid) => foldMap(monoid, identity);

  HKT<G, A> plus(HKT<G, A> v);

  /// Insert a new element `A` at the beginning.
  HKT<G, A> prepend(A t);

  /// Insert a new element `A` at the end.
  HKT<G, A> append(A t);
}

abstract class Foldable2<G, A, B> extends HKT2<G, A, B> {
  C foldRight<C>(C b, C Function(B a, C b) f);

  C fold<C>(C b, C Function(C b, B a) f) =>
      foldMap<Endo<C>>(dualEndoMonoid(), (a) => (C b) => f(b, a))(b);

  C foldMap<C>(Monoid<C> monoid, C Function(B a) f) =>
      foldRight(monoid.empty, (a, b) => monoid.combine(f(a), b));

  C foldRightWithIndex<C>(C c, C Function(int i, B b, C c) f) =>
      foldRight<Tuple2<C, int>>(
        Tuple2(c, length() - 1),
        (a, t) => Tuple2(f(t.value2, a, t.value1), t.value2 - 1),
      ).value1;

  C foldLeftWithIndex<C>(C c, C Function(int i, B b, C c) f) =>
      fold<Tuple2<C, int>>(
        Tuple2(c, 0),
        (t, a) => Tuple2(f(t.value2, a, t.value1), t.value2 + 1),
      ).value1;

  int length() => fold(0, (b, _) => b + 1);

  bool any(bool Function(B a) predicate) => foldMap(boolOrMonoid(), predicate);
  bool all(bool Function(B a) predicate) => foldMap(boolAndMonoid(), predicate);

  B concatenate(Monoid<B> monoid) => foldMap(monoid, identity);
}
