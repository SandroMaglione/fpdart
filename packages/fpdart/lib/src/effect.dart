import 'dart:async';

import 'package:fpdart/fpdart.dart';

import './extension/future_or_extension.dart';
import './extension/iterable_extension.dart';
import 'unit.dart' as fpdart_unit;

part 'context.dart';
part 'deferred.dart';
part 'either.dart';
part 'option.dart';

typedef EffectGen<E, L> = ({
  FutureOr<A> Function<A>(IEffect<E, L, A>) async,
  A Function<A>(IEffect<E, L, A>) sync,
});

final class _EffectThrow<L> implements Exception {
  final Cause<L> cause;
  const _EffectThrow(this.cause);

  @override
  String toString() {
    return "Effect.gen error: $cause";
  }
}

EffectGen<E, L> _effectGen<E, L>(Context<E> context) => (
      async: <A>(effect) => Future.sync(
            () => effect.asEffect._unsafeRun(context).then(
                  (exit) => switch (exit) {
                    Left(value: final cause) => throw _EffectThrow<L>(cause),
                    Right(value: final value) => value,
                  },
                ),
          ),
      sync: <A>(effect) {
        final run = effect.asEffect._unsafeRun(context);
        if (run is Future) {
          throw _EffectThrow<L>(
            Die.current(
              Exception("gen.sync cannot execute async Effect"),
            ),
          );
        }

        return switch (run) {
          Left(value: final cause) => throw _EffectThrow<L>(cause),
          Right(value: final value) => value,
        };
      },
    );

typedef DoFunctionEffect<E, L, A> = FutureOr<A> Function(
  EffectGen<E, L> $,
);

abstract class IEffect<E, L, R> {
  const IEffect();
  Effect<E, L, R> get asEffect;
}

final class Effect<E, L, R> extends IEffect<E, L, R> {
  final FutureOr<Exit<L, R>> Function(Context<E> context) _unsafeRun;
  const Effect._(this._unsafeRun);

  @override
  Effect<E, L, R> get asEffect => this;

  @override
  String toString() {
    return "Effect(${_unsafeRun.runtimeType})";
  }

  FutureOr<Exit<L, R>> __unsafeRun(Context<E> context) {
    if (context.signal.unsafeCompleted) {
      return const Left(Interrupted());
    }

    try {
      return _unsafeRun(context).then((exit) {
        if (context.signal.unsafeCompleted) {
          return const Left(Interrupted());
        }

        return exit;
      });
    } catch (err, stackTrace) {
      return Left(Die(err, stackTrace));
    }
  }

  /// {@category constructors}
  factory Effect.from(FutureOr<Exit<L, R>> Function(Context<E> context) run) =>
      Effect._((context) {
        try {
          return run(context);
        } on Cause<L> catch (cause) {
          return Left(cause);
        } catch (error, stackTrace) {
          return Left(Die(error, stackTrace));
        }
      });

  /// {@category constructors}
  factory Effect.gen(DoFunctionEffect<E, L, R> f) => Effect<E, L, R>._(
        (env) {
          try {
            return f(_effectGen<E, L>(env)).then(
              Right.new,
              onError: (error, stackTrace) {
                if (error is _EffectThrow<L>) {
                  return Left<Cause<L>, R>(error.cause);
                }

                return Left<Cause<L>, R>(Die(error, stackTrace));
              },
            );
          } on _EffectThrow<L> catch (genError) {
            return Left(genError.cause);
          }
        },
      );

  /// {@category constructors}
  factory Effect.tryCatch({
    required FutureOr<R> Function() execute,
    required L Function(Object error, StackTrace stackTrace) onError,
    FutureOr<dynamic> Function()? onCancel,
  }) =>
      Effect.from(
        (env) {
          try {
            return execute().then(
              Right.new,
              onError: (error, stackTrace) => Left(
                Failure(onError(error, stackTrace), stackTrace),
              ),
            );
          } catch (err, stack) {
            return Left(Failure(onError(err, stack), stack));
          }
        },
      );

  /// {@category constructors}
  factory Effect.fromNullable(R? value, {required L Function() onNull}) =>
      Effect.from(
        (_) => value == null ? Left(Failure(onNull())) : Right(value),
      );

  /// {@category constructors}
  factory Effect.functionFail(FutureOr<Cause<L>> Function() f) => Effect.from(
        (_) => f().then(Left.new),
      );

  /// {@category constructors}
  factory Effect.functionSucceed(FutureOr<R> Function() f) => Effect.from(
        (_) => f().then(Right.new),
      );

  /// {@category constructors}
  factory Effect.fail(L value) => Effect.from((_) => Left(Failure(value)));

  /// {@category constructors}
  factory Effect.failCause(Cause<L> cause) => Effect.from((_) => Left(cause));

  /// {@category constructors}
  factory Effect.succeed(R value) => Effect.from((_) => Right(value));

  /// {@category constructors}
  factory Effect.raceAll(Iterable<Effect<E, L, R>> iterable) =>
      Effect.from((context) {
        final signal = Deferred<Never, Never>();
        final deferred = Deferred<L, R>();

        for (final effect in iterable) {
          effect
              .__unsafeRun(context.withSignal(signal))
              .then(deferred.unsafeCompleteExit);

          if (deferred.unsafeCompleted) {
            break;
          }
        }

        return deferred.await<E>().__unsafeRun(context).then(
              (exit) => signal
                  .failCause<E, L>(const Interrupted())
                  .__unsafeRun(context.withoutSignal)
                  .then((_) => exit),
            );
      });

  /// {@category constructors}
  static Effect<E, L, void> sleep<E, L>(Duration duration) => Effect.from(
        (_) => Future.delayed(
          duration,
          () => const Right(null),
        ),
      );

  /// {@category constructors}
  static Effect<E, Never, Never> die<E>(dynamic defect) => Effect.from(
        (_) => Left(Die.current(defect)),
      );

  /// {@category constructors}
  static Effect<E, Never, Never> functionDie<E>(dynamic Function() run) =>
      Effect.from(
        (_) => Left(Die.current(run())),
      );

  /// {@category constructors}
  static Effect<E, L, fpdart_unit.Unit> unit<E, L>() => Effect.from(
        (_) => const Right(fpdart_unit.unit),
      );

  /// {@category collecting}
  static Effect<E, L, Iterable<R>> forEach<E, L, R, A>(
    Iterable<A> iterable,
    Effect<E, L, R> Function(A a, int index) f,
  ) =>
      Effect.from(
        (context) {
          if (iterable.isEmpty) {
            return const Right([]);
          }

          return iterable
              .mapWithIndex(f)
              .fold<Effect<E, L, Iterable<R>>>(
                Effect.succeed(const Iterable.empty()),
                (acc, effect) => acc.zipWith(
                  effect,
                  (list, r) => list.append(r),
                ),
              )
              ._unsafeRun(context);
        },
      );

  /// {@category collecting}
  static Effect<E, L, Iterable<R>> all<E, L, R>(
    Iterable<Effect<E, L, R>> iterable,
  ) =>
      Effect.forEach(iterable, (a, _) => a);

  /// {@category zipping}
  Effect<E, L, C> zipWith<B, C>(
    Effect<E, L, B> effect,
    C Function(R r, B b) f,
  ) =>
      flatMap(
        (r) => effect.map(
          (b) => f(r, b),
        ),
      );

  /// {@category zipping}
  Effect<E, L, R> zipLeft<C>(
    Effect<E, L, C> effect,
  ) =>
      flatMap(
        (r) => effect.map(
          (_) => r,
        ),
      );

  /// {@category zipping}
  Effect<E, L, C> zipRight<C>(
    Effect<E, L, C> effect,
  ) =>
      flatMap((_) => effect);

  /// {@category do_notation}
  Effect<V, L, R> mapEnv<V>(Context<E> Function(Context<V> context) f) =>
      Effect.from(
        (context) => _unsafeRun(f(context)),
      );

  /// {@category do_notation}
  Effect<Null, L, R> provide(E env) =>
      Effect.from((_) => _unsafeRun(Context.env(env)));

  /// {@category do_notation}
  Effect<V, L, R> provideEffect<V>(Effect<V, L, E> effect) => Effect.from(
        (context) => effect._unsafeRun(context).then(
              (exit) => switch (exit) {
                Left(value: final cause) => Left(cause),
                Right(value: final value) => _unsafeRun(context.withEnv(value)),
              },
            ),
      );

  /// {@category do_notation}
  static Effect<E, L, E> env<E, L>() => Effect.from(
        (context) => Right(context.env),
      );

  /// {@category combining}
  Effect<E, L, V> ap<V>(
    Effect<E, L, V Function(R r)> f,
  ) =>
      f.flatMap(
        (f) => flatMap(
          (v) => Effect.succeed(f(v)),
        ),
      );

  /// {@category conversions}
  Effect<E, Never, Either<L, R>> either() => Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => Right(Left(error)),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) => Right(Right(value)),
          },
        ),
      );

  /// {@category conversions}
  Effect<E, Never, Option<R>> option() => Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>() => Right(None()),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) => Right(Some(value)),
          },
        ),
      );

  /// {@category conversions}
  Effect<E, Never, Exit<L, R>> exit() => Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => Right(exit),
        ),
      );

  /// {@category folding}
  Effect<E, Never, C> match<C>({
    required C Function(L l) onFailure,
    required C Function(R r) onSuccess,
  }) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => Right(onFailure(error)),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) => Right(onSuccess(value)),
          },
        ),
      );

  /// {@category folding}
  Effect<E, Never, C> matchCause<C>({
    required C Function(Cause<L> l) onFailure,
    required C Function(R r) onSuccess,
  }) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => Right(onFailure(cause)),
            Right(value: final value) => Right(onSuccess(value)),
          },
        ),
      );

  /// {@category folding}
  Effect<E, C, D> matchEffect<C, D>({
    required Effect<E, C, D> Function(L l) onFailure,
    required Effect<E, C, D> Function(R r) onSuccess,
  }) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) =>
                  onFailure(error)._unsafeRun(context),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) => onSuccess(value)._unsafeRun(context),
          },
        ),
      );

  /// {@category folding}
  Effect<E, C, D> matchCauseEffect<C, D>({
    required Effect<E, C, D> Function(Cause<L> l) onFailure,
    required Effect<E, C, D> Function(R r) onSuccess,
  }) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => onFailure(cause)._unsafeRun(context),
            Right(value: final value) => onSuccess(value)._unsafeRun(context),
          },
        ),
      );

  /// {@category mapping}
  Effect<E, R, L> flip() => Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => Right(error),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) => Left(Failure(value)),
          },
        ),
      );

  /// {@category mapping}
  Effect<E, L, V> map<V>(V Function(R r) f) => ap(Effect.succeed(f));

  /// {@category mapping}
  Effect<E, C, R> mapError<C>(C Function(L l) f) => Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => Left(Failure(f(error))),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) => Right(value),
          },
        ),
      );

  /// {@category mapping}
  Effect<E, C, R> mapErrorCause<C>(C Function(Cause<L> l) f) => Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => Left(Failure(f(cause))),
            Right(value: final value) => Right(value),
          },
        ),
      );

  /// {@category mapping}
  Effect<E, C, D> mapBoth<C, D>(C Function(L l) fl, D Function(R r) fr) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => Left(Failure(fl(error))),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) => Right(fr(value)),
          },
        ),
      );

  /// {@category sequencing}
  Effect<E, L, R> race(Effect<E, L, R> effect) =>
      Effect.raceAll([this, effect]);

  /// {@category sequencing}
  Effect<E, L, C> flatMap<C>(Effect<E, L, C> Function(R r) f) => Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => Left(cause),
            Right(value: final value) => f(value)._unsafeRun(context),
          },
        ),
      );

  /// {@category sequencing}
  Effect<E, L, R> tap<C>(Effect<E, L, C> Function(R r) f) =>
      flatMap((r) => f(r).map((_) => r));

  /// {@category sequencing}
  Effect<E, L, R> tapError<C>(Effect<E, C, R> Function(L l) f) => Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) =>
                  f(error)._unsafeRun(context).then(
                        (_) => Left(Failure(error)),
                      ),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) => Right(value),
          },
        ),
      );

  /// {@category alternatives}
  Effect<E, C, R> orElse<C>(
    Effect<E, C, R> Function(L l) orElse,
  ) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) =>
                  orElse(error)._unsafeRun(context),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) =>
              Effect<E, C, R>.succeed(value)._unsafeRun(context),
          },
        ),
      );

  /// {@category alternatives}
  Effect<E, Never, R> get orDie => Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => Left(Die.current(cause)),
            Right(value: final value) =>
              Effect<E, Never, R>.succeed(value)._unsafeRun(context),
          },
        ),
      );

  /// {@category alternatives}
  Effect<E, Never, R> orDieWith<T extends Object>(T Function(L l) onError) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) =>
                  Left(Die.current(onError(error))),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) =>
              Effect<E, Never, R>.succeed(value)._unsafeRun(context),
          },
        ),
      );

  /// {@category error_handling}
  Effect<E, C, R> catchError<C>(
    Effect<E, C, R> Function(L error) f,
  ) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => f(error)._unsafeRun(context),
                Die() => Left(cause),
                Interrupted() => Left(cause),
              },
            Right(value: final value) =>
              Effect<E, Never, R>.succeed(value)._unsafeRun(context),
          },
        ),
      );

  /// {@category error_handling}
  Effect<E, C, R> catchCause<C>(
    Effect<E, C, R> Function(Cause<L> cause) f,
  ) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => f(cause),
            Right(value: final value) => Effect<E, C, R>.succeed(value),
          }
              ._unsafeRun(context),
        ),
      );

  /// {@category filtering}
  Effect<E, L, R> filterOrDie<C>({
    required bool Function(R r) predicate,
    required C Function(R r) orDieWith,
  }) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => Left(cause),
            Right(value: final value) => predicate(value)
                ? Right(value)
                : Left(Die.current(orDieWith(value))),
          },
        ),
      );

  /// {@category filtering}
  Effect<E, L, R> filterOrElse({
    required bool Function(R r) predicate,
    required Effect<E, L, R> Function(R r) orElse,
  }) =>
      Effect.from(
        (context) => _unsafeRun(context).then(
          (exit) => switch (exit) {
            Left(value: final cause) => Left(cause),
            Right(value: final value) => predicate(value)
                ? Right(value)
                : orElse(value)._unsafeRun(context),
          },
        ),
      );

  /// {@category delay}
  Effect<E, L, R> delay(Duration duration) =>
      Effect.sleep<E, L>(duration).zipRight(this);

  /// {@category delay}
  Effect<E, L, R> timeout(Duration duration) =>
      race(Effect<E, L, R>.failCause(const Interrupted()).delay(duration));

  /// {@category interruption}
  Effect<E, Never, R> interrupt() => Effect.failCause(const Interrupted());
}

extension ProvideNull<L, R> on Effect<Null, L, R> {
  /// {@category do_notation}
  Effect<V, L, R> withEnv<V>() => Effect.from(
        (context) => _unsafeRun(Context.env(null)),
      );

  /// {@category execution}
  R runSync() {
    try {
      final result = _unsafeRun(Context.env(null));
      if (result is Future) {
        throw Die.current(
          Exception("runSync cannot execute async Effect"),
        );
      }

      return switch (result) {
        Left(value: final cause) => throw cause,
        Right(value: final value) => value,
      };
    } on Cause<L> {
      rethrow;
    } catch (error, stackTrace) {
      throw Die(error, stackTrace);
    }
  }

  /// {@category execution}
  Exit<L, R> runSyncExit() {
    try {
      final result = _unsafeRun(Context.env(null));
      if (result is Future) {
        return Left(Die.current(
          Exception("runSyncExit cannot execute async Effect"),
        ));
      }
      return result;
    } on Cause<L> catch (cause) {
      return Left(cause);
    } catch (error, stackTrace) {
      return Left(Die(error, stackTrace));
    }
  }

  /// {@category execution}
  Future<R> runFuture() async {
    try {
      final result = _unsafeRun(Context.env(null));
      if (result is! Future) {
        return switch (result) {
          Left(value: final cause) => throw cause,
          Right(value: final value) => value,
        };
      }

      return switch (await result) {
        Left(value: final cause) => throw cause,
        Right(value: final value) => value,
      };
    } on Cause<L> {
      rethrow;
    } catch (error, stackTrace) {
      throw Die(error, stackTrace);
    }
  }

  /// {@category execution}
  Future<Exit<L, R>> runFutureExit() async {
    try {
      return _unsafeRun(Context.env(null));
    } on Cause<L> catch (cause) {
      return Left(cause);
    } catch (error, stackTrace) {
      return Left(Die(error, stackTrace));
    }
  }
}
