part of "effect.dart";

sealed class NOption<R> extends IEffect<dynamic, dynamic, R> {
  const NOption();

  NOption<C> flatMap<C>(covariant NOption<C> Function(R r) f) {
    return switch (this) {
      NNone() => NNone<dynamic>(),
      NSome(value: final value) => f(value),
    };
  }

  NOption<V> ap<V>(
    covariant NOption<V Function(R r)> f,
  ) =>
      f.flatMap(
        (f) => flatMap(
          (v) => NSome(f(v)),
        ),
      );

  NOption<V> map<V>(V Function(R r) f) => ap(NSome(f));

  Effect<V, L, R> withEnv<L, V>(L Function() onNone) => Effect._(
        (env) => switch (this) {
          NNone() => Exit.failure(onNone()),
          NSome(value: final value) => Exit.success(value),
        },
      );
}

final class NSome<R> extends NOption<R> {
  final R value;
  const NSome(this.value);

  @override
  Effect<dynamic, dynamic, R> get asEffect => Effect.succeed(value);

  NOption<C> andThen<C>(covariant NOption<C> Function() then) => then();
}

final class NNone<R> extends NOption<Never> {
  const NNone();

  @override
  Effect<dynamic, dynamic, Never> get asEffect => Effect.fail(null);

  NOption<C> andThen<C>(covariant NOption<C> Function() then) => this;
}
