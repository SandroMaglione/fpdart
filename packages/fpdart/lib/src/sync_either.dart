part of 'effect.dart';

final class SyncEither<L, R> extends IEffect<void, L, R> {
  const SyncEither._(UnsafeRun<void, L, R> run) : super._(run);

  factory SyncEither._fromEffect(IEffect<void, L, R> effect) =>
      SyncEither._(effect._runEffect);

  factory SyncEither.trySync(
    R Function() execute,
    L Function(Object error, StackTrace stackTrace) onError,
  ) =>
      SyncEither._fromEffect(
        Effect<void, L, R>.tryFuture(execute, onError),
      );

  @override
  SyncEither<L, C> flatMap<C>(covariant SyncEither<L, C> Function(R r) f) {
    return SyncEither._fromEffect(super.flatMap(f));
  }

  Exit<L, R> call() {
    final run = _unsafeRun(null);
    if (run is Future) {
      throw Exception("Error running an async Sync");
    }

    return run;
  }
}
