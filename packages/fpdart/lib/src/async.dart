part of "effect.dart";

final class Async<R> extends IEffect<void, Never, R> {
  const Async._(UnsafeRun<void, Never, R> run) : super._(run);

  factory Async._fromEffect(IEffect<void, Never, R> effect) =>
      Async._(effect._runEffect);

  factory Async.make(
    R Function() execute,
  ) =>
      Async._fromEffect(
        Effect<void, Never, R>.tryFuture(
          execute,
          (_, __) => throw Exception(
            "Error when building Async.make",
          ),
        ),
      );

  factory Async.value(R value) => Async._(
        (_) => Exit.success(value),
      );

  @override
  Async<C> flatMap<C>(covariant Async<C> Function(R r) f) {
    return Async._fromEffect(super.flatMap(f));
  }

  Future<R> call() async {
    final run = _unsafeRun(null);
    if (run is! Future) {
      throw Exception("Error running a sync Async");
    }

    return switch (await run) {
      Failure() => throw Exception("Invalid Async Left result"),
      Success(value: final value) => value,
    };
  }
}
