part of "effect.dart";

sealed class Option<R> extends IEffect<void, Never, R> {
  const Option();

  factory Option.safeCast(dynamic value) =>
      Option.safeCastStrict<R, dynamic>(value);

  static Option<R> safeCastStrict<R, V>(V value) {
    if (value is R) return Some(value);
    return None();
  }

  factory Option.fromPredicate(R value, bool Function(R r) predicate) {
    if (predicate(value)) return Some(value);
    return None();
  }

  factory Option.fromNullable(R? value) {
    if (value != null) return Some(value);
    return None();
  }

  factory Option.tryCatch(R Function() f) {
    try {
      return Some(f());
    } catch (_) {
      return None();
    }
  }

  R? toNullable();
  Option<C> flatMap<C>(Option<C> Function(R r) f);

  Option<V> ap<V>(
    Option<V Function(R r)> f,
  ) =>
      f.flatMap(
        (f) => flatMap(
          (v) => Some(f(v)),
        ),
      );

  Either<L, R> toEither<L>(L Function() onLeft) => switch (this) {
        Some(value: final value) => Right(value),
        None() => Left(onLeft()),
      };

  Option<V> map<V>(V Function(R r) f) => ap(Some(f));

  Effect<V, L, R> provide<L, V>(L Function() onNone) => Effect._(
        (env) => switch (this) {
          None() => Left(Fail(onNone())),
          Some(value: final value) => Right(value),
        },
      );
}

final class Some<R> extends Option<R> {
  final R value;
  const Some(this.value);

  @override
  Effect<void, Never, R> get asEffect => Effect.succeed(value).orDie;

  @override
  Effect<V, L, R> provide<L, V>(L Function() onNone) => Effect.succeed(value);

  Option<C> andThen<C>(Option<C> Function() then) => then();

  @override
  Option<C> flatMap<C>(Option<C> Function(R r) f) => f(value);

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
  static const None _none = None._instance();
  const None._instance();

  factory None() => _none;

  @override
  @internal

  /// **This will always throw, don't use it!**
  // ignore: cast_from_null_always_fails
  Effect<void, Never, Never> get asEffect => Effect.fail(null as Never);

  Option<C> andThen<C>(Option<C> Function() then) => this;

  @override
  Option<C> flatMap<C>(Option<C> Function(Never r) f) => this;

  @override
  Null toNullable() => null;

  @override
  String toString() => 'None';
}
