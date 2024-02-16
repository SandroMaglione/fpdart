part of "effect.dart";

final class Sync<R> extends IEffect<void, Never, R> {
  const Sync._(UnsafeRun<void, Never, R> run) : super._(run);

  factory Sync._fromEffect(IEffect<void, Never, R> effect) =>
      Sync._(effect._runEffect);

  factory Sync.make(
    R Function() execute,
  ) =>
      Sync._fromEffect(
        Effect<void, Never, R>.tryFuture(
          execute,
          (_, __) => throw Exception(
            "Error when building Sync.make",
          ),
        ),
      );

  factory Sync.value(R value) => Sync._(
        (_) => Either.right(value),
      );

  @override
  Sync<C> flatMap<C>(covariant Sync<C> Function(R r) f) {
    return Sync._fromEffect(super.flatMap(f));
  }

  R call() {
    final run = _unsafeRun(null);
    if (run is Future) {
      throw Exception("Error running an async Sync");
    }

    return run.match(
      (_) => throw Exception("Invalid Sync Left result"),
      (r) => r,
    );
  }
}
