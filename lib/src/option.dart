import 'either.dart';
import 'function.dart';
import 'task_option.dart';
import 'tuple.dart';
import 'typeclass/alt.dart';
import 'typeclass/applicative.dart';
import 'typeclass/eq.dart';
import 'typeclass/extend.dart';
import 'typeclass/filterable.dart';
import 'typeclass/foldable.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';
import 'typeclass/monoid.dart';
import 'typeclass/order.dart';
import 'typeclass/semigroup.dart';

/// Return a `Some(t)`.
///
/// Shortcut for `Option.of(r)`.
Option<T> some<T>(T t) => Some(t);

/// Return a [None].
///
/// Shortcut for `Option.none()`.
Option<T> none<T>() => None<T>();

/// Return [None] if `t` is `null`, [Some] otherwise.
///
/// Same as initializing `Option.fromNullable(t)`.
Option<T> optionOf<T>(T? t) => Option.fromNullable(t);

/// Return [Some] of `value` when `predicate` applied to `value` returns `true`,
/// [None] otherwise.
///
/// Same as initializing `Option.fromPredicate(value, predicate)`.
Option<T> option<T>(T value, bool Function(T) predicate) =>
    Option.fromPredicate(value, predicate);

/// Tag the [HKT] interface for the actual [Option].
abstract class _OptionHKT {}

// `Option<T> implements Functor<OptionHKT, T>` expresses correctly the
// return type of the `map` function as `HKT<OptionHKT, B>`.
// This tells us that the actual type parameter changed from `T` to `B`,
// according to the types `T` and `B` of the callable we actually passed as a parameter of `map`.
//
// Moreover, it informs us that we are still considering an higher kinded type
// with respect to the `OptionHKT` tag

/// A type that can contain a value of type `T` in a [Some] or no value with [None].
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
abstract class Option<T> extends HKT<_OptionHKT, T>
    with
        Functor<_OptionHKT, T>,
        Applicative<_OptionHKT, T>,
        Monad<_OptionHKT, T>,
        Foldable<_OptionHKT, T>,
        Alt<_OptionHKT, T>,
        Extend<_OptionHKT, T>,
        Filterable<_OptionHKT, T> {
  const Option();

  /// Return the result of `f` called with `b` and the value of [Some].
  /// If this [Option] is [None], return `b`.
  @override
  B foldRight<B>(B b, B Function(B acc, T t) f);

  /// Return the result of `f` called with `b` and the value of [Some].
  /// If this [Option] is [None], return `b`.
  @override
  B foldLeft<B>(B b, B Function(B acc, T t) f) =>
      foldMap<Endo<B>>(dualEndoMonoid(), (a) => (B b) => f(b, a))(b);

  /// Use `monoid` to combine the value of [Some] applied to `f`.
  @override
  B foldMap<B>(Monoid<B> monoid, B Function(T t) f) =>
      foldRight(monoid.empty, (b, a) => monoid.combine(f(a), b));

  /// Return the result of `f` called with `b` and the value of [Some].
  /// If this [Option] is [None], return `b`.
  @override
  B foldRightWithIndex<B>(B b, B Function(int i, B acc, T t) f) =>
      foldRight<Tuple2<B, int>>(
        Tuple2(b, length() - 1),
        (t, a) => Tuple2(f(t.second, t.first, a), t.second - 1),
      ).first;

  /// Return the result of `f` called with `b` and the value of [Some].
  /// If this [Option] is [None], return `b`.
  @override
  B foldLeftWithIndex<B>(B b, B Function(int i, B acc, T t) f) =>
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
  bool any(bool Function(T t) predicate) => foldMap(boolOrMonoid(), predicate);

  /// Return the result of `predicate` applied to the value of [Some].
  /// If the [Option] is [None], returns `true`.
  @override
  bool all(bool Function(T t) predicate) => foldMap(boolAndMonoid(), predicate);

  /// Use `monoid` to combine the value of [Some].
  @override
  T concatenate(Monoid<T> monoid) => foldMap(monoid, identity);

  /// Return the value of this [Option] if it is [Some], otherwise return `a`.
  @override
  Option<T> plus(covariant Option<T> a);

  /// Return `Some(a)`.
  @override
  Option<T> prepend(T t) => Some(t);

  /// If this [Option] is [None], return `Some(a)`. Otherwise return this [Some].
  @override
  Option<T> append(T t);

  /// Change the value of type `T` to a value of type `B` using function `f`.
  /// ```dart
  /// /// Change type `String` (`T`) to type `int` (`B`)
  /// final Option<String> mStr = Option.of('name');
  /// final Option<int> mInt = mStr.map((a) => a.length);
  /// ```
  /// 👇
  /// ```dart
  /// [🥚].map((🥚) => 👨‍🍳(🥚)) -> [🍳]
  /// [_].map((🥚) => 👨‍🍳(🥚)) -> [_]
  /// ```
  @override
  Option<B> map<B>(B Function(T t) f);

  /// Apply the function contained inside `a` to change the value of type `T` to
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
  Option<B> ap<B>(covariant Option<B Function(T t)> a) =>
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
  /// 👇
  /// ```dart
  /// [😀].flatMap(
  ///     (😀) => [👻(😀)]
  ///     ) -> [😱]
  ///
  /// [😀].flatMap(
  ///     (😀) => [👻(😀)]
  ///     ).flatMap(
  ///         (😱) => [👨‍⚕️(😱)]
  ///         ) -> [🤕]
  ///
  /// [😀].flatMap(
  ///     (😀) => [_]
  ///     ).flatMap(
  ///         (_) => [👨‍⚕️(_)]
  ///         ) -> [_]
  ///
  /// [_].flatMap(
  ///     (😀) => [👻(😀)]
  ///     ) -> [_]
  /// ```
  @override
  Option<B> flatMap<B>(covariant Option<B> Function(T t) f);

  /// Return the current [Option] if it is a [Some], otherwise return the result of `orElse`.
  ///
  /// Used to provide an **alt**ernative [Option] in case the current one is [None].
  /// ```dart
  /// [🍌].alt(() => [🍎]) -> [🍌]
  /// [_].alt(() => [🍎]) -> [🍎]
  /// ```
  @override
  Option<T> alt(covariant Option<T> Function() orElse);

  /// Change the value of [Option] from type `T` to type `Z` based on the
  /// value of `Option<T>` using function `f`.
  @override
  Option<Z> extend<Z>(Z Function(Option<T> t) f);

  /// Wrap this [Option] inside another [Option].
  @override
  Option<Option<T>> duplicate() => extend(identity);

  /// If this [Option] is a [Some] and calling `f` returns `true`, then return this [Some].
  /// Otherwise return [None].
  @override
  Option<T> filter(bool Function(T t) f);

  /// If this [Option] is a [Some] and calling `f` returns [Some], then return this [Some].
  /// Otherwise return [None].
  @override
  Option<Z> filterMap<Z>(Option<Z> Function(T t) f);

  /// Return a [Tuple2]. If this [Option] is a [Some]:
  /// - if `f` applied to its value returns `true`, then the tuple contains this [Option] as second value
  /// - if `f` applied to its value returns `false`, then the tuple contains this [Option] as first value
  /// Otherwise the tuple contains both [None].
  @override
  Tuple2<Option<T>, Option<T>> partition(bool Function(T t) f) =>
      Tuple2(filter((a) => !f(a)), filter(f));

  /// Return a [Tuple2] that contains as first value a [Some] when `f` returns [Left],
  /// otherwise the [Some] will be the second value of the tuple.
  @override
  Tuple2<Option<Z>, Option<Y>> partitionMap<Z, Y>(
          Either<Z, Y> Function(T t) f) =>
      Option.separate(map(f));

  /// If this [Option] is a [Some], then return the result of calling `then`.
  /// Otherwise return [None].
  /// ```dart
  /// [🍌].andThen(() => [🍎]) -> [🍎]
  /// [_].andThen(() => [🍎]) -> [_]
  /// ```
  @override
  Option<B> andThen<B>(covariant Option<B> Function() then) =>
      flatMap((_) => then());

  /// Chain multiple [Option]s.
  @override
  Option<B> call<B>(covariant Option<B> chain) => flatMap((_) => chain);

  /// Change type of this [Option] based on its value of type `T` and the
  /// value of type `C` of another [Option].
  @override
  Option<D> map2<C, D>(covariant Option<C> mc, D Function(T t, C c) f) =>
      flatMap((a) => mc.map((c) => f(a, c)));

  /// Change type of this [Option] based on its value of type `T`, the
  /// value of type `C` of a second [Option], and the value of type `D`
  /// of a third [Option].
  @override
  Option<E> map3<C, D, E>(covariant Option<C> mc, covariant Option<D> md,
          E Function(T t, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  /// Execute `onSome` when value is [Some], otherwise execute `onNone`.
  /// ```dart
  /// [🍌].match((🍌) => 🍌 * 2, () => 🍎) -> 🍌🍌
  /// [_].match((🍌) => 🍌 * 2, () => 🍎) -> 🍎
  /// ```
  B match<B>(B Function(T t) onSome, B Function() onNone);

  /// Return `true` when value is [Some].
  bool isSome();

  /// Return `true` when value is [None].
  bool isNone();

  /// If this [Option] is a [Some] then return the value inside the [Option].
  /// Otherwise return the result of `orElse`.
  /// ```dart
  /// [🍌].getOrElse(() => 🍎) -> 🍌
  /// [_].getOrElse(() => 🍎) -> 🍎
  ///
  ///  👆 same as 👇
  ///
  /// [🍌].match((🍌) => 🍌, () => 🍎)
  /// ```
  T getOrElse(T Function() orElse);

  /// Return value of type `T` when this [Option] is a [Some], `null` otherwise.
  T? toNullable();

  /// Build an [Either] from [Option].
  ///
  /// Return [Right] when [Option] is [Some], otherwise [Left] containing
  /// the result of calling `onLeft`.
  Either<L, T> toEither<L>(L Function() onLeft);

  /// Convert this [Option] to a [TaskOption].
  ///
  /// Used to convert a sync context ([Option]) to an async context ([TaskOption]).
  /// You should convert [Option] to [TaskOption] every time you need to
  /// call an async ([Future]) function based on the value in [Option].
  TaskOption<T> toTaskOption();

  /// Return `true` when value of `a` is equal to the value inside the [Option].
  bool elem(T t, Eq<T> eq);

  /// Build a [Option] from a [Either] by returning [Some] when `either` is [Right],
  /// [None] otherwise.
  static Option<R> fromEither<L, R>(Either<L, R> either) =>
      either.match((_) => Option.none(), (r) => Some(r));

  /// Return [Some] of `value` when `predicate` applied to `value` returns `true`,
  /// [None] otherwise.
  factory Option.fromPredicate(T value, bool Function(T t) predicate) =>
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
  factory Option.none() => None<T>();

  /// Return a `Some(a)`.
  factory Option.of(T t) => Some(t);

  /// Flat a [Option] contained inside another [Option] to be a single [Option].
  factory Option.flatten(Option<Option<T>> m) => m.flatMap(identity);

  /// Return [None] if `a` is `null`, [Some] otherwise.
  factory Option.fromNullable(T? t) => t == null ? Option.none() : Some(t);

  /// Try to run `f` and return `Some(a)` when no error are thrown, otherwise return `None`.
  factory Option.tryCatch(T Function() f) {
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
  static Eq<Option<T>> getEq<T>(Eq<T> eq) => Eq.instance((a1, a2) =>
      a1 == a2 ||
      a1
          .flatMap((j1) => a2.flatMap((j2) => Some(eq.eqv(j1, j2))))
          .getOrElse(() => false));

  /// Build an instance of [Monoid] in which the `empty` value is [None] and the
  /// `combine` function is based on the **first** [Option] if it is [Some], otherwise the second.
  static Monoid<Option<T>> getFirstMonoid<T>() =>
      Monoid.instance(Option.none(), (a1, a2) => a1.isNone() ? a2 : a1);

  /// Build an instance of [Monoid] in which the `empty` value is [None] and the
  /// `combine` function is based on the **second** [Option] if it is [Some], otherwise the first.
  static Monoid<Option<T>> getLastMonoid<T>() =>
      Monoid.instance(Option.none(), (a1, a2) => a2.isNone() ? a1 : a2);

  /// Build an instance of [Monoid] in which the `empty` value is [None] and the
  /// `combine` function uses the given `semigroup` to combine the values of both [Option]
  /// if they are both [Some].
  ///
  /// If one of the [Option] is [None], then calling `combine` returns [None].
  static Monoid<Option<T>> getMonoid<T>(Semigroup<T> semigroup) =>
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
  static Order<Option<T>> getOrder<T>(Order<T> order) => Order.from(
        (a1, a2) => a1 == a2
            ? 0
            : a1
                .flatMap((v1) => a2.flatMap(
                      (v2) => Some(order.compare(v1, v2)),
                    ))
                .getOrElse(() => a1.isSome() ? 1 : -1),
      );

  /// Converts from Json.
  ///
  /// Json serialization support for `json_serializable` with `@JsonSerializable`.
  factory Option.fromJson(dynamic json) => Option<T>.fromNullable(json as T?);

  /// Converts to Json.
  ///
  /// Json serialization support for `json_serializable` with `@JsonSerializable`.
  Object? toJson(Object? Function(T) toJsonT);
}

class Some<T> extends Option<T> {
  final T _value;
  const Some(this._value);

  /// Extract value of type `T` inside the [Some].
  T get value => _value;

  @override
  Option<D> map2<C, D>(covariant Option<C> mc, D Function(T t, C c) f) =>
      flatMap((a) => mc.map((c) => f(a, c)));

  @override
  Option<E> map3<C, D, E>(covariant Option<C> mc, covariant Option<D> md,
          E Function(T t, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  @override
  Option<B> map<B>(B Function(T t) f) => Some(f(_value));

  @override
  B foldRight<B>(B b, B Function(B acc, T t) f) => f(b, _value);

  @override
  Option<B> flatMap<B>(covariant Option<B> Function(T t) f) => f(_value);

  @override
  T getOrElse(T Function() orElse) => _value;

  @override
  Option<T> alt(Option<T> Function() orElse) => this;

  @override
  B match<B>(B Function(T t) onSome, B Function() onNone) => onSome(_value);

  @override
  Option<Z> extend<Z>(Z Function(Option<T> t) f) => Some(f(this));

  @override
  bool isSome() => true;

  @override
  bool isNone() => false;

  @override
  Option<T> filter(bool Function(T t) f) => f(_value) ? this : Option.none();

  @override
  Option<Z> filterMap<Z>(Option<Z> Function(T t) f) =>
      f(_value).match((a) => Some(a), () => Option.none());

  @override
  T? toNullable() => _value;

  @override
  bool elem(T t, Eq<T> eq) => eq.eqv(_value, t);

  @override
  Either<L, T> toEither<L>(L Function() onLeft) => Right(_value);

  @override
  Option<T> plus(covariant Option<T> a) => this;

  @override
  Option<T> append(T t) => this;

  @override
  bool operator ==(Object other) => (other is Some) && other._value == _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Some($_value)';

  @override
  Object? toJson(Object? Function(T p1) toJsonT) => toJsonT(_value);

  @override
  TaskOption<T> toTaskOption() => TaskOption.of(_value);
}

class None<T> extends Option<T> {
  const None();

  @override
  Option<D> map2<C, D>(covariant Option<C> mc, D Function(T t, C c) f) =>
      flatMap((b) => mc.map((c) => f(b, c)));

  @override
  Option<E> map3<C, D, E>(covariant Option<C> mc, covariant Option<D> md,
          E Function(T t, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  @override
  Option<B> map<B>(B Function(T t) f) => Option.none();

  @override
  B foldRight<B>(B b, B Function(B acc, T t) f) => b;

  @override
  Option<B> flatMap<B>(covariant Option<B> Function(T t) f) => Option.none();

  @override
  T getOrElse(T Function() orElse) => orElse();

  @override
  Option<T> alt(Option<T> Function() orElse) => orElse();

  @override
  B match<B>(B Function(T t) onSome, B Function() onNone) => onNone();

  @override
  Option<Z> extend<Z>(Z Function(Option<T> t) f) => Option.none();

  @override
  bool isSome() => false;

  @override
  bool isNone() => true;

  @override
  Option<T> filter(bool Function(T t) f) => Option.none();

  @override
  Option<Z> filterMap<Z>(Option<Z> Function(T t) f) => Option.none();

  @override
  T? toNullable() => null;

  @override
  bool elem(T t, Eq<T> eq) => false;

  @override
  Either<L, T> toEither<L>(L Function() onLeft) => Left(onLeft());

  @override
  Option<T> plus(covariant Option<T> a) => a;

  @override
  Option<T> append(T t) => Some(t);

  @override
  bool operator ==(Object other) => other is None;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'None';

  @override
  Object? toJson(Object? Function(T p1) toJsonT) => null;

  @override
  TaskOption<T> toTaskOption() => TaskOption.none();
}
