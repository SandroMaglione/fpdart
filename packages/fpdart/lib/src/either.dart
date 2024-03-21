part of "effect.dart";

sealed class Either<L, R> extends IEffect<Null, L, R> {
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

  R? toNullable();
  Option<R> toOption();
  Either<L, C> flatMap<C>(Either<L, C> Function(R r) f);
  Either<C, R> mapLeft<C>(C Function(L l) f);
  Effect<V, L, R> provide<V>();
  Either<D, C> mapBoth<C, D>({
    required D Function(L l) onLeft,
    required C Function(R r) onRight,
  });
  Either<R, L> get flip;
  R getOrElse(R Function(L l) orElse);

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
  Effect<Never, L, R> get asEffect => Effect.succeed(value);

  Either<L, C> andThen<C>(Either<L, C> Function() then) => then();

  Either<C, R> orElse<C>(Either<C, R> Function(L l) orElse) => Right(value);

  @override
  R getOrElse(R Function(L l) orElse) => value;

  @override
  Either<R, L> get flip => Left(value);

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
  R toNullable() => value;

  @override
  Option<R> toOption() => Some(value);

  @override
  bool operator ==(Object other) => (other is Right) && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}

final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  Effect<Never, L, R> get asEffect => Effect.fail(value);

  Either<L, C> andThen<C>(Either<L, C> Function() then) => Left(value);

  Either<C, R> orElse<C>(Either<C, R> Function(L l) orElse) => orElse(value);

  @override
  R getOrElse(R Function(L l) orElse) => orElse(value);

  @override
  Either<R, L> get flip => Right(value);

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
  R? toNullable() => null;

  @override
  Option<R> toOption() => None();

  @override
  bool operator ==(Object other) => (other is Left) && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}
