part of "effect.dart";

sealed class Option<R> extends IEffect<Never, Never, R> {
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

  factory Option.fromJson(
    dynamic json,
    R Function(dynamic json) fromJson,
  ) =>
      json != null ? Option.tryCatch(() => fromJson(json)) : None();

  static Iterable<R> getSomes<R>(Iterable<Option<R>> iterable) sync* {
    for (var option in iterable) {
      if (option is Some<R>) {
        yield option.value;
      }
    }
  }

  Object? toJson(Object? Function(R value) toJson);
  R? getOrNull();
  Option<C> flatMap<C>(Option<C> Function(R r) f);
  Option<C> andThen<C>(C Function(R r) f);
  Option<R> tap<C>(Option<C> Function(R r) f);
  Option<R> filter(bool Function(R r) f);
  Option<C> filterMap<C>(Option<C> Function(R r) f);

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
          None() => Left(Failure(onNone())),
          Some(value: final value) => Right(value),
        },
      );
}

final class Some<R> extends Option<R> {
  final R value;
  const Some(this.value);

  @override
  Effect<Never, Never, R> get asEffect => Effect._((_) => Right(value));

  @override
  Effect<V, L, R> provide<L, V>(L Function() onNone) => Effect.succeed(value);

  @override
  Option<C> flatMap<C>(Option<C> Function(R r) f) => f(value);

  @override
  R getOrNull() => value;

  @override
  Option<C> andThen<C>(C Function(R r) f) => Some(f(value));

  @override
  Either<L, R> toEither<L>(L Function() onLeft) => Right(value);

  @override
  Object? toJson(Object? Function(R value) toJson) => toJson(value);

  @override
  bool operator ==(Object other) => (other is Some) && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Some($value)';

  @override
  Option<R> tap<C>(Option<C> Function(R r) f) => f(value).map((_) => value);

  @override
  Option<R> filter(bool Function(R r) f) {
    if (f(value)) return Some(value);
    return None();
  }

  @override
  Option<C> filterMap<C>(Option<C> Function(R r) f) {
    if (f(value) case Some(value: final value)) return Some(value);
    return None();
  }
}

final class None extends Option<Never> {
  static const None _none = None._instance();
  const None._instance();

  factory None() => _none;

  @override
  Effect<Never, Never, Never> get asEffect =>
      // ignore: cast_from_null_always_fails
      Effect._((_) => Left(Failure(null as Never)));

  @override
  Option<C> flatMap<C>(Option<C> Function(Never r) f) => this;

  @override
  Null getOrNull() => null;

  @override
  Object? toJson(Object? Function(Never value) toJson) => None();

  @override
  String toString() => 'None';

  @override
  Option<C> andThen<C>(C Function(Never r) f) => None();

  @override
  Option<Never> tap<C>(Option<C> Function(Never r) f) => None();

  @override
  Option<Never> filter(bool Function(Never r) f) => None();

  @override
  Option<C> filterMap<C>(Option<C> Function(Never r) f) => None();
}
