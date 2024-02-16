part of 'effect.dart';

final class AsyncEither<L, R> extends Effect<void, L, R> {
  const AsyncEither._(UnsafeRun<void, L, R> run) : super._(run);

  factory AsyncEither._fromEffect(Effect<void, L, R> effect) =>
      AsyncEither._(effect._runEffect);

  factory AsyncEither.tryFuture(
    FutureOr<R> Function() execute,
    L Function(Object error, StackTrace stackTrace) onError,
  ) =>
      AsyncEither._fromEffect(
        Effect<void, L, R>.tryFuture(execute, onError),
      );

  @override
  AsyncEither<L, C> flatMap<C>(AsyncEither<L, C> Function(R r) f) {
    return AsyncEither._fromEffect(super.flatMap(f));
  }
}
