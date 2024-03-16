part of "effect.dart";

sealed class NEither<L, R> extends IEffect<Never, L, R> {
  const NEither();

  NEither<L, C> flatMap<C>(covariant NEither<L, C> Function(R r) f) {
    return switch (this) {
      NLeft(value: final value) => NLeft(value),
      NRight(value: final value) => f(value),
    };
  }

  NEither<L, V> ap<V>(
    covariant NEither<L, V Function(R r)> f,
  ) =>
      f.flatMap(
        (f) => flatMap(
          (v) => NRight(f(v)),
        ),
      );

  NEither<L, V> map<V>(V Function(R r) f) => ap(NRight(f));

  Effect<V, L, R> provide<V>() => Effect._(
        (env) => switch (this) {
          NLeft(value: final value) => Exit.failure(value),
          NRight(value: final value) => Exit.success(value),
        },
      );

  NEither<C, R> mapLeft<C>(C Function(L l) f) => switch (this) {
        NLeft(value: final value) => NLeft(f(value)),
        NRight(value: final value) => NRight(value),
      };
}

final class NRight<L, R> extends NEither<L, R> {
  final R value;
  const NRight(this.value);

  @override
  Effect<Never, L, R> get asEffect => Effect.succeed(value);

  NEither<L, C> andThen<C>(covariant NEither<L, C> Function() then) => then();

  NEither<C, R> orElse<C>(covariant NEither<C, R> Function(L l) orElse) =>
      NRight(value);
}

final class NLeft<L, R> extends NEither<L, R> {
  final L value;
  const NLeft(this.value);

  @override
  Effect<Never, L, R> get asEffect => Effect.fail(value);

  NEither<L, C> andThen<C>(covariant NEither<L, C> Function() then) =>
      NLeft(value);

  NEither<C, R> orElse<C>(covariant NEither<C, R> Function(L l) orElse) =>
      orElse(value);
}
