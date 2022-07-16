import 'function.dart';
import 'option.dart';
import 'task_either.dart';
import 'tuple.dart';
import 'typeclass/typeclass.export.dart';

/// Return a `Right(r)`.
///
/// Shortcut for `Either.of(r)`.
Either<L, R> right<L, R>(R r) => Right<L, R>(r);

/// Return a `Left(l)`.
///
/// Shortcut for `Either.left(l)`.
Either<L, R> left<L, R>(L l) => Left<L, R>(l);

/// Tag the [HKT2] interface for the actual [Either].
abstract class _EitherHKT {}

/// Represents a value of one of two possible types, [Left] or [Right].
///
/// [Either] is commonly used to **handle errors**. Instead of returning placeholder
/// values when a computation may fail (such as `-1`, `null`, etc.), we return an instance
/// of [Right] containing the correct result when a computation is successful, otherwise we return
/// an instance of [Left] containing information about the kind of error that occurred.
abstract class Either<L, R> extends HKT2<_EitherHKT, L, R>
    with
        Functor2<_EitherHKT, L, R>,
        Applicative2<_EitherHKT, L, R>,
        Monad2<_EitherHKT, L, R>,
        Foldable2<_EitherHKT, L, R>,
        Alt2<_EitherHKT, L, R>,
        Extend2<_EitherHKT, L, R> {
  const Either();

  /// Return the result of `f` called with `b` and the value of [Right].
  /// If this [Either] is [Left], return `b`.
  @override
  C foldRight<C>(C b, C Function(C acc, R b) f);

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
      foldRight<Tuple2<C, int>>(
        Tuple2(c, length() - 1),
        (t, b) => Tuple2(f(t.second, t.first, b), t.second - 1),
      ).first;

  /// Return the result of `f` called with `b` and the value of [Right].
  /// If this [Either] is [Left], return `b`.
  @override
  C foldLeftWithIndex<C>(C c, C Function(int i, C acc, R b) f) =>
      foldLeft<Tuple2<C, int>>(
        Tuple2(c, 0),
        (t, b) => Tuple2(f(t.second, t.first, b), t.second + 1),
      ).first;

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

  /// Return a [Right] containing the value `c`.
  @override
  Either<L, C> pure<C>(C c) => Right<L, C>(c);

  /// Apply the function contained inside `a` to change the value on the [Right] from
  /// type `R` to a value of type `C`.
  @override
  Either<L, C> ap<C>(covariant Either<L, C Function(R r)> a) =>
      a.flatMap((f) => map(f));

  /// Used to chain multiple functions that return a [Either].
  ///
  /// You can extract the value of every [Right] in the chain without
  /// handling all possible missing cases.
  /// If any of the functions in the chain returns [Left], the result is [Left].
  ///
  /// Same as `bind`.
  @override
  Either<L, C> flatMap<C>(covariant Either<L, C> Function(R a) f);

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

  /// If `f` applied on this [Either] as [Right] returns `true`, then return this [Either].
  /// If it returns `false`, return the result of `onFalse` in a [Left].
  Either<L, R> filterOrElse(bool Function(R r) f, L Function(R r) onFalse) =>
      flatMap((r) => f(r) ? Either.of(r) : Either.left(onFalse(r)));

  /// Used to chain multiple functions that return a [Either].
  ///
  /// You can extract the value of every [Right] in the chain without
  /// handling all possible missing cases.
  /// If any of the functions in the chain returns [Left], the result is [Left].
  ///
  /// Same as `flatMap`.
  Either<L, R2> bind<R2>(Either<L, R2> Function(R r) f) => flatMap(f);

  /// Chain a request that returns another [Either], execute it, ignore
  /// the result, and return the same value as the current [Either].
  @override
  Either<L, R> chainFirst<C>(
    covariant Either<L, C> Function(R b) chain,
  ) =>
      flatMap((b) => chain(b).map((c) => b));

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

  /// Convert this [Either] to a [TaskEither].
  ///
  /// Used to convert a sync context ([Either]) to an async context ([TaskEither]).
  /// You should convert [Either] to [TaskEither] every time you need to
  /// call an async ([Future]) function based on the value in [Either].
  TaskEither<L, R> toTaskEither();

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
  factory Either.fromOption(Option<R> m, L Function() onNone) =>
      m.match((r) => Either.of(r), () => Either.left(onNone()));

  /// If calling `predicate` with `r` returns `true`, then return `Right(r)`.
  /// Otherwise return [Left] containing the result of `onFalse`.
  factory Either.fromPredicate(
          R r, bool Function(R r) predicate, L Function(R r) onFalse) =>
      predicate(r) ? Either.of(r) : Either.left(onFalse(r));

  /// If `r` is `null`, then return the result of `onNull` in [Left].
  /// Otherwise return `Right(r)`.
  factory Either.fromNullable(R? r, L Function(R? r) onNull) =>
      r != null ? Either.of(r) : Either.left(onNull(r));

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
}
