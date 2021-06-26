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

/// Return a `Some(t)`.
///
/// Shortcut for `Option.of(r)`.
Option<T> some<T>(T t) => Some(t);

/// Return a [None].
///
/// Shortcut for `Option.none()`.
Option<T> none<T>() => const None();

/// Tag the [HKT] interface for the actual [Option].
abstract class _OptionHKT {}

// `Option<A> implements Functor<OptionHKT, A>` expresses correctly the
// return type of the `map` function as `HKT<OptionHKT, B>`.
// This tells us that the actual type parameter changed from `A` to `B`,
// according to the types `A` and `B` of the callable we actually passed as a parameter of `map`.
//
// Moreover, it informs us that we are still considering an higher kinded type
// with respect to the `OptionHKT` tag

/// A type that can contain a value of type `A` in a [Some] or no value with [None].
///
/// Used to represent type-safe missing values. Instead of using `null`, you define the type
/// to be [Option]. In this way, you are required by the type system to handle the case in which
/// the value is missing.
/// ```dart
/// final Option<String> mStr = Option.of('name');
///
/// /// Using [Option] you are required to specify every possible case.
/// /// The type system helps you to find and define edge-cases and avoid errors.
/// mStr.match(
///   printString,
///   () => print('I have no string to print 🤷‍♀️'),
/// );
/// ```
abstract class Option<A> extends HKT<_OptionHKT, A>
    with
        Monad<_OptionHKT, A>,
        Foldable<_OptionHKT, A>,
        Alt<_OptionHKT, A>,
        Extend<_OptionHKT, A>,
        Filterable<_OptionHKT, A> {
  const Option();

  /// Return the result of `f` called with `b` and the value of [Some].
  /// If this [Option] is [None], return `b`.
  @override
  B foldRight<B>(B b, B Function(B acc, A a) f);

  /// Return the result of `f` called with `b` and the value of [Some].
  /// If this [Option] is [None], return `b`.
  @override
  B foldLeft<B>(B b, B Function(B acc, A a) f) =>
      foldMap<Endo<B>>(dualEndoMonoid(), (a) => (B b) => f(b, a))(b);

  /// Use `monoid` to combine the value of [Some] applied to `f`.
  @override
  B foldMap<B>(Monoid<B> monoid, B Function(A a) f) =>
      foldRight(monoid.empty, (b, a) => monoid.combine(f(a), b));

  /// Return the result of `f` called with `b` and the value of [Some].
  /// If this [Option] is [None], return `b`.
  @override
  B foldRightWithIndex<B>(B b, B Function(int i, B acc, A a) f) =>
      foldRight<Tuple2<B, int>>(
        Tuple2(b, length() - 1),
        (t, a) => Tuple2(f(t.second, t.first, a), t.second - 1),
      ).first;

  /// Return the result of `f` called with `b` and the value of [Some].
  /// If this [Option] is [None], return `b`.
  @override
  B foldLeftWithIndex<B>(B b, B Function(int i, B acc, A a) f) =>
      foldLeft<Tuple2<B, int>>(
        Tuple2(b, 0),
        (t, a) => Tuple2(f(t.second, t.first, a), t.second + 1),
      ).first;

  /// Returns `1` when [Option] is [Some], `0` otherwise.
  @override
  int length() => foldLeft(0, (b, _) => b + 1);

  /// Return the result of `predicate` applied to the value of [Some].
  /// If the [Option] is [None], returns `false`.
  @override
  bool any(bool Function(A a) predicate) => foldMap(boolOrMonoid(), predicate);

  /// Return the result of `predicate` applied to the value of [Some].
  /// If the [Option] is [None], returns `true`.
  @override
  bool all(bool Function(A a) predicate) => foldMap(boolAndMonoid(), predicate);

  /// Use `monoid` to combine the value of [Some].
  @override
  A concatenate(Monoid<A> monoid) => foldMap(monoid, identity);

  /// Return the value of this [Option] if it is [Some], otherwise return `a`.
  @override
  Option<A> plus(covariant Option<A> a);

  /// Return `Some(a)`.
  @override
  Option<A> prepend(A a) => Some(a);

  /// If this [Option] is [None], return `Some(a)`. Otherwise return this [Some].
  @override
  Option<A> append(A a);

  /// Change the value of type `A` to a value of type `B` using function `f`.
  /// ```dart
  /// /// Change type `String` (`A`) to type `int` (`B`)
  /// final Option<String> mStr = Option.of('name');
  /// final Option<int> mInt = mStr.map((a) => a.length);
  /// ```
  @override
  Option<B> map<B>(B Function(A a) f);

  /// Apply the function contained inside `a` to change the value of type `A` to
  /// a value of type `B`.
  ///
  /// If `a` is [None], return [None].
  /// ```dart
  /// final a = Option.of(10);
  /// final b = Option.of(20);
  ///
  /// /// `map` takes one parameter [int] and returns `sumToDouble`.
  /// /// We therefore have a function inside a [Option] that we want to
  /// /// apply to another value!
  /// final Option<double Function(int)> map = a.map(
  ///   (a) => (int b) => sumToDouble(a, b),
  /// );
  ///
  /// /// Using `ap`, we get the final `Option<double>` that we want 🚀
  /// final result = b.ap(map);
  /// ```
  @override
  Option<B> ap<B>(covariant Option<B Function(A a)> a) =>
      a.match((f) => map(f), () => Option.none());

  /// Return a [Some] containing the value `b`.
  @override
  Option<B> pure<B>(B b) => Some(b);

  /// Used to chain multiple functions that return a [Option].
  ///
  /// You can extract the value of every [Option] in the chain without
  /// handling all possible missing cases.
  /// If any of the functions in the chain returns [None], the result is [None].
  /// ```dart
  /// /// Using `flatMap`, you can forget that the value may be missing and just
  /// /// use it as if it was there.
  /// ///
  /// /// In case one of the values is actually missing, you will get a [None]
  /// /// at the end of the chain ⛓
  /// final a = Option.of('name');
  /// final Option<double> result = a.flatMap(
  ///   (s) => stringToInt(s).flatMap(
  ///     (i) => intToDouble(i),
  ///   ),
  /// );
  /// ```
  @override
  Option<B> flatMap<B>(covariant Option<B> Function(A a) f);

  /// Return the current [Option] if it is a [Some], otherwise return the result of `orElse`.
  ///
  /// Used to provide an **alt**ernative [Option] in case the current one is [None].
  @override
  Option<A> alt(covariant Option<A> Function() orElse);

  /// Change the value of [Option] from type `A` to type `Z` based on the
  /// value of `Option<A>` using function `f`.
  @override
  Option<Z> extend<Z>(Z Function(Option<A> t) f);

  /// Wrap this [Option] inside another [Option].
  @override
  Option<Option<A>> duplicate() => extend(identity);

  /// If this [Option] is a [Some] and calling `f` returns `true`, then return this [Some].
  /// Otherwise return [None].
  @override
  Option<A> filter(bool Function(A a) f);

  /// If this [Option] is a [Some] and calling `f` returns [Some], then return this [Some].
  /// Otherwise return [None].
  @override
  Option<Z> filterMap<Z>(Option<Z> Function(A a) f);

  /// Return a [Tuple2]. If this [Option] is a [Some]:
  /// - if `f` applied to its value returns `true`, then the tuple contains this [Option] as second value
  /// - if `f` applied to its value returns `false`, then the tuple contains this [Option] as first value
  /// Otherwise the tuple contains both [None].
  @override
  Tuple2<Option<A>, Option<A>> partition(bool Function(A a) f) =>
      Tuple2(filter((a) => !f(a)), filter(f));

  /// Return a [Tuple2] that contains as first value a [Some] when `f` returns [Left],
  /// otherwise the [Some] will be the second value of the tuple.
  @override
  Tuple2<Option<Z>, Option<Y>> partitionMap<Z, Y>(
          Either<Z, Y> Function(A a) f) =>
      Option.separate(map(f));

  /// If this [Option] is a [Some], then return the result of calling `then`.
  /// Otherwise return [None].
  @override
  Option<B> andThen<B>(covariant Option<B> Function() then) =>
      flatMap((_) => then());

  /// Change type of this [Option] based on its value of type `A` and the
  /// value of type `C` of another [Option].
  @override
  Option<D> map2<C, D>(covariant Option<C> mc, D Function(A a, C c) f) =>
      flatMap((a) => mc.map((c) => f(a, c)));

  /// Change type of this [Option] based on its value of type `A`, the
  /// value of type `C` of a second [Option], and the value of type `D`
  /// of a third [Option].
  @override
  Option<E> map3<C, D, E>(covariant Option<C> mc, covariant Option<D> md,
          E Function(A a, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  /// Execute `onSome` when value is [Some], otherwise execute `onNone`.
  B match<B>(B Function(A a) onSome, B Function() onNone);

  /// Return `true` when value is [Some].
  bool isSome();

  /// Return `true` when value is [None].
  bool isNone();

  /// If this [Option] is a [Some] then return the value inside the [Option].
  /// Otherwise return the result of `orElse`.
  A getOrElse(A Function() orElse);

  /// Return value of type `A` when this [Option] is a [Some], `null` otherwise.
  A? toNullable();

  /// Build an [Either] from [Option].
  ///
  /// Return [Right] when [Option] is [Some], otherwise [Left] containing
  /// the result of calling `onLeft`.
  Either<L, A> toEither<L>(L Function() onLeft);

  /// Return `true` when value of `a` is equal to the value inside the [Option].
  bool elem(A a, Eq<A> eq);

  /// Build a [Option] from a [Either] by returning [Some] when `either` is [Right],
  /// [None] otherwise.
  static Option<R> fromEither<L, R>(Either<L, R> either) =>
      either.match((_) => Option.none(), (r) => Some(r));

  /// Return [Some] of `value` when `predicate` applied to `value` returns `true`,
  /// [None] otherwise.
  factory Option.fromPredicate(A value, bool Function(A a) predicate) =>
      predicate(value) ? Some(value) : Option.none();

  /// Return [Some] of type `B` by calling `f` with `value` when `predicate` applied to `value` is `true`,
  /// `None` otherwise.
  /// ```dart
  /// /// If the value of `str` is not empty, then return a [Some] containing
  /// /// the `length` of `str`, otherwise [None].
  /// Option.fromPredicateMap<String, int>(
  ///   str,
  ///   (str) => str.isNotEmpty,
  ///   (str) => str.length,
  /// );
  /// ```
  static Option<B> fromPredicateMap<A, B>(
          A value, bool Function(A a) predicate, B Function(A a) f) =>
      predicate(value) ? Some(f(value)) : Option.none();

  /// Return a [None].
  factory Option.none() => None<A>();

  /// Return a `Some(a)`.
  factory Option.of(A a) => Some(a);

  /// Flat a [Option] contained inside another [Option] to be a single [Option].
  factory Option.flatten(Option<Option<A>> m) => m.flatMap(identity);

  /// Return [None] if `a` is `null`, [Some] otherwise.
  factory Option.fromNullable(A? a) => a == null ? Option.none() : Some(a);

  /// Try to run `f` and return `Some(a)` when no error are thrown, otherwise return `None`.
  factory Option.tryCatch(A Function() f) {
    try {
      return Some(f());
    } catch (_) {
      return Option.none();
    }
  }

  /// Return a [Tuple2] of [Option] from a `Option<Either<A, B>>`.
  ///
  /// The value on the left of the [Either] will be the first value of the tuple,
  /// while the right value of the [Either] will be the second of the tuple.
  static Tuple2<Option<A>, Option<B>> separate<A, B>(Option<Either<A, B>> m) =>
      m.match((either) => Tuple2(either.getLeft(), either.getRight()),
          () => Tuple2(Option.none(), Option.none()));

  /// Build an `Eq<Option>` by comparing the values inside two [Option].
  ///
  /// If both [Option] are [None], then calling `eqv` returns `true`. Otherwise, if both are [Some]
  /// and their contained value is the same, then calling `eqv` returns `true`.
  /// It returns `false` in all other cases.
  static Eq<Option<A>> getEq<A>(Eq<A> eq) => Eq.instance((a1, a2) =>
      a1 == a2 ||
      a1
          .flatMap((j1) => a2.flatMap((j2) => Some(eq.eqv(j1, j2))))
          .getOrElse(() => false));

  /// Build an instance of [Monoid] in which the `empty` value is [None] and the
  /// `combine` function is based on the **first** [Option] if it is [Some], otherwise the second.
  static Monoid<Option<A>> getFirstMonoid<A>() =>
      Monoid.instance(Option.none(), (a1, a2) => a1.isNone() ? a2 : a1);

  /// Build an instance of [Monoid] in which the `empty` value is [None] and the
  /// `combine` function is based on the **second** [Option] if it is [Some], otherwise the first.
  static Monoid<Option<A>> getLastMonoid<A>() =>
      Monoid.instance(Option.none(), (a1, a2) => a2.isNone() ? a1 : a2);

  /// Build an instance of [Monoid] in which the `empty` value is [None] and the
  /// `combine` function uses the given `semigroup` to combine the values of both [Option]
  /// if they are both [Some].
  ///
  /// If one of the [Option] is [None], then calling `combine` returns [None].
  static Monoid<Option<A>> getMonoid<A>(Semigroup<A> semigroup) =>
      Monoid.instance(
          Option.none(),
          (a1, a2) => a1.flatMap((v1) => a2.flatMap(
                (v2) => Some(semigroup.combine(v1, v2)),
              )));

  /// Return an [Order] to order instances of [Option].
  ///
  /// Return `0` when the [Option]s are the same, otherwise uses the given `order`
  /// to compare their values when they are both [Some].
  ///
  /// Otherwise instances of [Some] comes before [None] in the ordering.
  static Order<Option<A>> getOrder<A>(Order<A> order) => Order.from(
        (a1, a2) => a1 == a2
            ? 0
            : a1
                .flatMap((v1) => a2.flatMap(
                      (v2) => Some(order.compare(v1, v2)),
                    ))
                .getOrElse(() => a1.isSome() ? 1 : -1),
      );
}

class Some<A> extends Option<A> {
  final A _value;
  const Some(this._value);

  /// Extract value of type `A` inside the [Some].
  A get value => _value;

  @override
  Option<D> map2<C, D>(covariant Option<C> mc, D Function(A a, C c) f) =>
      flatMap((a) => mc.map((c) => f(a, c)));

  @override
  Option<E> map3<C, D, E>(covariant Option<C> mc, covariant Option<D> md,
          E Function(A a, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  @override
  Option<B> map<B>(B Function(A a) f) => Some(f(_value));

  @override
  B foldRight<B>(B b, B Function(B acc, A a) f) => f(b, _value);

  @override
  Option<B> flatMap<B>(covariant Option<B> Function(A a) f) => f(_value);

  @override
  A getOrElse(A Function() orElse) => _value;

  @override
  Option<A> alt(Option<A> Function() orElse) => this;

  @override
  B match<B>(B Function(A a) onSome, B Function() onNone) => onSome(_value);

  @override
  Option<Z> extend<Z>(Z Function(Option<A> t) f) => Some(f(this));

  @override
  bool isSome() => true;

  @override
  bool isNone() => false;

  @override
  Option<A> filter(bool Function(A a) f) => f(_value) ? this : Option.none();

  @override
  Option<Z> filterMap<Z>(Option<Z> Function(A a) f) =>
      f(_value).match((a) => Some(a), () => Option.none());

  @override
  A? toNullable() => _value;

  @override
  bool elem(A a, Eq<A> eq) => eq.eqv(_value, a);

  @override
  Either<L, A> toEither<L>(L Function() onLeft) => Right(_value);

  @override
  Option<A> plus(covariant Option<A> v) => this;

  @override
  Option<A> append(A a) => this;

  @override
  bool operator ==(Object other) => (other is Some) && other._value == _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Some($_value)';
}

class None<A> extends Option<A> {
  const None();

  @override
  Option<D> map2<C, D>(covariant Option<C> a, D Function(A a, C c) f) =>
      flatMap((b) => a.map((c) => f(b, c)));

  @override
  Option<E> map3<C, D, E>(covariant Option<C> mc, covariant Option<D> md,
          E Function(A a, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  @override
  Option<B> map<B>(B Function(A a) f) => Option.none();

  @override
  B foldRight<B>(B b, B Function(B acc, A a) f) => b;

  @override
  Option<B> flatMap<B>(covariant Option<B> Function(A a) f) => Option.none();

  @override
  A getOrElse(A Function() orElse) => orElse();

  @override
  Option<A> alt(Option<A> Function() orElse) => orElse();

  @override
  B match<B>(B Function(A a) onSome, B Function() onNone) => onNone();

  @override
  Option<Z> extend<Z>(Z Function(Option<A> t) f) => Option.none();

  @override
  bool isSome() => false;

  @override
  bool isNone() => true;

  @override
  Option<A> filter(bool Function(A a) f) => Option.none();

  @override
  Option<Z> filterMap<Z>(Option<Z> Function(A a) f) => Option.none();

  @override
  A? toNullable() => null;

  @override
  bool elem(A a, Eq<A> eq) => false;

  @override
  Either<L, A> toEither<L>(L Function() onLeft) => Left(onLeft());

  @override
  Option<A> plus(covariant Option<A> v) => v;

  @override
  Option<A> append(A a) => Some(a);

  @override
  bool operator ==(Object other) => other is None;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'None';
}
