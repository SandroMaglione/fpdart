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

// `Maybe<A> implements Functor<MaybeHKT, A>` expresses correctly the
// return type of the `map` function as `HKT<MaybeHKT, B>`.
// This tells us that the actual type parameter changed from `A` to `B`,
// according to the types `A` and `B` of the callable we actually passed as a parameter of `map`.
//
// Moreover, it informs us that we are still considering an higher kinded type
// with respect to the `MaybeHKT` tag

/// A type that can contain a value of type `A` in a [Just] or no value with [Nothing].
///
/// Used to represent type-safe missing values. Instead of using `null`, you define the type
/// to be [Maybe]. In this way, you are required by the type system to handle the case in which
/// the value is missing.
/// ```dart
/// final Maybe<String> mStr = Maybe.of('name');
///
/// /// Using [Maybe] you are required to specify every possible case.
/// /// The type system helps you to find and define edge-cases and avoid errors.
/// mStr.match(
///   printString,
///   () => print('I have no string to print 🤷‍♀️'),
/// );
/// ```
abstract class Maybe<A> extends HKT<_MaybeHKT, A>
    with
        Monad<_MaybeHKT, A>,
        Foldable<_MaybeHKT, A>,
        Alt<_MaybeHKT, A>,
        Extend<_MaybeHKT, A>,
        Filterable<_MaybeHKT, A> {
  const Maybe();

  /// Change the value of type `A` to a value of type `B` using function `f`.
  /// ```dart
  /// /// Change type `String` (`A`) to type `int` (`B`)
  /// final Maybe<String> mStr = Maybe.of('name');
  /// final Maybe<int> mInt = mStr.map((a) => a.length);
  /// ```
  @override
  Maybe<B> map<B>(B Function(A a) f);

  /// Apply the function contained inside `a` to change the value of type `A` to
  /// a value of type `B`.
  ///
  /// If `a` is [Nothing], return [Nothing].
  /// ```dart
  /// final a = Maybe.of(10);
  /// final b = Maybe.of(20);
  ///
  /// /// `map` takes one parameter [int] and returns `sumToDouble`.
  /// /// We therefore have a function inside a [Maybe] that we want to
  /// /// apply to another value!
  /// final Maybe<double Function(int)> map = a.map(
  ///   (a) => (int b) => sumToDouble(a, b),
  /// );
  ///
  /// /// Using `ap`, we get the final `Maybe<double>` that we want 🚀
  /// final result = b.ap(map);
  /// ```
  @override
  Maybe<B> ap<B>(covariant Maybe<B Function(A a)> a) =>
      a.match((f) => map(f), () => Maybe.nothing<B>());

  /// Return a [Just] containing the value `b`.
  @override
  Maybe<B> pure<B>(B b) => Just(b);

  /// Used to chain multiple functions that return a [Maybe].
  ///
  /// You can extract the value of every [Maybe] in the chain without
  /// handling all possible missing cases.
  /// If any of the functions in the chain returns [Nothing], the result is [Nothing].
  /// ```dart
  /// /// Using `flatMap`, you can forget that the value may be missing and just
  /// /// use it as if it was there.
  /// ///
  /// /// In case one of the values is actually missing, you will get a [Nothing]
  /// /// at the end of the chain ⛓
  /// final a = Maybe.of('name');
  /// final Maybe<double> result = a.flatMap(
  ///   (s) => stringToInt(s).flatMap(
  ///     (i) => intToDouble(i),
  ///   ),
  /// );
  /// ```
  @override
  Maybe<B> flatMap<B>(covariant Maybe<B> Function(A a) f);

  /// Return the current [Maybe] if it is a [Just], otherwise return the result of `orElse`.
  ///
  /// Used to provide an **alt**ernative [Maybe] in case the current one is [Nothing].
  @override
  Maybe<A> alt(covariant Maybe<A> Function() orElse);

  /// Change the value of [Maybe] from type `A` to type `Z` based on the
  /// value of `Maybe<A>` using function `f`.
  @override
  Maybe<Z> extend<Z>(Z Function(Maybe<A> t) f);

  /// Wrap this [Maybe] inside another [Maybe].
  @override
  Maybe<Maybe<A>> duplicate() => extend(identity);

  /// If this [Maybe] is a [Just] and calling `f` returns `true`, then return this [Just].
  /// Otherwise return [Nothing].
  @override
  Maybe<A> filter(bool Function(A a) f);

  /// If this [Maybe] is a [Just] and calling `f` returns [Just], then return this [Just].
  /// Otherwise return [Nothing].
  @override
  Maybe<Z> filterMap<Z>(Maybe<Z> Function(A a) f);

  /// Return a [Tuple2]. If this [Maybe] is a [Just]:
  /// - if `f` applied to its value returns `true`, then the tuple contains this [Maybe] as second value
  /// - if `f` applied to its value returns `false`, then the tuple contains this [Maybe] as first value
  /// Otherwise the tuple contains both [Nothing].
  @override
  Tuple2<Maybe<A>, Maybe<A>> partition(bool Function(A a) f) =>
      Tuple2(filter((a) => !f(a)), filter(f));

  /// Return a [Tuple2] that contains as first value a [Just] when `f` returns [Left],
  /// otherwise the [Just] will be the second value of the tuple.
  @override
  Tuple2<Maybe<Z>, Maybe<Y>> partitionMap<Z, Y>(Either<Z, Y> Function(A a) f) =>
      Maybe.separate(map(f));

  /// If this [Maybe] is a [Just], then return the result of calling `then`.
  /// Otherwise return [Nothing].
  @override
  Maybe<B> andThen<B>(covariant Maybe<B> Function() then) =>
      flatMap((_) => then());

  /// Change type of this [Maybe] based on its value of type `A` and the
  /// value of type `C` of another [Maybe].
  @override
  Maybe<D> map2<C, D>(covariant Maybe<C> mc, D Function(A a, C c) f) =>
      flatMap((a) => mc.map((c) => f(a, c)));

  /// Change type of this [Maybe] based on its value of type `A`, the
  /// value of type `C` of a second [Maybe], and the value of type `D`
  /// of a third [Maybe].
  @override
  Maybe<E> map3<C, D, E>(covariant Maybe<C> mc, covariant Maybe<D> md,
          E Function(A a, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  /// Return the value of this [Maybe] if it is [Just], otherwise return `a`.
  @override
  Maybe<A> plus(covariant Maybe<A> a);

  /// Return `Just(a)`.
  @override
  Maybe<A> prepend(A a) => Just(a);

  /// If this [Maybe] is [Nothing], return `Just(a)`. Otherwise return this [Just].
  @override
  Maybe<A> append(A a);

  /// Execute `onJust` when value is [Just], otherwise execute `onNothing`.
  B match<B>(B Function(A just) onJust, B Function() onNothing);

  /// Return `true` when value is [Just].
  bool isJust();

  /// Return `true` when value is [Nothing].
  bool isNothing();

  /// If this [Maybe] is a [Just] then return the value inside the [Maybe].
  /// Otherwise return the result of `orElse`.
  A getOrElse(A Function() orElse);

  /// Return value of type `A` when this [Maybe] is a [Just], `null` otherwise.
  A? toNullable();

  /// Build an [Either] from [Maybe].
  ///
  /// Return [Right] when [Maybe] is [Just], otherwise [Left] containing
  /// the result of calling `onLeft`.
  Either<L, A> toEither<L>(L Function() onLeft);

  /// Return `true` when value of `a` is equal to the value inside the [Maybe].
  bool elem(A a, Eq<A> eq);

  /// Build a [Maybe] from a [Either] by returning [Just] when `either` is [Right],
  /// [Nothing] otherwise.
  static Maybe<R> fromEither<L, R>(Either<L, R> either) =>
      either.match((_) => Maybe.nothing<R>(), (r) => Just(r));

  /// Return [Just] of `value` when `predicate` applied to `value` returns `true`,
  /// [Nothing] otherwise.
  static Maybe<A> fromPredicate<A>(A value, bool Function(A a) predicate) =>
      predicate(value) ? Just(value) : Maybe.nothing<A>();

  /// Return [Just] of type `B` by calling `f` with `value` when `predicate` applied to `value` is `true`,
  /// `Nothing` otherwise.
  /// ```dart
  /// /// If the value of `str` is not empty, then return a [Just] containing
  /// /// the `length` of `str`, otherwise [Nothing].
  /// Maybe.fromPredicateMap<String, int>(
  ///   str,
  ///   (str) => str.isNotEmpty,
  ///   (str) => str.length,
  /// );
  /// ```
  static Maybe<B> fromPredicateMap<A, B>(
          A value, bool Function(A a) predicate, B Function(A a) f) =>
      predicate(value) ? Just(f(value)) : Maybe.nothing<B>();

  /// Return a [Nothing].
  static Maybe<A> nothing<A>() => Nothing<A>();

  /// Return a `Just(a)`.
  static Maybe<A> of<A>(A a) => Just(a);

  /// Flat a [Maybe] contained inside another [Maybe] to be a single [Maybe].
  static Maybe<A> flatten<A>(Maybe<Maybe<A>> m) => m.flatMap(identity);

  /// Return a [Tuple2] of [Maybe] from a `Maybe<Either<A, B>>`.
  ///
  /// The value on the left of the [Either] will be the first value of the tuple,
  /// while the right value of the [Either] will be the second of the tuple.
  static Tuple2<Maybe<A>, Maybe<B>> separate<A, B>(Maybe<Either<A, B>> m) =>
      m.match((just) => Tuple2(just.getLeft(), just.getRight()),
          () => Tuple2(Maybe.nothing<A>(), Maybe.nothing<B>()));

  /// Build an `Eq<Maybe>` by comparing the values inside two [Maybe].
  ///
  /// If both [Maybe] are [Nothing], then calling `eqv` returns `true`. Otherwise, if both are [Just]
  /// and their contained value is the same, then calling `eqv` returns `true`.
  /// It returns `false` in all other cases.
  static Eq<Maybe<A>> getEq<A>(Eq<A> eq) => Eq.instance((a1, a2) =>
      a1 == a2 ||
      a1
          .flatMap((j1) => a2.flatMap((j2) => Just(eq.eqv(j1, j2))))
          .getOrElse(() => false));

  /// Build an instance of [Monoid] in which the `empty` value is [Nothing] and the
  /// `combine` function is based on the **first** [Maybe] if it is [Just], otherwise the second.
  static Monoid<Maybe<A>> getFirstMonoid<A>() =>
      Monoid.instance(Maybe.nothing<A>(), (a1, a2) => a1.isNothing() ? a2 : a1);

  /// Build an instance of [Monoid] in which the `empty` value is [Nothing] and the
  /// `combine` function is based on the **second** [Maybe] if it is [Just], otherwise the first.
  static Monoid<Maybe<A>> getLastMonoid<A>() =>
      Monoid.instance(Maybe.nothing<A>(), (a1, a2) => a2.isNothing() ? a1 : a2);

  /// Build an instance of [Monoid] in which the `empty` value is [Nothing] and the
  /// `combine` function uses the given `semigroup` to combine the values of both [Maybe]
  /// if they are both [Just].
  ///
  /// If one of the [Maybe] is [Nothing], then calling `combine` returns [Nothing].
  static Monoid<Maybe<A>> getMonoid<A>(Semigroup<A> semigroup) =>
      Monoid.instance(
          Maybe.nothing<A>(),
          (a1, a2) => a1.flatMap((j1) => a2.flatMap(
                (j2) => Just(semigroup.combine(j1, j2)),
              )));

  /// Return an [Order] to order instances of [Maybe].
  ///
  /// Return `0` when the [Maybe]s are the same, otherwise uses the given `order`
  /// to compare their values when they are both [Just].
  ///
  /// Otherwise instances of [Just] comes before [Nothing] in the ordering.
  static Order<Maybe<A>> getOrder<A>(Order<A> order) => Order.from(
        (a1, a2) => a1 == a2
            ? 0
            : a1
                .flatMap((j1) => a2.flatMap(
                      (j2) => Just(order.compare(j1, j2)),
                    ))
                .getOrElse(() => a1.isJust() ? 1 : -1),
      );

  /// Return [Nothing] if `a` is `null`, [Just] otherwise.
  static Maybe<A> fromNullable<A>(A? a) =>
      a == null ? Maybe.nothing<A>() : Just(a);

  /// Try to run `f` and return `Just(a)` when no error are thrown, otherwise return `Nothing`.
  static Maybe<A> tryCatch<A>(A Function() f) {
    try {
      return Just(f());
    } catch (_) {
      return Maybe.nothing<A>();
    }
  }
}

class Just<A> extends Maybe<A> {
  final A _value;
  const Just(this._value);

  /// Extract value of type `A` inside the [Just].
  A get value => _value;

  @override
  Maybe<D> map2<C, D>(covariant Maybe<C> mc, D Function(A a, C c) f) =>
      flatMap((a) => mc.map((c) => f(a, c)));

  @override
  Maybe<E> map3<C, D, E>(covariant Maybe<C> mc, covariant Maybe<D> md,
          E Function(A a, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  @override
  Maybe<B> map<B>(B Function(A a) f) => Just(f(_value));

  @override
  B foldRight<B>(B b, B Function(A a, B b) f) => f(_value, b);

  @override
  Maybe<B> flatMap<B>(covariant Maybe<B> Function(A a) f) => f(_value);

  @override
  A getOrElse(A Function() orElse) => _value;

  @override
  Maybe<A> alt(Maybe<A> Function() orElse) => this;

  @override
  B match<B>(B Function(A just) onJust, B Function() onNothing) =>
      onJust(_value);

  @override
  Maybe<Z> extend<Z>(Z Function(Maybe<A> t) f) => Just(f(this));

  @override
  bool isJust() => true;

  @override
  bool isNothing() => false;

  @override
  Maybe<A> filter(bool Function(A a) f) =>
      f(_value) ? this : Maybe.nothing<A>();

  @override
  Maybe<Z> filterMap<Z>(Maybe<Z> Function(A a) f) =>
      f(_value).match((just) => Just(just), () => Maybe.nothing<Z>());

  @override
  A? toNullable() => _value;

  @override
  bool elem(A a, Eq<A> eq) => eq.eqv(_value, a);

  @override
  Either<L, A> toEither<L>(L Function() onLeft) => Right(_value);

  @override
  Maybe<A> plus(covariant Maybe<A> v) => this;

  @override
  Maybe<A> append(A a) => this;

  @override
  bool operator ==(Object other) => (other is Just) && other._value == _value;

  @override
  int get hashCode => _value.hashCode;
}

class Nothing<A> extends Maybe<A> {
  const Nothing();

  @override
  Maybe<D> map2<C, D>(covariant Maybe<C> a, D Function(A a, C c) f) =>
      flatMap((b) => a.map((c) => f(b, c)));

  @override
  Maybe<E> map3<C, D, E>(covariant Maybe<C> mc, covariant Maybe<D> md,
          E Function(A a, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  @override
  Maybe<B> map<B>(B Function(A a) f) => Maybe.nothing<B>();

  @override
  B foldRight<B>(B b, B Function(A a, B b) f) => b;

  @override
  Maybe<B> flatMap<B>(covariant Maybe<B> Function(A a) f) => Maybe.nothing<B>();

  @override
  A getOrElse(A Function() orElse) => orElse();

  @override
  Maybe<A> alt(Maybe<A> Function() orElse) => orElse();

  @override
  B match<B>(B Function(A just) onJust, B Function() onNothing) => onNothing();

  @override
  Maybe<Z> extend<Z>(Z Function(Maybe<A> t) f) => Maybe.nothing<Z>();

  @override
  bool isJust() => false;

  @override
  bool isNothing() => true;

  @override
  Maybe<A> filter(bool Function(A a) f) => Maybe.nothing<A>();

  @override
  Maybe<Z> filterMap<Z>(Maybe<Z> Function(A a) f) => Maybe.nothing<Z>();

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

  @override
  bool operator ==(Object other) => other is Nothing;

  @override
  int get hashCode => 0;
}
