import 'applicative.dart';
import 'hkt.dart';

mixin Monad<KT, A> on HKT<KT, A>, Applicative<KT, A> {
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

  HKT<KT, A> chainFirst<B>(covariant Monad<KT, B> Function(A a) chain) =>
      flatMap((a) => chain(a).map((b) => a));

  HKT<KT, B> call<B>(HKT<KT, B> chain) => flatMap((_) => chain);
}

mixin Monad2<KT, A, B> on HKT2<KT, A, B>, Applicative2<KT, A, B> {
  HKT2<KT, A, C> flatMap<C>(HKT2<KT, A, C> Function(B a) f);

  /// Derive `ap` from `flatMap`.
  ///
  /// Use `flatMap` to extract the value from `a` and from the current [Monad].
  /// If both these values are present, apply the function from `a` to the value
  /// of the current [Monad], using `pure` to return the correct type.
  @override
  HKT2<KT, A, C> ap<C>(covariant Monad2<KT, A, C Function(B a)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  HKT2<KT, A, D> map2<C, D>(Monad2<KT, A, C> m1, D Function(B b, C c) f) =>
      flatMap((b) => m1.map((c) => f(b, c)));

  HKT2<KT, A, E> map3<C, D, E>(Monad2<KT, A, C> m1, Monad2<KT, A, D> m2,
          E Function(B b, C c, D d) f) =>
      flatMap((b) => m1.flatMap((c) => m2.map((d) => f(b, c, d))));

  HKT2<KT, A, C> andThen<C>(HKT2<KT, A, C> Function() then) =>
      flatMap((_) => then());

  HKT2<KT, A, B> chainFirst<C>(
          covariant Monad2<KT, A, C> Function(B b) chain) =>
      flatMap((b) => chain(b).map((c) => b));

  HKT2<KT, A, C> call<C>(HKT2<KT, A, C> chain) => flatMap((_) => chain);
}

mixin Monad3<KT, P1, P2, P3>
    on HKT3<KT, P1, P2, P3>, Applicative3<KT, P1, P2, P3> {
  HKT3<KT, P1, P2, N1> flatMap<N1>(HKT3<KT, P1, P2, N1> Function(P3) f);

  /// Derive `ap` from `flatMap`.
  ///
  /// Use `flatMap` to extract the value from `a` and from the current [Monad].
  /// If both these values are present, apply the function from `a` to the value
  /// of the current [Monad], using `pure` to return the correct type.
  @override
  HKT3<KT, P1, P2, N1> ap<N1>(
          covariant Monad3<KT, P1, P2, N1 Function(P3)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  HKT3<KT, P1, P2, N2> map2<N1, N2>(
    Monad3<KT, P1, P2, N1> m1,
    N2 Function(P3, N1) f,
  ) =>
      flatMap((b) => m1.map((c) => f(b, c)));

  HKT3<KT, P1, P2, N3> map3<N1, N2, N3>(
    Monad3<KT, P1, P2, N1> m1,
    Monad3<KT, P1, P2, N2> m2,
    N3 Function(P3, N1, N2) f,
  ) =>
      flatMap(
        (b) => m1.flatMap((c) => m2.map((d) => f(b, c, d))),
      );

  HKT3<KT, P1, P2, N1> andThen<N1>(
    HKT3<KT, P1, P2, N1> Function() then,
  ) =>
      flatMap((_) => then());

  HKT3<KT, P1, P2, P3> chainFirst<N1>(
    covariant Monad3<KT, P1, P2, N1> Function(P3) chain,
  ) =>
      flatMap((b) => chain(b).map((c) => b));

  HKT3<KT, P1, P2, N1> call<N1>(HKT3<KT, P1, P2, N1> chain) =>
      flatMap((_) => chain);
}
