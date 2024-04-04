part of 'effect.dart';

final class Deferred<L, R> {
  Option<Exit<L, R>> _state = const None();
  Completer<Exit<L, R>>? __completer;

  Deferred._();
  Deferred.unsafeMake();

  static Effect<Null, Never, Deferred<L, R>> make<L, R>() =>
      Effect.succeed(Deferred._());

  Deferred.completed(R value) : _state = Some(Right(value));
  Deferred.failedCause(Cause<L> cause) : _state = Some(Left(cause));
  Deferred.failed(L error) : _state = Some(Left(Failure(error)));

  Completer<Exit<L, R>> get _completer =>
      __completer ??= Completer<Exit<L, R>>.sync();

  bool get unsafeCompleted => _state is Some<Exit<L, R>>;

  Effect<E, L, R> wait<E>() => Effect.from(
        (ctx) async => switch (_state) {
          None() => await _completer.future,
          Some(value: final value) => value,
        },
      );

  void unsafeCompleteExit(Exit<L, R> exit) {
    if (_state is Some<Exit<L, R>>) return;

    _state = Some(exit);
    __completer?.complete(exit);
  }

  Effect<E, C, Unit> completeExit<E, C>(Exit<L, R> exit) =>
      Effect.succeedLazy(() {
        switch (_state) {
          case None():
            unsafeCompleteExit(exit);
            return unit;
          case Some():
            return unit;
        }
      });

  Effect<E, C, Unit> failCause<E, C>(Cause<L> cause) =>
      completeExit(Left(cause));
}
