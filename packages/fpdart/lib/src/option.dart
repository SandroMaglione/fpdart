import 'either.dart';
import 'extension/option_extension.dart';
import 'function.dart';
import 'io_option.dart';
import 'task_option.dart';
import 'typeclass/applicative.dart';
import 'typeclass/eq.dart';
import 'typeclass/extend.dart';
import 'typeclass/filterable.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';
import 'typeclass/monoid.dart';
import 'typeclass/order.dart';
import 'typeclass/semigroup.dart';

part 'option_extension.dart';

/// Return a `Some(t)`.
///
/// Shortcut for `Option.of(r)`.
Option<T> some<T>(T t) => Some(t);

/// Return a [None].
///
/// Shortcut for `Option.none()`.
Option<T> none<T>() => const Option.none();

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

final class _OptionThrow implements Exception {
  const _OptionThrow();
}

typedef DoAdapterOption = A Function<A>(Option<A>);
A _doAdapter<A>(Option<A> option) =>
    option.getOrElse(() => throw const _OptionThrow());

typedef DoFunctionOption<A> = A Function(DoAdapterOption $);

/// Tag the [HKT] interface for the actual [Option].
abstract final class _OptionHKT {}

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
///   () => print('I have no string to print 🤷‍♀️'),
///   printString,
/// );
/// ```
sealed class Option<T> extends HKT<_OptionHKT, T>
    with
        Functor<_OptionHKT, T>,
        Applicative<_OptionHKT, T>,
        Monad<_OptionHKT, T>,
        Extend<_OptionHKT, T>,
        Filterable<_OptionHKT, T> {
  const Option();

  /// Initialize a **Do Notation** chain.
  // ignore: non_constant_identifier_names
  factory Option.Do(DoFunctionOption<T> f) {
    try {
      return Option.of(f(_doAdapter));
    } on _OptionThrow catch (_) {
      return const Option.none();
    }
  }

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
  Option<B> ap<B>(covariant Option<B Function(T t)> a) => a.match(
        Option<B>.none,
        map,
      );

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

  /// Return a new [Option] that calls [Option.fromNullable] on the result of of the given function [f].
  ///
  /// ```dart
  /// expect(
  ///   Option.of(123).flatMapNullable((_) => null),
  ///   Option.none(),
  /// );
  ///
  /// expect(
  ///   Option.of(123).flatMapNullable((_) => 456),
  ///   Option.of(456),
  /// );
  /// ```
  Option<B> flatMapNullable<B>(B? Function(T t) f) =>
      flatMap((t) => Option.fromNullable(f(t)));

  /// Return a new [Option] that calls [Option.tryCatch] with the given function [f].
  ///
  /// ```dart
  /// expect(
  ///   Option.of(123).flatMapThrowable((_) => throw Exception()),
  ///   Option.of(123).flatMapThrowable((_) => 456),
  ///   Option.of(456),
  /// );
  /// ```
  Option<B> flatMapThrowable<B>(B Function(T t) f) =>
      flatMap((t) => Option.tryCatch(() => f(t)));

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
  Option<T> filter(bool Function(T t) f) =>
      flatMap((t) => f(t) ? this : const Option.none());

  /// If this [Option] is a [Some] and calling `f` returns [Some], then return this [Some].
  /// Otherwise return [None].
  @override
  Option<Z> filterMap<Z>(Option<Z> Function(T t) f);

  /// Return a record. If this [Option] is a [Some]:
  /// - if `f` applied to its value returns `true`, then the tuple contains this [Option] as second value
  /// - if `f` applied to its value returns `false`, then the tuple contains this [Option] as first value
  /// Otherwise the tuple contains both [None].
  @override
  (Option<T>, Option<T>) partition(bool Function(T t) f) =>
      (filter((a) => !f(a)), filter(f));

  /// Return a record that contains as first value a [Some] when `f` returns [Left],
  /// otherwise the [Some] will be the second value of the tuple.
  @override
  (Option<Z>, Option<Y>) partitionMap<Z, Y>(Either<Z, Y> Function(T t) f) =>
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

  /// {@template fpdart_option_match}
  /// Execute `onSome` when value is [Some], otherwise execute `onNone`.
  /// {@endtemplate}
  /// ```dart
  /// [🍌].match(() => 🍎, (🍌) => 🍌 * 2) -> 🍌🍌
  /// [_].match(() => 🍎, (🍌) => 🍌 * 2) -> 🍎
  /// ```
  ///
  /// Same as `fold`.
  B match<B>(B Function() onNone, B Function(T t) onSome);

  /// {@macro fpdart_option_match}
  /// ```dart
  /// [🍌].fold(() => 🍎, (🍌) => 🍌 * 2) -> 🍌🍌
  /// [_].fold(() => 🍎, (🍌) => 🍌 * 2) -> 🍎
  /// ```
  ///
  /// Same as `match`.
  B fold<B>(B Function() onNone, B Function(T t) onSome) =>
      match(onNone, onSome);

  /// Return `true` when value is [Some].
  bool isSome();

  /// Return `true` when value is [None].
  bool isNone();

  /// Return value of type `T` when this [Option] is a [Some], `null` otherwise.
  T? toNullable();

  /// Build an [Either] from [Option].
  ///
  /// Return [Right] when [Option] is [Some], otherwise [Left] containing
  /// the result of calling `onLeft`.
  Either<L, T> toEither<L>(L Function() onLeft) => match(
        () => Left(onLeft()),
        Right.new,
      );

  /// Convert this [Option] to a [IOOption].
  IOOption<T> toIOOption() => IOOption(() => this);

  /// Convert this [Option] to a [TaskOption].
  ///
  /// Used to convert a sync context ([Option]) to an async context ([TaskOption]).
  /// You should convert [Option] to [TaskOption] every time you need to
  /// call an async ([Future]) function based on the value in [Option].
  TaskOption<T> toTaskOption() => TaskOption(() => Future.value(this));

  /// {@template fpdart_traverse_list_option}
  /// Map each element in the list to an [Option] using the function `f`,
  /// and collect the result in an `Option<List<B>>`.
  ///
  /// If any mapped element of the list is [None], then the final result
  /// will be [None].
  /// {@endtemplate}
  ///
  /// Same as `Option.traverseList` but passing `index` in the map function.
  static Option<List<B>> traverseListWithIndex<A, B>(
    List<A> list,
    Option<B> Function(A a, int i) f,
  ) {
    final resultList = <B>[];
    for (var i = 0; i < list.length; i++) {
      final o = f(list[i], i);
      final r = o.match<B?>(() => null, identity);
      if (r == null) return none();
      resultList.add(r);
    }

    return some(resultList);
  }

  /// {@macro fpdart_traverse_list_option}
  ///
  /// Same as `Option.traverseListWithIndex` but without `index` in the map function.
  static Option<List<B>> traverseList<A, B>(
    List<A> list,
    Option<B> Function(A a) f,
  ) =>
      traverseListWithIndex<A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_option}
  /// Convert a `List<Option<A>>` to a single `Option<List<A>>`.
  ///
  /// If any of the [Option] in the [List] is [None], then the result is [None].
  /// {@endtemplate}
  static Option<List<A>> sequenceList<A>(
    List<Option<A>> list,
  ) =>
      traverseList(list, identity);

  /// Build a [Option] from a [Either] by returning [Some] when `either` is [Right],
  /// [None] otherwise.
  static Option<R> fromEither<L, R>(Either<L, R> either) =>
      either.match((_) => const Option.none(), Some.new);

  /// {@template fpdart_safe_cast_option}
  /// Safely cast a value to type `T`.
  ///
  /// If `value` is not of type `T`, then return a [None].
  /// {@endtemplate}
  ///
  /// Less strict version of `Option.safeCastStrict`, since `safeCast`
  /// assumes the value to be `dynamic`.
  ///
  /// **Note**: Make sure to specify the type of [Option] (`Option<T>.safeCast`
  /// instead of `Option.safeCast`), otherwise this will always return [Some]!
  // `dynamic`s are use for safe-casting
  //ignore: avoid_annotating_with_dynamic
  factory Option.safeCast(dynamic value) =>
      Option.safeCastStrict<T, dynamic>(value);

  /// {@macro fpdart_safe_cast_option}
  ///
  /// More strict version of `Option.safeCast`, in which also the **input value
  /// type** must be specified (while in `Option.safeCast` the type is `dynamic`).
  static Option<T> safeCastStrict<T, V>(V value) =>
      value is T ? Option<T>.of(value) : Option<T>.none();

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
  const factory Option.none() = None;

  /// Return a `Some(a)`.
  const factory Option.of(T t) = Some<T>;

  /// Flat a [Option] contained inside another [Option] to be a single [Option].
  factory Option.flatten(Option<Option<T>> m) => m.flatMap(identity);

  /// Return [None] if `a` is `null`, [Some] otherwise.
  factory Option.fromNullable(T? t) => t == null ? Option.none() : Some(t);

  /// Try to run `f` and return `Some(a)` when no error are thrown, otherwise return `None`.
  factory Option.tryCatch(T Function() f) {
    try {
      return Some(f());
    } catch (_) {
      return const Option.none();
    }
  }

  /// Return a record of [Option] from a `Option<Either<A, B>>`.
  ///
  /// The value on the left of the [Either] will be the first value of the tuple,
  /// while the right value of the [Either] will be the second of the tuple.
  static (Option<A>, Option<B>) separate<A, B>(Option<Either<A, B>> m) =>
      m.match(
        () => (const Option.none(), const Option.none()),
        (either) => (either.getLeft(), either.getRight()),
      );

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
      Monoid.instance(const Option.none(), (a1, a2) => a1.isNone() ? a2 : a1);

  /// Build an instance of [Monoid] in which the `empty` value is [None] and the
  /// `combine` function is based on the **second** [Option] if it is [Some], otherwise the first.
  static Monoid<Option<T>> getLastMonoid<T>() =>
      Monoid.instance(const Option.none(), (a1, a2) => a2.isNone() ? a1 : a2);

  /// Build an instance of [Monoid] in which the `empty` value is [None] and the
  /// `combine` function uses the given `semigroup` to combine the values of both [Option]
  /// if they are both [Some].
  ///
  /// If one of the [Option] is [None], then calling `combine` returns [None].
  static Monoid<Option<T>> getMonoid<T>(Semigroup<T> semigroup) =>
      Monoid.instance(
          const Option.none(),
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
  factory Option.fromJson(
    // nature of JSON
    //ignore: avoid_annotating_with_dynamic
    dynamic json,
    // nature of JSON
    //ignore: avoid_annotating_with_dynamic
    T Function(dynamic json) fromJsonT,
  ) =>
      json != null ? Option.tryCatch(() => fromJsonT(json)) : Option.none();

  /// Converts to Json.
  ///
  /// Json serialization support for `json_serializable` with `@JsonSerializable`.
  Object? toJson(Object? Function(T) toJsonT);

  /// {@template fpdart_traverse_record_option}
  /// Apply the provided functions to each element of the record,
  /// and collect the results in an [Option] of a record.
  ///
  /// If any result is [None], the entire result is [None].
  /// {@endtemplate}
  static Option<(B1, B2)> traverseRecord2<A1, A2, B1, B2>(
    (A1, A2) record,
    Option<B1> Function(A1) f1,
    Option<B2> Function(A2) f2,
  ) =>
      f1(record.$1).flatMap((b1) => f2(record.$2).map((b2) => (b1, b2)));

  /// {@macro fpdart_traverse_record_option}
  static Option<(B1, B2, B3)> traverseRecord3<A1, A2, A3, B1, B2, B3>(
    (A1, A2, A3) record,
    Option<B1> Function(A1) f1,
    Option<B2> Function(A2) f2,
    Option<B3> Function(A3) f3,
  ) =>
      f1(record.$1).flatMap((b1) =>
          f2(record.$2).flatMap((b2) => f3(record.$3).map((b3) => (b1, b2, b3))));

  /// {@macro fpdart_traverse_record_option}
  static Option<(B1, B2, B3, B4)>
      traverseRecord4<A1, A2, A3, A4, B1, B2, B3, B4>(
    (A1, A2, A3, A4) record,
    Option<B1> Function(A1) f1,
    Option<B2> Function(A2) f2,
    Option<B3> Function(A3) f3,
    Option<B4> Function(A4) f4,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3)
                  .flatMap((b3) => f4(record.$4).map((b4) => (b1, b2, b3, b4)))));

  /// {@macro fpdart_traverse_record_option}
  static Option<(B1, B2, B3, B4, B5)>
      traverseRecord5<A1, A2, A3, A4, A5, B1, B2, B3, B4, B5>(
    (A1, A2, A3, A4, A5) record,
    Option<B1> Function(A1) f1,
    Option<B2> Function(A2) f2,
    Option<B3> Function(A3) f3,
    Option<B4> Function(A4) f4,
    Option<B5> Function(A5) f5,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4)
                  .flatMap((b4) => f5(record.$5).map((b5) => (b1, b2, b3, b4, b5))))));

  /// {@macro fpdart_traverse_record_option}
  static Option<(B1, B2, B3, B4, B5, B6)>
      traverseRecord6<A1, A2, A3, A4, A5, A6, B1, B2, B3, B4, B5, B6>(
    (A1, A2, A3, A4, A5, A6) record,
    Option<B1> Function(A1) f1,
    Option<B2> Function(A2) f2,
    Option<B3> Function(A3) f3,
    Option<B4> Function(A4) f4,
    Option<B5> Function(A5) f5,
    Option<B6> Function(A6) f6,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap(
                      (b5) => f6(record.$6).map((b6) => (b1, b2, b3, b4, b5, b6)))))));

  /// {@macro fpdart_traverse_record_option}
  static Option<(B1, B2, B3, B4, B5, B6, B7)>
      traverseRecord7<A1, A2, A3, A4, A5, A6, A7, B1, B2, B3, B4, B5, B6, B7>(
    (A1, A2, A3, A4, A5, A6, A7) record,
    Option<B1> Function(A1) f1,
    Option<B2> Function(A2) f2,
    Option<B3> Function(A3) f3,
    Option<B4> Function(A4) f4,
    Option<B5> Function(A5) f5,
    Option<B6> Function(A6) f6,
    Option<B7> Function(A7) f7,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).map((b7) => (b1, b2, b3, b4, b5, b6, b7))))))));

  /// {@macro fpdart_traverse_record_option}
  static Option<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseRecord8<A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5, B6, B7,
              B8>(
    (A1, A2, A3, A4, A5, A6, A7, A8) record,
    Option<B1> Function(A1) f1,
    Option<B2> Function(A2) f2,
    Option<B3> Function(A3) f3,
    Option<B4> Function(A4) f4,
    Option<B5> Function(A5) f5,
    Option<B6> Function(A6) f6,
    Option<B7> Function(A7) f7,
    Option<B8> Function(A8) f8,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8)
                          .map((b8) => (b1, b2, b3, b4, b5, b6, b7, b8)))))))));

  /// {@macro fpdart_traverse_record_option}
  static Option<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseRecord9<A1, A2, A3, A4, A5, A6, A7, A8, A9, B1, B2, B3, B4, B5, B6,
              B7, B8, B9>(
    (A1, A2, A3, A4, A5, A6, A7, A8, A9) record,
    Option<B1> Function(A1) f1,
    Option<B2> Function(A2) f2,
    Option<B3> Function(A3) f3,
    Option<B4> Function(A4) f4,
    Option<B5> Function(A5) f5,
    Option<B6> Function(A6) f6,
    Option<B7> Function(A7) f7,
    Option<B8> Function(A8) f8,
    Option<B9> Function(A9) f9,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8).flatMap((b8) =>
                          f9(record.$9)
                              .map((b9) => (b1, b2, b3, b4, b5, b6, b7, b8, b9))))))))));

  /// {@template fpdart_sequence_record_option}
  /// Combine all [Option] in the record and collect results.
  ///
  /// If any [Option] is [None], the result is [None].
  /// {@endtemplate}
  static Option<(A, B)> sequenceRecord2<A, B>(
    (Option<A>, Option<B>) record,
  ) =>
      traverseRecord2(record, identity, identity);

  /// {@macro fpdart_sequence_record_option}
  static Option<(A, B, C)> sequenceRecord3<A, B, C>(
    (Option<A>, Option<B>, Option<C>) record,
  ) =>
      traverseRecord3(record, identity, identity, identity);

  /// {@macro fpdart_sequence_record_option}
  static Option<(A, B, C, D)> sequenceRecord4<A, B, C, D>(
    (Option<A>, Option<B>, Option<C>, Option<D>) record,
  ) =>
      traverseRecord4(record, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_option}
  static Option<(A, B, C, D, F)> sequenceRecord5<A, B, C, D, F>(
    (Option<A>, Option<B>, Option<C>, Option<D>, Option<F>) record,
  ) =>
      traverseRecord5(record, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_option}
  static Option<(A, B, C, D, F, G)> sequenceRecord6<A, B, C, D, F, G>(
    (Option<A>, Option<B>, Option<C>, Option<D>, Option<F>, Option<G>) record,
  ) =>
      traverseRecord6(
          record, identity, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_option}
  static Option<(A, B, C, D, F, G, H)> sequenceRecord7<A, B, C, D, F, G, H>(
    (
      Option<A>,
      Option<B>,
      Option<C>,
      Option<D>,
      Option<F>,
      Option<G>,
      Option<H>
    ) record,
  ) =>
      traverseRecord7(record, identity, identity, identity, identity, identity,
          identity, identity);

  /// {@macro fpdart_sequence_record_option}
  static Option<(A, B, C, D, F, G, H, I)> sequenceRecord8<A, B, C, D, F, G, H, I>(
    (
      Option<A>,
      Option<B>,
      Option<C>,
      Option<D>,
      Option<F>,
      Option<G>,
      Option<H>,
      Option<I>
    ) record,
  ) =>
      traverseRecord8(record, identity, identity, identity, identity, identity,
          identity, identity, identity);

  /// {@macro fpdart_sequence_record_option}
  static Option<(A, B, C, D, F, G, H, I, J)>
      sequenceRecord9<A, B, C, D, F, G, H, I, J>(
    (
      Option<A>,
      Option<B>,
      Option<C>,
      Option<D>,
      Option<F>,
      Option<G>,
      Option<H>,
      Option<I>,
      Option<J>
    ) record,
  ) =>
          traverseRecord9(record, identity, identity, identity, identity,
              identity, identity, identity, identity, identity);
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
  Option<B> flatMap<B>(covariant Option<B> Function(T t) f) => f(_value);

  @override
  B match<B>(B Function() onNone, B Function(T t) onSome) => onSome(_value);

  @override
  Option<Z> extend<Z>(Z Function(Option<T> t) f) => Some(f(this));

  @override
  bool isSome() => true;

  @override
  bool isNone() => false;

  @override
  Option<T> filter(bool Function(T t) f) => f(_value) ? this : Option.none();

  @override
  Option<Z> filterMap<Z>(Option<Z> Function(T t) f) => f(_value).match(
        () => const Option.none(),
        Some.new,
      );

  @override
  T toNullable() => _value;

  @override
  Either<L, T> toEither<L>(L Function() onLeft) => Right(_value);

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

class None extends Option<Never> {
  const None();

  @override
  Option<D> map2<C, D>(covariant Option<C> mc, D Function(Never t, C c) f) =>
      this;

  @override
  Option<E> map3<C, D, E>(
    covariant Option<C> mc,
    covariant Option<D> md,
    E Function(Never t, C c, D d) f,
  ) =>
      this;

  @override
  Option<B> map<B>(B Function(Never t) f) => this;

  @override
  Option<B> flatMap<B>(covariant Option<B> Function(Never t) f) => this;

  @override
  B match<B>(B Function() onNone, B Function(Never t) onSome) => onNone();

  @override
  Option<Z> extend<Z>(Z Function(Option<Never> t) f) => const Option.none();

  @override
  bool isSome() => false;

  @override
  bool isNone() => true;

  @override
  Option<Z> filterMap<Z>(Option<Z> Function(Never t) f) => const Option.none();

  @override
  bool operator ==(Object other) => other is None;

  @override
  Null toNullable() => null;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'None';

  @override
  Object? toJson(Object? Function(Never p1) toJsonT) => null;
}
