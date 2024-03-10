part of "effect.dart";

sealed class NOption<R> extends IEffect<dynamic, dynamic, R> {
  const NOption._(UnsafeRun<dynamic, dynamic, R> run) : super._(run);

  @override
  NOption<C> flatMap<C>(covariant NOption<C> Function(R r) f) {
    return switch (this) {
      NNone() => NNone<dynamic>(),
      NSome(value: final value) => f(value),
    };
  }

  @override
  NOption<V> ap<V>(
    covariant NOption<V Function(R r)> f,
  ) =>
      f.flatMap(
        (f) => flatMap(
          (v) => NSome(f(v)),
        ),
      );

  @override
  NOption<V> map<V>(V Function(R r) f) => ap(NSome(f));

  Effect<V, L, R> withEnv<L, V>(L Function() onNone) => Effect._(
        (env) => switch (this) {
          NNone() => Exit.failure(onNone()),
          NSome(value: final value) => Exit.success(value),
        },
      );
}

// ignore: missing_override_of_must_be_overridden
class NSome<R> extends NOption<R> {
  final R value;
  NSome(this.value) : super._((_) => Exit.success(value));
}

// ignore: missing_override_of_must_be_overridden
class NNone<R> extends NOption<Never> {
  NNone() : super._((_) => Exit.failure(null));
}
