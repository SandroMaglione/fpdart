part of "effect.dart";

sealed class Option<R> extends IEffect<Never, Never, R> {
  const Option();

  R? toNullable();

  Either<L, R> toEither<L>(L Function() onLeft) => switch (this) {
        Some(value: final value) => Right(value),
        None() => Left(onLeft()),
      };

  Option<C> flatMap<C>(covariant Option<C> Function(R r) f) {
    return switch (this) {
      None() => None(),
      Some(value: final value) => f(value),
    };
  }

  Option<V> ap<V>(
    covariant Option<V Function(R r)> f,
  ) =>
      f.flatMap(
        (f) => flatMap(
          (v) => Some(f(v)),
        ),
      );

  Option<V> map<V>(V Function(R r) f) => ap(Some(f));

  Effect<V, L, R> provide<L, V>(L Function() onNone) => Effect._(
        (env) => switch (this) {
          None() => Exit.failure(onNone()),
          Some(value: final value) => Exit.success(value),
        },
      );
}

final class Some<R> extends Option<R> {
  final R value;
  const Some(this.value);

  @override
  Effect<Never, Never, R> get asEffect => Effect.succeed(value);

  Option<C> andThen<C>(covariant Option<C> Function() then) => then();

  @override
  R toNullable() => value;

  @override
  Either<L, R> toEither<L>(L Function() onLeft) => Right(value);

  @override
  bool operator ==(Object other) => (other is Some) && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Some($value)';
}

final class None extends Option<Never> {
  const None();

  @override
  @internal

  /// **This will always throw, don't use it!**
  // ignore: cast_from_null_always_fails
  Effect<Never, Never, Never> get asEffect => Effect.fail(null as Never);

  Option<C> andThen<C>(covariant Option<C> Function() then) => this;

  @override
  Null toNullable() => null;

  @override
  bool operator ==(Object other) => other is None;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'None';
}
