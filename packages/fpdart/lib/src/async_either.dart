part of 'effect.dart';

final class AsyncEither<L, R> extends IEffect<void, L, R> {
  const AsyncEither._(UnsafeRun<void, L, R> run) : super._(run);

  factory AsyncEither._fromEffect(IEffect<void, L, R> effect) =>
      AsyncEither._(effect._runEffect);

  factory AsyncEither.tryFuture(
    FutureOr<R> Function() execute,
    L Function(Object error, StackTrace stackTrace) onError,
  ) =>
      AsyncEither._fromEffect(
        Effect<void, L, R>.tryFuture(execute, onError),
      );

  @override
  AsyncEither<L, C> flatMap<C>(covariant AsyncEither<L, C> Function(R r) f) {
    return AsyncEither._fromEffect(super.flatMap(f));
  }

  Future<Exit<L, R>> call() async => _unsafeRun(null);
}
