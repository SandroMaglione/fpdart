part of "effect.dart";

sealed class Either<L, R> extends IEffect<Never, L, R> {
  const Either();

  /// If calling `predicate` with `r` returns `true`, then return `Right(r)`.
  /// Otherwise return [Left] containing the result of `onFalse`.
  factory Either.fromPredicate(
    R r,
    bool Function(R r) predicate,
    L Function(R r) onFalse,
  ) =>
      predicate(r) ? Right(r) : Left(onFalse(r));

  factory Either.fromNullable(R? r, L Function() onNull) =>
      r != null ? Right(r) : Left(onNull());

  factory Either.tryCatch({
    required R Function() execute,
    required L Function(Object o, StackTrace s) onError,
  }) {
    try {
      return Right(execute());
    } catch (e, s) {
      return Left(onError(e, s));
    }
  }

  factory Either.safeCast(
    dynamic value,
    L Function(dynamic value) onError,
  ) =>
      Either.safeCastStrict<L, R, dynamic>(value, onError);

  static Either<L, R> safeCastStrict<L, R, V>(
    V value,
    L Function(V value) onError,
  ) =>
      value is R ? Right(value) : Left(onError(value));

  static Iterable<R> getRights<L, R>(Iterable<Either<L, R>> iterable) sync* {
    for (var either in iterable) {
      if (either is Right<L, R>) {
        yield either.value;
      }
    }
  }

  static Iterable<L> getLefts<L, R>(Iterable<Either<L, R>> iterable) sync* {
    for (var either in iterable) {
      if (either is Left<L, R>) {
        yield either.value;
      }
    }
  }

  R? getOrNull();
  Either<L, C> flatMap<C>(Either<L, C> Function(R r) f);
  Either<C, R> mapLeft<C>(C Function(L l) f);
  Effect<V, L, R> provide<V>();
  Either<D, C> mapBoth<C, D>({
    required D Function(L l) onLeft,
    required C Function(R r) onRight,
  });
  Either<R, L> flip();
  R getOrElse(R Function(L l) orElse);
  Either<L, C> andThen<C>(C Function(R r) f);
  Either<C, R> orElse<C>(Either<C, R> Function(L l) orElse);
  Either<L, R> tap<C>(Either<L, C> Function(R r) f);
  Either<L, R> filterOrLeft<C>({
    required bool Function(R r) predicate,
    required L Function(R r) orLeftWith,
  });
  Option<L> getLeft();
  Option<R> getRight();

  Either<L, V> ap<V>(
    Either<L, V Function(R r)> f,
  ) =>
      f.flatMap(
        (f) => flatMap(
          (v) => Right(f(v)),
        ),
      );

  Either<L, V> map<V>(V Function(R r) f) => ap(Right(f));
}

final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  Effect<Never, L, R> get asEffect => Effect._((_) => Right(value));

  @override
  Either<L, C> andThen<C>(C Function(R value) f) => Right(f(value));

  @override
  Either<C, R> orElse<C>(Either<C, R> Function(L l) orElse) => Right(value);

  @override
  R getOrElse(R Function(L l) orElse) => value;

  @override
  Either<R, L> flip() => Left(value);

  @override
  Either<D, C> mapBoth<C, D>(
          {required D Function(L l) onLeft,
          required C Function(R r) onRight}) =>
      Right(onRight(value));

  @override
  Either<C, R> mapLeft<C>(C Function(L l) f) => Right(value);

  @override
  Either<L, C> flatMap<C>(Either<L, C> Function(R r) f) => f(value);

  @override
  Effect<V, L, R> provide<V>() => Effect.succeed(value);

  @override
  R getOrNull() => value;

  @override
  Option<R> getRight() => Some(value);

  @override
  bool operator ==(Object other) => (other is Right) && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';

  @override
  Either<L, R> filterOrLeft<C>({
    required bool Function(R r) predicate,
    required L Function(R r) orLeftWith,
  }) =>
      predicate(value) ? Right(value) : Left(orLeftWith(value));

  @override
  Option<L> getLeft() => None();

  @override
  Either<L, R> tap<C>(Either<L, C> Function(R r) f) =>
      f(value).map((_) => value);
}

final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  Effect<Never, L, R> get asEffect => Effect._((_) => Left(Fail(value)));

  @override
  Either<L, C> andThen<C>(C Function(R value) f) => Left(value);

  @override
  Either<C, R> orElse<C>(Either<C, R> Function(L l) orElse) => orElse(value);

  @override
  R getOrElse(R Function(L l) orElse) => orElse(value);

  @override
  Either<R, L> flip() => Right(value);

  @override
  Either<D, C> mapBoth<C, D>(
          {required D Function(L l) onLeft,
          required C Function(R r) onRight}) =>
      Left(onLeft(value));

  @override
  Either<C, R> mapLeft<C>(C Function(L l) f) => Left(f(value));

  @override
  Either<L, C> flatMap<C>(Either<L, C> Function(R r) f) => Left(value);

  @override
  Effect<V, L, R> provide<V>() => Effect.fail(value);

  @override
  R? getOrNull() => null;

  @override
  Option<R> getRight() => None();

  @override
  bool operator ==(Object other) => (other is Left) && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';

  @override
  Either<L, R> filterOrLeft<C>({
    required bool Function(R r) predicate,
    required L Function(R r) orLeftWith,
  }) =>
      Left(value);

  @override
  Option<L> getLeft() => Some(value);

  @override
  Either<L, R> tap<C>(Either<L, C> Function(R r) f) => Left(value);
}
