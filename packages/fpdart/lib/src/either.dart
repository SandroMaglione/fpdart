part of "effect.dart";

sealed class Either<L, R> extends IEffect<Never, L, R> {
  const Either();

  R? toNullable();
  Option<R> toOption();

  Either<L, C> flatMap<C>(covariant Either<L, C> Function(R r) f) {
    return switch (this) {
      Left(value: final value) => Left(value),
      Right(value: final value) => f(value),
    };
  }

  Either<L, V> ap<V>(
    covariant Either<L, V Function(R r)> f,
  ) =>
      f.flatMap(
        (f) => flatMap(
          (v) => Right(f(v)),
        ),
      );

  Either<L, V> map<V>(V Function(R r) f) => ap(Right(f));

  Effect<V, L, R> provide<V>() => Effect._(
        (env) => switch (this) {
          Left(value: final value) => Exit.failure(value),
          Right(value: final value) => Exit.success(value),
        },
      );

  Either<C, R> mapLeft<C>(C Function(L l) f) => switch (this) {
        Left(value: final value) => Left(f(value)),
        Right(value: final value) => Right(value),
      };
}

final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  Effect<Never, L, R> get asEffect => Effect.succeed(value);

  Either<L, C> andThen<C>(covariant Either<L, C> Function() then) => then();

  Either<C, R> orElse<C>(covariant Either<C, R> Function(L l) orElse) =>
      Right(value);

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

  Either<L, C> andThen<C>(covariant Either<L, C> Function() then) =>
      Left(value);

  Either<C, R> orElse<C>(covariant Either<C, R> Function(L l) orElse) =>
      orElse(value);

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
