import 'applicative.dart';
import 'hkt.dart';

abstract class Monad<KT, A> extends HKT<KT, A> with Applicative<KT, A> {
  HKT<KT, B> flatMap<B>(HKT<KT, B> Function(A a) f);

  @override
  HKT<KT, B> ap<B>(covariant Monad<KT, B Function(A a)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  HKT<KT, D> map2<C, D>(Monad<KT, C> mc, D Function(A a, C c) f) =>
      flatMap((a) => mc.map((c) => f(a, c)));

  HKT<KT, E> map3<C, D, E>(
          Monad<KT, C> mc, Monad<KT, D> md, E Function(A a, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  HKT<KT, B> andThen<B>(HKT<KT, B> Function() then) => flatMap((_) => then());
}

abstract class Monad2<G, A, B> extends HKT2<G, A, B>
    with Applicative2<G, A, B> {
  HKT2<G, A, C> flatMap<C>(HKT2<G, A, C> Function(B a) f);

  /// Derive `ap` from `flatMap`.
  ///
  /// Use `flatMap` to extract the value from `a` and from the current [Monad].
  /// If both these values are present, apply the function from `a` to the value
  /// of the current [Monad], using `pure` to return the correct type.
  @override
  HKT2<G, A, C> ap<C>(covariant Monad2<G, A, C Function(B a)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  HKT2<G, A, D> map2<C, D>(Monad2<G, A, C> a, D Function(B b, C c) f) =>
      flatMap((b) => a.map((c) => f(b, c)));

  HKT2<G, A, C> andThen<C>(HKT2<G, A, C> Function() then) =>
      flatMap((_) => then());
}
