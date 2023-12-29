import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:fpdart_effect/src/cause.dart' as cause;

part 'do.dart';

final class Effect<R, E, A> {
  final FutureOr<cause.Exit<E, A>> Function(R env) _unsafeRun;
  const Effect._(this._unsafeRun);

  /** Create */
  factory Effect.succeed(A value) => Effect._((_) => Either.right(value));
  factory Effect.fail(E value) =>
      Effect._((_) => Either.left(cause.Failure(value)));

  factory Effect.sync(A Function() run) => Effect._((_) => Either.right(run()));
  factory Effect.future(Future<A> Function() run) => Effect._(
        (_) async => Either.right(await run()),
      );

  static Effect<R, E, A> trySync<R, E, A>({
    required A Function() onTry,
    required E Function(Object e, StackTrace s) onCatch,
  }) =>
      Effect._(
        (_) {
          try {
            return Either.right(onTry());
          } catch (e, s) {
            return Either.left(
              cause.Failure(onCatch(e, s)),
            );
          }
        },
      );

  static Effect<R, E, A> tryFuture<R, E, A>({
    required Future<A> Function() onTry,
    required E Function(Object e, StackTrace s) onCatch,
  }) =>
      Effect._(
        (_) async {
          try {
            return Either.right(await onTry());
          } catch (e, s) {
            return Either.left(
              cause.Failure(onCatch(e, s)),
            );
          }
        },
      );

  /** Do notation */
  factory Effect.Do(DoFunction<R, E, A> run) => Effect._(
        (env) async {
          try {
            return Either.of(await run(_doAdapter<R, E>(env)));
          } on _DoThrow<E> catch (e) {
            return Either.left(cause.Failure(e.value));
          }
        },
      );

  /** Execute (Run) */
  A runSync(R env) {
    final run = _unsafeRun(env);
    if (run is Future) {
      throw Exception(
        "Cannot use runSync in an Effect returning a Future, use runFuture instead",
      );
    }

    final result = run;
    return switch (result) {
      Left(value: final value) =>
        throw Exception("runSync returns an error: $value"),
      Right(value: final value) => value,
    };
  }

  cause.Exit<E, A> runSyncExit(R env) {
    final run = _unsafeRun(env);
    if (run is Future) {
      throw Exception(
        "Cannot use runSyncExit in an Effect returning a Future, use runFutureExit instead",
      );
    }

    return run;
  }

  Future<A> runFuture(R env) async => switch (await _unsafeRun(env)) {
        Left(value: final value) =>
          throw Exception("runFuture returns an error: $value"),
        Right(value: final value) => value,
      };

  Future<cause.Exit<E, A>> runFutureExit(R env) async => _unsafeRun(env);
}
