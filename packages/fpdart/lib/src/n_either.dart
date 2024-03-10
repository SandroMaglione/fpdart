part of "effect.dart";

sealed class NEither<L, R> extends IEffect<dynamic, L, R> {
  const NEither._(UnsafeRun<dynamic, L, R> run) : super._(run);

  @override
  NEither<L, C> flatMap<C>(covariant NEither<L, C> Function(R r) f) {
    return switch (this) {
      NLeft(value: final value) => NLeft(value),
      NRight(value: final value) => f(value),
    };
  }

  @override
  NEither<L, V> ap<V>(
    covariant NEither<L, V Function(R r)> f,
  ) =>
      f.flatMap(
        (f) => flatMap(
          (v) => NRight(f(v)),
        ),
      );

  @override
  NEither<L, V> map<V>(V Function(R r) f) => ap(NRight(f));

  Effect<V, L, R> withEnv<V>() => Effect._(
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

// ignore: missing_override_of_must_be_overridden
class NRight<L, R> extends NEither<L, R> {
  final R value;
  NRight(this.value) : super._((_) => Exit.success(value));
}

// ignore: missing_override_of_must_be_overridden
class NLeft<L, R> extends NEither<L, R> {
  final L value;
  NLeft(this.value) : super._((_) => Exit.failure(value));
}
