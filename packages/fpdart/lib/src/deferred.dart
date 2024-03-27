part of 'effect.dart';

final class Deferred<L, R> extends IEffect<Null, L, R> {
  Option<Exit<L, R>> _value = None();

  Completer<Exit<L, R>>? __completer;

  Deferred();

  Deferred.completed(R value) : _value = Some(Right(value));
  Deferred.failedCause(Cause<L> cause) : _value = Some(Left(cause));
  Deferred.failed(L error) : _value = Some(Left(Failure(error)));

  Completer<Exit<L, R>> get _completer =>
      __completer ??= Completer<Exit<L, R>>.sync();

  bool get unsafeCompleted => _value is Some<Exit<L, R>>;

  @override
  Effect<Null, L, R> get asEffect => Effect.from(
        (_) => await<Null>()._unsafeRun(Context.env(null)),
      );

  Effect<E, L, R> await<E>() => Effect.from(
        (ctx) async => switch (_value) {
          None() => await _completer.future,
          Some(value: final value) => value,
        },
      );

  void unsafeCompleteExit(Exit<L, R> exit) {
    if (_value is Some<Exit<L, R>>) return;

    _value = Some(exit);
    __completer?.complete(exit);
  }

  Effect<E, C, Unit> completeExit<E, C>(Exit<L, R> exit) =>
      Effect.functionSucceed(() {
        switch (_value) {
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
