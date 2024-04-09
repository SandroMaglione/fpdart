part of "effect.dart";

class AsyncContext<L, R> {
  final _deferred = Deferred<L, R>.unsafeMake();

  void succeed(R value) => _deferred.unsafeCompleteExit(Right(value));
  void fail(L error) => _deferred.unsafeCompleteExit(Left(Failure(error)));
  void failCause(Cause<L> cause) => _deferred.unsafeCompleteExit(Left(cause));
  void die(dynamic defect) => _deferred.unsafeCompleteExit(Left(
        Die(defect, StackTrace.current),
      ));
}
