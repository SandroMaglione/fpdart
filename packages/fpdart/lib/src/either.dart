import 'function.dart';
import 'io_either.dart';
import 'option.dart';
import 'task_either.dart';
import 'typeclass/typeclass.export.dart';
import 'typedef.dart';

/// Return a `Right(r)`.
///
/// Shortcut for `Either.of(r)`.
Either<L, R> right<L, R>(R r) => Right<L, R>(r);

/// Return a `Left(l)`.
///
/// Shortcut for `Either.left(l)`.
Either<L, R> left<L, R>(L l) => Left<L, R>(l);

final class _EitherThrow<L> {
  final L value;
  const _EitherThrow(this.value);
}

typedef DoAdapterEither<L> = R Function<R>(Either<L, R>);
DoAdapterEither<L> _doAdapter<L>() =>
    <R>(Either<L, R> either) => either.getOrElse(
          (l) => throw _EitherThrow(l),
        );

typedef DoFunctionEither<L, R> = R Function(DoAdapterEither<L> $);

/// Tag the [HKT2] interface for the actual [Either].
abstract final class _EitherHKT {}

/// Represents a value of one of two possible types, [Left] or [Right].
///
/// [Either] is commonly used to **handle errors**. Instead of returning placeholder
/// values when a computation may fail (such as `-1`, `null`, etc.), we return an instance
/// of [Right] containing the correct result when a computation is successful, otherwise we return
/// an instance of [Left] containing information about the kind of error that occurred.
sealed class Either<L, R> extends HKT2<_EitherHKT, L, R>
    with
        Functor2<_EitherHKT, L, R>,
        Applicative2<_EitherHKT, L, R>,
        Monad2<_EitherHKT, L, R>,
        Foldable2<_EitherHKT, L, R>,
        Alt2<_EitherHKT, L, R>,
        Extend2<_EitherHKT, L, R> {
  const Either();

  /// Initialize a **Do Notation** chain.
  // ignore: non_constant_identifier_names
  factory Either.Do(DoFunctionEither<L, R> f) {
    try {
      return Either.of(f(_doAdapter<L>()));
    } on _EitherThrow<L> catch (e) {
      return Either.left(e.value);
    }
  }

  /// This method folds the value from right to left.
  ///
  /// Return the result of `f` called with `b` and the value of [Right].
  /// If this [Either] is [Left], return `b`.
  @override
  C foldRight<C>(C b, C Function(C acc, R b) f);

  /// This method folds the value from left to right.
  ///
  /// Return the result of `f` called with `b` and the value of [Right].
  /// If this [Either] is [Left], return `b`.
  @override
  C foldLeft<C>(C b, C Function(C acc, R b) f) =>
      foldMap<Endo<C>>(dualEndoMonoid(), (b) => (C c) => f(c, b))(b);

  /// Use `monoid` to combine the value of [Right] applied to `f`.
  @override
  C foldMap<C>(Monoid<C> monoid, C Function(R b) f) =>
      foldRight(monoid.empty, (c, b) => monoid.combine(f(b), c));

  /// Return the result of `f` called with `b` and the value of [Right].
  /// If this [Either] is [Left], return `b`.
  @override
  C foldRightWithIndex<C>(C c, C Function(int i, C acc, R b) f) =>
      foldRight<(C, int)>(
        (c, length() - 1),
        (t, b) => (f(t.$2, t.$1, b), t.$2 - 1),
      ).$1;

  /// Return the result of `f` called with `b` and the value of [Right].
  /// If this [Either] is [Left], return `b`.
  @override
  C foldLeftWithIndex<C>(C c, C Function(int i, C acc, R b) f) =>
      foldLeft<(C, int)>(
        (c, 0),
        (t, b) => (f(t.$2, t.$1, b), t.$2 + 1),
      ).$1;

  /// Returns `1` when [Either] is [Right], `0` otherwise.
  @override
  int length() => foldLeft(0, (b, _) => b + 1);

  /// Return the result of `predicate` applied to the value of [Right].
  /// If the [Either] is [Left], returns `false`.
  @override
  bool any(bool Function(R a) predicate) => foldMap(boolOrMonoid(), predicate);

  /// Return the result of `predicate` applied to the value of [Right].
  /// If the [Either] is [Left], returns `true`.
  @override
  bool all(bool Function(R a) predicate) => foldMap(boolAndMonoid(), predicate);

  /// Use `monoid` to combine the value of [Right].
  @override
  R concatenate(Monoid<R> monoid) => foldMap(monoid, identity);

  /// If the [Either] is [Right], then change its value from type `R` to
  /// type `C` using function `f`.
  @override
  Either<L, C> map<C>(C Function(R a) f);

  /// Define two functions to change both the [Left] and [Right] value of the
  /// [Either].
  ///
  /// {@template fpdart_bimap_either}
  /// Same as `map`+`mapLeft` but for both [Left] and [Right]
  /// (`map` is only to change [Right], while `mapLeft` is only to change [Left]).
  /// {@endtemplate}
  Either<C, D> bimap<C, D>(C Function(L l) mLeft, D Function(R b) mRight) =>
      mapLeft(mLeft).map(mRight);

  /// Return a [Right] containing the value `c`.
  @override
  Either<L, C> pure<C>(C c) => Right<L, C>(c);

  /// Apply the function contained inside `a` to change the value on the [Right] from
  /// type `R` to a value of type `C`.
  @override
  Either<L, C> ap<C>(covariant Either<L, C Function(R r)> a) =>
      a.flatMap((f) => map(f));

  /// If this [Either] is a [Right], then return the result of calling `then`.
  /// Otherwise return [Left].
  @override
  Either<L, R2> andThen<R2>(covariant Either<L, R2> Function() then) =>
      flatMap((_) => then());

  /// Return the current [Either] if it is a [Right], otherwise return the result of `orElse`.
  ///
  /// Used to provide an **alt**ernative [Either] in case the current one is [Left].
  @override
  Either<L, R> alt(covariant Either<L, R> Function() orElse);

  /// Change type of this [Either] based on its value of type `R` and the
  /// value of type `C` of another [Either].
  @override
  Either<L, D> map2<C, D>(covariant Either<L, C> m1, D Function(R b, C c) f) =>
      flatMap((b) => m1.map((c) => f(b, c)));

  /// Change type of this [Either] based on its value of type `R`, the
  /// value of type `C` of a second [Either], and the value of type `D`
  /// of a third [Either].
  @override
  Either<L, E> map3<C, D, E>(covariant Either<L, C> m1,
          covariant Either<L, D> m2, E Function(R b, C c, D d) f) =>
      flatMap((b) => m1.flatMap((c) => m2.map((d) => f(b, c, d))));

  /// Change the value of [Either] from type `R` to type `Z` based on the
  /// value of `Either<L, R>` using function `f`.
  @override
  Either<L, Z> extend<Z>(Z Function(Either<L, R> t) f);

  /// Wrap this [Either] inside another [Either].
  @override
  Either<L, Either<L, R>> duplicate() => extend(identity);

  /// Chain multiple functions having the same left type `L`.
  @override
  Either<L, B> call<B>(covariant Either<L, B> chain) => flatMap((_) => chain);

  /// {@template fpdart_flat_map_either}
  /// Used to chain multiple functions that return a [Either].
  ///
  /// You can extract the value of every [Right] in the chain without
  /// handling all possible missing cases.
  /// If any of the functions in the chain returns [Left], the result is [Left].
  /// {@endtemplate}
  ///
  /// Same as `bind`.
  @override
  Either<L, C> flatMap<C>(covariant Either<L, C> Function(R a) f);

  /// {@macro fpdart_flat_map_either}
  ///
  /// Same as `flatMap`.
  Either<L, R2> bind<R2>(Either<L, R2> Function(R r) f) => flatMap(f);

  /// If `f` applied on this [Either] as [Right] returns `true`, then return this [Either].
  /// If it returns `false`, return the result of `onFalse` in a [Left].
  Either<L, R> filterOrElse(bool Function(R r) f, L Function(R r) onFalse) =>
      flatMap((r) => f(r) ? Either.of(r) : Either.left(onFalse(r)));

  /// Chain a request that returns another [Either], execute it, ignore
  /// the result, and return the same value as the current [Either].
  @override
  Either<L, R> chainFirst<C>(
    covariant Either<L, C> Function(R b) chain,
  ) =>
      flatMap((b) => chain(b).map((c) => b).orElse((l) => right(b)));

  /// Used to chain multiple functions that return a `Future<Either>`.
  ///
  /// When this value is [Right], it returns a [TaskEither] that will resolve to
  /// the result of calling `f`.
  /// Otherwise, if this value is [Left], it returns `TaskEither.left()`.
  TaskEither<L, R2> bindFuture<R2>(Future<Either<L, R2>> Function(R r) f);

  /// If the [Either] is [Left], then change its value from type `L` to
  /// type `C` using function `f`.
  Either<C, R> mapLeft<C>(C Function(L a) f);

  /// Convert this [Either] to a [Option]:
  /// - If the [Either] is [Left], throw away its value and just return [None]
  /// - If the [Either] is [Right], return a [Some] containing the value inside [Right]
  Option<R> toOption();

  /// Convert this [Either] to a [IOEither].
  IOEither<L, R> toIOEither();

  /// Convert this [Either] to a [TaskEither].
  ///
  /// Used to convert a sync context ([Either]) to an async context ([TaskEither]).
  /// You should convert [Either] to [TaskEither] every time you need to
  /// call an async ([Future]) function based on the value in [Either].
  TaskEither<L, R> toTaskEither();

  /// Convert [Either] to nullable `R?`.
  ///
  /// **Note**: this loses information about a possible [Left] value,
  /// converting it to simply `null`.
  R? toNullable();

  /// Return `true` when this [Either] is [Left].
  bool isLeft();

  /// Return `true` when this [Either] is [Right].
  bool isRight();

  /// Extract the value from [Left] in a [Option].
  ///
  /// If the [Either] is [Right], return [None].
  Option<L> getLeft();

  /// Extract the value from [Right] in a [Option].
  ///
  /// If the [Either] is [Left], return [None].
  ///
  /// Same as `toOption`.
  Option<R> getRight() => toOption();

  /// Swap the values contained inside the [Left] and [Right] of this [Either].
  Either<R, L> swap();

  /// If this [Either] is [Left], return the result of `onLeft`.
  ///
  /// Used to recover from errors, so that when this value is [Left] you
  /// try another function that returns an [Either].
  Either<L1, R> orElse<L1>(Either<L1, R> Function(L l) onLeft);

  /// Return the value inside this [Either] if it is a [Right].
  /// Otherwise return result of `onElse`.
  R getOrElse(R Function(L l) orElse);

  /// Execute `onLeft` when value is [Left], otherwise execute `onRight`.
  ///
  /// Same as `fold`.
  C match<C>(C Function(L l) onLeft, C Function(R r) onRight);

  /// Execute `onLeft` when value is [Left], otherwise execute `onRight`.
  ///
  /// Same as `match`.
  C fold<C>(C Function(L l) onLeft, C Function(R r) onRight) =>
      match<C>(onLeft, onRight);

  /// Return `true` when value of `r` is equal to the value inside this [Either].
  /// If this [Either] is [Left], then return `false`.
  bool elem(R r, Eq<R> eq);

  /// Return the result of calliing `predicate` with the value of [Either] if it is a [Right].
  /// Otherwise return `false`.
  bool exists(bool Function(R r) predicate);

  /// {@template fpdart_traverse_list_either}
  /// Map each element in the list to an [Either] using the function `f`,
  /// and collect the result in an `Either<E, List<B>>`.
  ///
  /// If any mapped element of the list is [Left], then the final result
  /// will be [Left].
  /// {@endtemplate}
  ///
  /// Same as `Either.traverseList` but passing `index` in the map function.
  static Either<E, List<B>> traverseListWithIndex<E, A, B>(
    List<A> list,
    Either<E, B> Function(A a, int i) f,
  ) {
    final resultList = <B>[];
    for (var i = 0; i < list.length; i++) {
      final e = f(list[i], i);
      if (e is Left<E, B>) {
        return left(e._value);
      } else if (e is Right<E, B>) {
        resultList.add(e._value);
      } else {
        throw Exception(
          "[fpdart]: Error when mapping Either, it should be either Left or Right.",
        );
      }
    }

    return right(resultList);
  }

  /// {@macro fpdart_traverse_list_either}
  ///
  /// Same as `Either.traverseListWithIndex` but without `index` in the map function.
  static Either<E, List<B>> traverseList<E, A, B>(
    List<A> list,
    Either<E, B> Function(A a) f,
  ) =>
      traverseListWithIndex<E, A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_either}
  /// Convert a `List<Either<E, A>>` to a single `Either<E, List<A>>`.
  ///
  /// If any of the [Either] in the [List] is [Left], then the result is [Left].
  /// {@endtemplate}
  static Either<E, List<A>> sequenceList<E, A>(
    List<Either<E, A>> list,
  ) =>
      traverseList(list, identity);

  /// {@template fpdart_rights_either}
  /// Extract all the [Right] values from a `List<Either<E, A>>`.
  /// {@endtemplate}
  static List<A> rights<E, A>(List<Either<E, A>> list) {
    final resultList = <A>[];
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      if (e is Right<E, A>) {
        resultList.add(e._value);
      }
    }

    return resultList;
  }

  /// {@template fpdart_lefts_either}
  /// Extract all the [Left] values from a `List<Either<E, A>>`.
  /// {@endtemplate}
  static List<E> lefts<E, A>(List<Either<E, A>> list) {
    final resultList = <E>[];
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      if (e is Left<E, A>) {
        resultList.add(e._value);
      }
    }

    return resultList;
  }

  /// {@template fpdart_partition_eithers_either}
  /// Extract all the [Left] and [Right] values from a `List<Either<E, A>>` and
  /// return them in two partitioned [List] inside a record.
  /// {@endtemplate}
  static (List<E>, List<A>) partitionEithers<E, A>(List<Either<E, A>> list) {
    final resultListLefts = <E>[];
    final resultListRights = <A>[];
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      if (e is Left<E, A>) {
        resultListLefts.add(e._value);
      } else if (e is Right<E, A>) {
        resultListRights.add(e._value);
      } else {
        throw Exception(
          "[fpdart]: Error when mapping Either, it should be either Left or Right.",
        );
      }
    }

    return (resultListLefts, resultListRights);
  }

  /// Flat a [Either] contained inside another [Either] to be a single [Either].
  factory Either.flatten(Either<L, Either<L, R>> e) => e.flatMap(identity);

  /// Return a `Right(r)`.
  ///
  /// Same as `Either.right(r)`.
  factory Either.of(R r) => Right(r);

  /// Return a `Right(r)`.
  ///
  /// Same as `Either.of(r)`.
  factory Either.right(R r) => Right(r);

  /// Return a `Left(l)`.
  factory Either.left(L l) => Left(l);

  /// Return an [Either] from a [Option]:
  /// - If [Option] is [Some], then return [Right] containing its value
  /// - If [Option] is [None], then return [Left] containing the result of `onNone`
  factory Either.fromOption(Option<R> m, L Function() onNone) => m.match(
        () => Either.left(onNone()),
        (r) => Either.of(r),
      );

  /// If calling `predicate` with `r` returns `true`, then return `Right(r)`.
  /// Otherwise return [Left] containing the result of `onFalse`.
  factory Either.fromPredicate(
          R r, bool Function(R r) predicate, L Function(R r) onFalse) =>
      predicate(r) ? Either.of(r) : Either.left(onFalse(r));

  /// If `r` is `null`, then return the result of `onNull` in [Left].
  /// Otherwise return `Right(r)`.
  factory Either.fromNullable(R? r, L Function() onNull) =>
      r != null ? Either.of(r) : Either.left(onNull());

  /// Try to execute `run`. If no error occurs, then return [Right].
  /// Otherwise return [Left] containing the result of `onError`.
  factory Either.tryCatch(
      R Function() run, L Function(Object o, StackTrace s) onError) {
    try {
      return Either.of(run());
    } catch (e, s) {
      return Either.left(onError(e, s));
    }
  }

  /// {@template fpdart_safe_cast_either}
  /// Safely cast a value to type `R`.
  ///
  /// If `value` is not of type `R`, then return a [Left]
  /// containing the result of `onError`.
  /// {@endtemplate}
  ///
  /// Less strict version of `Either.safeCastStrict`, since `safeCast`
  /// assumes the value to be `dynamic`.
  ///
  /// **Note**: Make sure to specify the types of [Either] (`Either<L, R>.safeCast`
  /// instead of `Either.safeCast`), otherwise this will always return [Right]!
  factory Either.safeCast(
    dynamic value,
    L Function(dynamic value) onError,
  ) =>
      Either.safeCastStrict<L, R, dynamic>(value, onError);

  /// {@macro fpdart_safe_cast_either}
  ///
  /// More strict version of `Either.safeCast`, in which also the **input value
  /// type** must be specified (while in `Either.safeCast` the type is `dynamic`).
  static Either<L, R> safeCastStrict<L, R, V>(
    V value,
    L Function(V value) onError,
  ) =>
      value is R ? Either<L, R>.of(value) : Either<L, R>.left(onError(value));

  /// Try to execute `run`. If no error occurs, then return [Right].
  /// Otherwise return [Left] containing the result of `onError`.
  ///
  /// `run` has one argument, which allows for easier chaining with
  /// `Either.flatMap`.
  static Either<L, R> Function(T) tryCatchK<L, R, T>(
          R Function(T) run, L Function(Object o, StackTrace s) onError) =>
      (a) => Either.tryCatch(
            () => run(a),
            onError,
          );

  /// Build an `Eq<Either>` by comparing the values inside two [Either].
  ///
  /// Return `true` when the two [Either] are equal or when both are [Left] or
  /// [Right] and comparing using `eqL` or `eqR` returns `true`.
  static Eq<Either<L, R>> getEq<L, R>(Eq<L> eqL, Eq<R> eqR) =>
      Eq.instance((e1, e2) =>
          e1 == e2 ||
          (e1.match((l1) => e2.match((l2) => eqL.eqv(l1, l2), (_) => false),
              (r1) => e2.match((_) => false, (r2) => eqR.eqv(r1, r2)))));

  /// Build a `Semigroup<Either>` from a [Semigroup].
  ///
  /// If both are [Right], then return [Right] containing the result of `combine` from
  /// `semigroup`. Otherwise return [Right] if any of the two [Either] is [Right].
  ///
  /// When both are [Left], return the first [Either].
  static Semigroup<Either<L, R>> getSemigroup<L, R>(Semigroup<R> semigroup) =>
      Semigroup.instance((e1, e2) => e2.match(
          (_) => e1,
          (r2) => e1.match(
              (_) => e2, (r1) => Either.of(semigroup.combine(r1, r2)))));
}

class Right<L, R> extends Either<L, R> {
  final R _value;
  const Right(this._value);

  /// Extract the value of type `R` inside the [Right].
  R get value => _value;

  @override
  Either<L, D> map2<C, D>(covariant Either<L, C> m1, D Function(R b, C c) f) =>
      flatMap((b) => m1.map((c) => f(b, c)));

  @override
  Either<L, E> map3<C, D, E>(covariant Either<L, C> m1,
          covariant Either<L, D> m2, E Function(R b, C c, D d) f) =>
      flatMap((b) => m1.flatMap((c) => m2.map((d) => f(b, c, d))));

  @override
  Either<L, C> map<C>(C Function(R a) f) => Right<L, C>(f(_value));

  @override
  Either<C, R> mapLeft<C>(C Function(L a) f) => Right<C, R>(_value);

  @override
  C foldRight<C>(C b, C Function(C acc, R a) f) => f(b, _value);

  @override
  C match<C>(C Function(L l) onLeft, C Function(R r) onRight) =>
      onRight(_value);

  @override
  Either<L, C> flatMap<C>(covariant Either<L, C> Function(R a) f) => f(_value);

  @override
  Option<R> toOption() => Some(_value);

  @override
  bool isLeft() => false;

  @override
  bool isRight() => true;

  @override
  Either<R, L> swap() => Left(_value);

  @override
  Either<L, R> alt(covariant Either<L, R> Function() orElse) => this;

  @override
  Option<L> getLeft() => Option.none();

  @override
  Either<L, Z> extend<Z>(Z Function(Either<L, R> t) f) => Either.of(f(this));

  @override
  Either<L1, R> orElse<L1>(Either<L1, R> Function(L l) onLeft) =>
      Either.of(_value);

  @override
  R getOrElse(R Function(L l) orElse) => _value;

  @override
  bool elem(R r, Eq<R> eq) => eq.eqv(r, _value);

  @override
  bool exists(bool Function(R r) predicate) => predicate(_value);

  @override
  bool operator ==(Object other) => (other is Right) && other._value == _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Right($_value)';

  @override
  TaskEither<L, R2> bindFuture<R2>(Future<Either<L, R2>> Function(R r) f) =>
      TaskEither(() async => f(_value));

  @override
  TaskEither<L, R> toTaskEither() => TaskEither.of(_value);

  @override
  IOEither<L, R> toIOEither() => IOEither.of(_value);

  @override
  R? toNullable() => _value;
}

class Left<L, R> extends Either<L, R> {
  final L _value;
  const Left(this._value);

  /// Extract the value of type `L` inside the [Left].
  L get value => _value;

  @override
  Either<L, D> map2<C, D>(covariant Either<L, C> m1, D Function(R b, C c) f) =>
      flatMap((b) => m1.map((c) => f(b, c)));

  @override
  Either<L, E> map3<C, D, E>(covariant Either<L, C> m1,
          covariant Either<L, D> m2, E Function(R b, C c, D d) f) =>
      flatMap((b) => m1.flatMap((c) => m2.map((d) => f(b, c, d))));

  @override
  Either<L, C> map<C>(C Function(R a) f) => Left<L, C>(_value);

  @override
  Either<C, R> mapLeft<C>(C Function(L a) f) => Left<C, R>(f(_value));

  @override
  C foldRight<C>(C b, C Function(C acc, R a) f) => b;

  @override
  C match<C>(C Function(L l) onLeft, C Function(R r) onRight) => onLeft(_value);

  @override
  Either<L, C> flatMap<C>(covariant Either<L, C> Function(R a) f) =>
      Left<L, C>(_value);

  @override
  Option<R> toOption() => Option.none();

  @override
  bool isLeft() => true;

  @override
  bool isRight() => false;

  @override
  Either<R, L> swap() => Right(_value);

  @override
  Either<L, R> alt(covariant Either<L, R> Function() orElse) => orElse();

  @override
  Option<L> getLeft() => Some(_value);

  @override
  Either<L, Z> extend<Z>(Z Function(Either<L, R> t) f) => Either.left(_value);

  @override
  Either<L1, R> orElse<L1>(Either<L1, R> Function(L l) onLeft) =>
      onLeft(_value);

  @override
  R getOrElse(R Function(L l) orElse) => orElse(_value);

  @override
  bool elem(R r, Eq<R> eq) => false;

  @override
  bool exists(bool Function(R r) predicate) => false;

  @override
  bool operator ==(Object other) => (other is Left) && other._value == _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Left($_value)';

  @override
  TaskEither<L, R2> bindFuture<R2>(Future<Either<L, R2>> Function(R r) f) =>
      TaskEither.left(_value);

  @override
  TaskEither<L, R> toTaskEither() => TaskEither.left(_value);

  @override
  IOEither<L, R> toIOEither() => IOEither.left(_value);

  @override
  R? toNullable() => null;
}
