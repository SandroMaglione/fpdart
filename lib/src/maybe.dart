import 'package:fpdart/fpdart.dart';

import 'either.dart';
import 'function.dart';
import 'tuple.dart';
import 'typeclass/alt.dart';
import 'typeclass/eq.dart';
import 'typeclass/extend.dart';
import 'typeclass/filterable.dart';
import 'typeclass/foldable.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

/// Tag the `HKT` interface for the actual `Maybe`
abstract class _MaybeHKT {}

/// `Maybe<A> implements Functor<MaybeHKT, A>` expresses correctly the
/// return type of the `map` function as `HKT<MaybeHKT, B>`.
/// This tells us that the actual type parameter changed from `A` to `B`,
/// according to the types `A` and `B` of the callable we actually passed as a parameter of `map`.
///
/// Moreover, it informs us that we are still considering an higher kinded type
/// with respect to the `MaybeHKT` tag
abstract class Maybe<A> extends HKT<_MaybeHKT, A>
    with
        Monad<_MaybeHKT, A>,
        Foldable<_MaybeHKT, A>,
        Alt<_MaybeHKT, A>,
        Extend<_MaybeHKT, A>,
        Filterable<_MaybeHKT, A> {
  const Maybe();

  @override
  Maybe<B> map<B>(B Function(A a) f);

  @override
  Maybe<B> ap<B>(covariant Maybe<B Function(A a)> a) =>
      a.match((f) => map(f), () => Nothing());

  @override
  Maybe<B> pure<B>(B b) => Just(b);

  @override
  Maybe<B> flatMap<B>(covariant Maybe<B> Function(A a) f);

  /// Return the current `Maybe` if it is a `Just`, otherwise return the result of `orElse`.
  @override
  Maybe<A> alt(covariant Maybe<A> Function() orElse);

  @override
  Maybe<Z> extend<Z>(Z Function(Maybe<A> t) f);

  @override
  Maybe<Maybe<A>> duplicate() => extend(identity);

  @override
  Maybe<A> filter(bool Function(A a) f);

  @override
  Maybe<Z> filterMap<Z>(Maybe<Z> Function(A a) f);

  @override
  Tuple2<Maybe<A>, Maybe<A>> partition(bool Function(A a) f) =>
      Tuple2(filter((a) => !f(a)), filter(f));

  @override
  Tuple2<Maybe<Z>, Maybe<Y>> partitionMap<Z, Y>(Either<Z, Y> Function(A a) f) =>
      Maybe.separate(map(f));

  @override
  Maybe<B> andThen<B>(covariant Maybe<B> Function() then) =>
      flatMap((_) => then());

  @override
  Maybe<D> map2<C, D>(covariant Maybe<C> a, D Function(A a, C c) f) =>
      flatMap((b) => a.map((c) => f(b, c)));

  /// Return the value of this [Maybe] if it is [Just], otherwise return `v`.
  @override
  Maybe<A> plus(covariant Maybe<A> v);

  /// Return `Just(a)`.
  @override
  Maybe<A> prepend(A a) => Just(a);

  /// If this [Maybe] is [Nothing], return `Just(a)`. Otherwise return this [Just].
  @override
  Maybe<A> append(A a);

  /// Execute `onJust` when value is `Just`, otherwise execute `onNothing`.
  B match<B>(B Function(A just) onJust, B Function() onNothing);

  /// Return `true` when value is `Just`.
  bool isJust();

  /// Return `true` when value is `Nothing`.
  bool isNothing();

  /// If `Just` then return the value inside the [Maybe], otherwise return the result of `orElse`.
  A getOrElse(A Function() orElse);

  /// Return value of type `A` when `Just`, `null` otherwise.
  A? toNullable();

  /// Build an [Either] from [Maybe].
  ///
  /// Return [Right] when [Maybe] is [Just], otherwise [Left] containing
  /// the result of calling `onLeft`.
  Either<L, A> toEither<L>(L Function() onLeft);

  /// Return `true` when value of `a` is equal to the value inside the [Maybe].
  bool elem(A a, Eq<A> eq);

  /// Build a [Maybe] from a [Either] by keeping `Just` when either is `Right`,
  /// `Nothing` otherwise.
  static Maybe<R> fromEither<L, R>(Either<L, R> either) =>
      either.match((_) => Nothing(), (r) => Just(r));

  /// Return `Just` of `value` when `predicate` applied to `value` is `true`,
  /// `Nothing` otherwise.
  static Maybe<A> fromPredicate<A>(A value, bool Function(A a) predicate) =>
      predicate(value) ? Just(value) : Nothing();

  /// Return a `Nothing`.
  static Maybe<A> nothing<A>() => Nothing();

  /// Return a `Just(a)`.
  static Maybe<A> of<A>(A a) => Just(a);

  static Maybe<A> flatten<A>(Maybe<Maybe<A>> m) => m.flatMap(identity);

  static Tuple2<Maybe<A>, Maybe<B>> separate<A, B>(Maybe<Either<A, B>> m) =>
      m.match((just) => Tuple2(just.getLeft(), just.getRight()),
          () => Tuple2(Nothing(), Nothing()));

  /// Build an [Eq<Maybe>] by comparing the values inside two [Maybe].
  ///
  /// If both [Maybe] are [Nothing], then calling `eqv` returns `true`. Otherwise, if both are [Just]
  /// and their contained value is the same, then calling `eqv` returns `true`.
  /// It returns `false` in all other cases.
  static Eq<Maybe<A>> getEq<A>(Eq<A> eq) => Eq.instance((a1, a2) =>
      a1 == a2 ||
      a1
          .flatMap((j1) => a2.flatMap((j2) => Just(eq.eqv(j1, j2))))
          .getOrElse(() => false));

  static Monoid<Maybe<A>> getFirstMonoid<A>() =>
      Monoid.instance(Nothing(), (a1, a2) => a1.isNothing() ? a2 : a1);

  static Monoid<Maybe<A>> getLastMonoid<A>() =>
      Monoid.instance(Nothing(), (a1, a2) => a2.isNothing() ? a1 : a2);

  static Monoid<Maybe<A>> getMonoid<A>(Semigroup<A> semigroup) =>
      Monoid.instance(
          Nothing(),
          (a1, a2) => a1.flatMap(
              (j1) => a2.flatMap((j2) => Just(semigroup.combine(j1, j2)))));

  static Order<Maybe<A>> getOrder<A>(Order<A> order) => Order.from(
        (a1, a2) => a1 == a2
            ? 0
            : a1
                .flatMap(
                    (j1) => a2.flatMap((j2) => Just(order.compare(j1, j2))))
                .getOrElse(() => a1.isJust() ? 1 : -1),
      );

  /// Return `Nothing` if `a` is `null`, `Just` otherwise.
  static Maybe<A> fromNullable<A>(A? a) => a == null ? Nothing() : Just(a);

  /// Try to run `f` and return `Just(a)` when no error are thrown, otherwise return `Nothing`.
  static Maybe<A> tryCatch<A>(A Function() f) {
    try {
      return Just(f());
    } catch (_) {
      return Nothing();
    }
  }
}

class Just<A> extends Maybe<A> {
  final A a;
  const Just(this.a);

  @override
  Maybe<D> map2<C, D>(covariant Maybe<C> a, D Function(A a, C c) f) =>
      flatMap((b) => a.map((c) => f(b, c)));

  @override
  Maybe<B> map<B>(B Function(A a) f) => Just(f(a));

  @override
  B foldRight<B>(B b, B Function(A a, B b) f) => f(a, b);

  @override
  Maybe<B> flatMap<B>(covariant Maybe<B> Function(A a) f) => f(a);

  @override
  A getOrElse(A Function() orElse) => a;

  @override
  Maybe<A> alt(Maybe<A> Function() orElse) => this;

  @override
  B match<B>(B Function(A just) onJust, B Function() onNothing) => onJust(a);

  @override
  Maybe<Z> extend<Z>(Z Function(Maybe<A> t) f) => Just(f(this));

  @override
  bool isJust() => true;

  @override
  bool isNothing() => false;

  @override
  Maybe<A> filter(bool Function(A a) f) => f(a) ? this : Nothing();

  @override
  Maybe<Z> filterMap<Z>(Maybe<Z> Function(A a) f) =>
      f(a).match((just) => Just(just), () => Nothing());

  @override
  A? toNullable() => a;

  @override
  bool elem(A v, Eq<A> eq) => eq.eqv(a, v);

  @override
  Either<L, A> toEither<L>(L Function() onLeft) => Right(a);

  @override
  Maybe<A> plus(covariant Maybe<A> v) => this;

  @override
  Maybe<A> append(A a) => this;
}

class Nothing<A> extends Maybe<A> {
  const Nothing();

  @override
  Maybe<D> map2<C, D>(covariant Maybe<C> a, D Function(A a, C c) f) =>
      flatMap((b) => a.map((c) => f(b, c)));

  @override
  Maybe<B> map<B>(B Function(A a) f) => Nothing();

  @override
  B foldRight<B>(B b, B Function(A a, B b) f) => b;

  @override
  Maybe<B> flatMap<B>(covariant Maybe<B> Function(A a) f) => Nothing();

  @override
  A getOrElse(A Function() orElse) => orElse();

  @override
  Maybe<A> alt(Maybe<A> Function() orElse) => orElse();

  @override
  B match<B>(B Function(A just) onJust, B Function() onNothing) => onNothing();

  @override
  Maybe<Z> extend<Z>(Z Function(Maybe<A> t) f) => Nothing();

  @override
  bool isJust() => false;

  @override
  bool isNothing() => true;

  @override
  Maybe<A> filter(bool Function(A a) f) => Nothing();

  @override
  Maybe<Z> filterMap<Z>(Maybe<Z> Function(A a) f) => Nothing();

  @override
  A? toNullable() => null;

  @override
  bool elem(A a, Eq<A> eq) => false;

  @override
  Either<L, A> toEither<L>(L Function() onLeft) => Left(onLeft());

  @override
  Maybe<A> plus(covariant Maybe<A> v) => v;

  @override
  Maybe<A> append(A a) => Just(a);
}
