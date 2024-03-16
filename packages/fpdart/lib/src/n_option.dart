part of "effect.dart";

sealed class NOption<R> extends IEffect<Never, Never, R> {
  const NOption();

  NOption<C> flatMap<C>(covariant NOption<C> Function(R r) f) {
    return switch (this) {
      NNone() => NNone<Never>(),
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

  Effect<V, L, R> provide<L, V>(L Function() onNone) => Effect._(
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
  Effect<Never, Never, R> get asEffect => Effect.succeed(value);

  NOption<C> andThen<C>(covariant NOption<C> Function() then) => then();
}

final class NNone<R> extends NOption<Never> {
  const NNone();

  @override
  @internal

  /// **This will always throw, don't use it!**
  // ignore: cast_from_null_always_fails
  Effect<Never, Never, Never> get asEffect => Effect.fail(null as Never);

  NOption<C> andThen<C>(covariant NOption<C> Function() then) => this;
}
