import 'dart:async';

import 'package:fpdart/fpdart.dart';

import './extension/future_or_extension.dart';
import './extension/iterable_extension.dart';
import 'unit.dart' as fpdart_unit;

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

EffectGen<E, L> _effectGen<E, L>(E env) => (
      async: <A>(effect) => Future.sync(
            () => effect.asEffect._unsafeRun(env).then(
                  (exit) => switch (exit) {
                    Left(value: final cause) => throw _EffectThrow<L>(cause),
                    Right(value: final value) => value,
                  },
                ),
          ),
      sync: <A>(effect) {
        final run = effect.asEffect._unsafeRun(env);
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

abstract interface class IEffect<E, L, R> {
  const IEffect();
  Effect<E, L, R> get asEffect;
}

final class Effect<E, L, R> extends IEffect<E, L, R> {
  final FutureOr<Exit<L, R>> Function(E env) _unsafeRun;
  const Effect._(this._unsafeRun);

  @override
  Effect<E, L, R> get asEffect => this;

  @override
  String toString() {
    return "Effect(${_unsafeRun.runtimeType})";
  }

  /// {@category execution}
  R runSync(E env) {
    try {
      final result = _unsafeRun(env);
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
  Exit<L, R> runSyncExit(E env) {
    try {
      final result = _unsafeRun(env);
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
  Future<R> runFuture(E env) async {
    try {
      final result = _unsafeRun(env);
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
  Future<Exit<L, R>> runFutureExit(E env) async {
    try {
      final result = _unsafeRun(env);
      if (result is! Future) {
        return result;
      }
      return result;
    } on Cause<L> catch (cause) {
      return Left(cause);
    } catch (error, stackTrace) {
      return Left(Die(error, stackTrace));
    }
  }

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
      Effect._(
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
      Effect._(
        (_) => value == null ? Left(Failure(onNull())) : Right(value),
      );

  /// {@category constructors}
  factory Effect.functionFail(FutureOr<Cause<L>> Function() f) => Effect._(
        (_) => f().then(Left.new),
      );

  /// {@category constructors}
  factory Effect.functionSucceed(FutureOr<R> Function() f) => Effect._(
        (_) => f().then(Right.new),
      );

  /// {@category constructors}
  factory Effect.fail(L value) => Effect._((_) => Left(Failure(value)));

  /// {@category constructors}
  factory Effect.succeed(R value) => Effect._((_) => Right(value));

  /// {@category constructors}
  static Effect<E, Never, Never> die<E>(dynamic defect) => Effect._(
        (_) => Left(Die.current(defect)),
      );

  /// {@category constructors}
  static Effect<E, Never, Never> functionDie<E>(dynamic Function() run) =>
      Effect._(
        (_) => Left(Die.current(run())),
      );

  /// {@category constructors}
  static Effect<E, L, fpdart_unit.Unit> unit<E, L>() => Effect._(
        (_) => const Right(fpdart_unit.unit),
      );

  /// {@category collecting}
  static Effect<E, L, Iterable<R>> forEach<E, L, R, A>(
    Iterable<A> iterable,
    Effect<E, L, R> Function(A a, int index) f,
  ) =>
      Effect._(
        (env) {
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
              ._unsafeRun(env);
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

  /// Extract the required dependency from the complete environment.
  ///
  /// {@category do_notation}
  Effect<V, L, R> provide<V>(E Function(V env) f) => Effect._(
        (env) => _unsafeRun(f(env)),
      );

  /// {@category do_notation}
  static Effect<E, L, E> env<E, L>() => Effect._(
        (env) => Right(env),
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
  Effect<E, Never, Either<L, R>> either() => Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => Right(Left(error)),
                Die() => Left(cause),
              },
            Right(value: final value) => Right(Right(value)),
          },
        ),
      );

  /// {@category conversions}
  Effect<E, Never, Option<R>> option() => Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>() => Right(None()),
                Die() => Left(cause),
              },
            Right(value: final value) => Right(Some(value)),
          },
        ),
      );

  /// {@category conversions}
  Effect<E, Never, Exit<L, R>> exit() => Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => Right(exit),
        ),
      );

  /// {@category folding}
  Effect<E, Never, C> match<C>({
    required C Function(L l) onFailure,
    required C Function(R r) onSuccess,
  }) =>
      Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => Right(onFailure(error)),
                Die() => Left(cause),
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
      Effect._(
        (env) => _unsafeRun(env).then(
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
      Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) =>
                  onFailure(error)._unsafeRun(env),
                Die() => Left(cause),
              },
            Right(value: final value) => onSuccess(value)._unsafeRun(env),
          },
        ),
      );

  /// {@category folding}
  Effect<E, C, D> matchCauseEffect<C, D>({
    required Effect<E, C, D> Function(Cause<L> l) onFailure,
    required Effect<E, C, D> Function(R r) onSuccess,
  }) =>
      Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => onFailure(cause)._unsafeRun(env),
            Right(value: final value) => onSuccess(value)._unsafeRun(env),
          },
        ),
      );

  /// {@category mapping}
  Effect<E, R, L> flip() => Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => Right(error),
                Die() => Left(cause),
              },
            Right(value: final value) => Left(Failure(value)),
          },
        ),
      );

  /// {@category mapping}
  Effect<E, L, V> map<V>(V Function(R r) f) => ap(Effect.succeed(f));

  /// {@category mapping}
  Effect<E, C, R> mapError<C>(C Function(L l) f) => Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => Left(Failure(f(error))),
                Die() => Left(cause),
              },
            Right(value: final value) => Right(value),
          },
        ),
      );

  /// {@category mapping}
  Effect<E, C, R> mapErrorCause<C>(C Function(Cause<L> l) f) => Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => Left(Failure(f(cause))),
            Right(value: final value) => Right(value),
          },
        ),
      );

  /// {@category mapping}
  Effect<E, C, D> mapBoth<C, D>(C Function(L l) fl, D Function(R r) fr) =>
      Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => Left(Failure(fl(error))),
                Die() => Left(cause),
              },
            Right(value: final value) => Right(fr(value)),
          },
        ),
      );

  /// {@category sequencing}
  Effect<E, L, C> flatMap<C>(Effect<E, L, C> Function(R r) f) => Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => Left(cause),
            Right(value: final value) => f(value)._unsafeRun(env),
          },
        ),
      );

  /// {@category sequencing}
  Effect<E, L, R> tap<C>(Effect<E, L, C> Function(R r) f) =>
      flatMap((r) => f(r).map((_) => r));

  /// {@category sequencing}
  Effect<E, L, R> tapError<C>(Effect<E, C, R> Function(L l) f) => Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => f(error)._unsafeRun(env).then(
                      (_) => Left(Failure(error)),
                    ),
                Die() => Left(cause),
              },
            Right(value: final value) => Right(value),
          },
        ),
      );

  /// {@category alternatives}
  Effect<E, C, R> orElse<C>(
    Effect<E, C, R> Function(L l) orElse,
  ) =>
      Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => orElse(error)._unsafeRun(env),
                Die() => Left(cause),
              },
            Right(value: final value) =>
              Effect<E, C, R>.succeed(value)._unsafeRun(env),
          },
        ),
      );

  /// {@category alternatives}
  Effect<E, Never, R> get orDie => Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => Left(Die.current(cause)),
            Right(value: final value) =>
              Effect<E, Never, R>.succeed(value)._unsafeRun(env),
          },
        ),
      );

  /// {@category alternatives}
  Effect<E, Never, R> orDieWith<T extends Object>(T Function(L l) onError) =>
      Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) =>
                  Left(Die.current(onError(error))),
                Die() => Left(cause),
              },
            Right(value: final value) =>
              Effect<E, Never, R>.succeed(value)._unsafeRun(env),
          },
        ),
      );

  /// {@category error_handling}
  Effect<E, C, R> catchError<C>(
    Effect<E, C, R> Function(L error) f,
  ) =>
      Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Failure<L>(error: final error) => f(error)._unsafeRun(env),
                Die() => Left(cause),
              },
            Right(value: final value) =>
              Effect<E, Never, R>.succeed(value)._unsafeRun(env),
          },
        ),
      );

  /// {@category error_handling}
  Effect<E, C, R> catchCause<C>(
    Effect<E, C, R> Function(Cause<L> cause) f,
  ) =>
      Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => f(cause),
            Right(value: final value) => Effect<E, C, R>.succeed(value),
          }
              ._unsafeRun(env),
        ),
      );

  /// {@category filtering}
  Effect<E, L, R> filterOrDie<C>({
    required bool Function(R r) predicate,
    required C Function(R r) orDieWith,
  }) =>
      Effect._(
        (env) => _unsafeRun(env).then(
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
      Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => Left(cause),
            Right(value: final value) =>
              predicate(value) ? Right(value) : orElse(value)._unsafeRun(env),
          },
        ),
      );
}

extension ProvideVoid<L, R> on Effect<void, L, R> {
  /// Add a required dependency instead of [void].
  ///
  /// {@category do_notation}
  Effect<V, L, R> withEnv<V>() => Effect._(
        (env) => _unsafeRun(null),
      );
}
