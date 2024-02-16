part of 'effect.dart';

final class SyncEither<L, R> extends Effect<void, L, R> {
  const SyncEither._(UnsafeRun<void, L, R> run) : super._(run);

  factory SyncEither._fromEffect(Effect<void, L, R> effect) =>
      SyncEither._(effect._runEffect);

  factory SyncEither.trySync(
    R Function() execute,
    L Function(Object error, StackTrace stackTrace) onError,
  ) =>
      SyncEither._fromEffect(
        Effect<void, L, R>.tryFuture(execute, onError),
      );

  @override
  SyncEither<L, C> flatMap<C>(SyncEither<L, C> Function(R r) f) {
    return SyncEither._fromEffect(super.flatMap(f));
  }
}
