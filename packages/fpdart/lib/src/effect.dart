import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/extension/future_or_extension.dart';
import 'package:fpdart/src/extension/iterable_extension.dart';
import 'package:meta/meta.dart';

import 'unit.dart' as fpdart_unit;

part 'either.dart';
part 'option.dart';

typedef EffectGen<E, L> = ({
  FutureOr<A> Function<A>(IEffect<E, L, A>) async,
  A Function<A>(IEffect<E, L, A>) sync,
});

final class _EffectThrow<L> {
  final Cause<L> cause;
  const _EffectThrow(this.cause);

  @override
  String toString() {
    return "Effect.gen error: $cause";
  }
}

EffectGen<E, L> _effectGen<E, L>(E? env) => (
      async: <A>(effect) => Future.sync(
            () => effect.asEffect._unsafeRun(env).then(
                  (exit) => switch (exit) {
                    Left(value: final cause) => throw _EffectThrow(cause),
                    Right(value: final value) => value,
                  },
                ),
          ),
      sync: <A>(effect) {
        final run = effect.asEffect._unsafeRun(env);
        if (run is Future) {
          throw _EffectThrow<L>(
            Die.current("Cannot execute a Future using sync"),
          );
        }

        return switch (run) {
          Left(value: final cause) => throw _EffectThrow(cause),
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
  /// `E?` is optional to allow [Never] to work (`provideNever`).
  ///
  /// In practice a user of the library should never be allowed to pass `null` as [E].
  final FutureOr<Exit<L, R>> Function(E? env) _unsafeRun;
  final StackTrace? stackTrace;

  static bool debugTracing = false;

  const Effect._(
    this._unsafeRun, {
    this.stackTrace,
  });

  @override
  Effect<E, L, R> get asEffect => this;

  @override
  String toString() {
    return "Effect(${_unsafeRun.runtimeType})";
  }

  /// {@category execution}
  R runSync(E env) {
    final result = _unsafeRun(env);
    if (result is Future) {
      throw Die.current(result, stackTrace);
    }

    return switch (result) {
      Left(value: final cause) => throw cause,
      Right(value: final value) => value,
    };
  }

  /// {@category execution}
  Exit<L, R> runSyncExit(E env) {
    final result = _unsafeRun(env);
    if (result is Future) {
      return Left(Die.current(""));
    }
    return result;
  }

  /// {@category execution}
  Future<R> runFuture(E env) async {
    final result = await _unsafeRun(env);
    return switch (result) {
      Left(value: final cause) => throw cause,
      Right(value: final value) => value,
    };
  }

  /// {@category execution}
  Future<Exit<L, R>> runFutureExit(E env) async => _unsafeRun(env);

  /// {@category constructors}
  // ignore: non_constant_identifier_names
  factory Effect.gen(DoFunctionEffect<E, L, R> f) => Effect<E, L, R>._(
        (env) {
          try {
            return f(_effectGen<E, L>(env)).then(Right.new);
          } on _EffectThrow<L> catch (err) {
            return Left(err.cause);
          }
        },
      );

  /// {@category constructors}
  static Effect<void, L, R> tryCatch<L, R>({
    required FutureOr<R> Function() execute,
    required L Function(Object error, StackTrace stackTrace) onError,
    FutureOr<dynamic> Function()? onCancel,
  }) =>
      Effect._(
        (env) {
          try {
            return execute().then(Right.new);
          } catch (err, stack) {
            return Left(Fail(onError(err, stack), stack));
          }
        },
      );

  /// {@category constructors}
  static Effect<void, L, R> fromNullable<L, R>(R? value, L Function() onNull) =>
      Effect._(
        (_) => value == null ? Left(Fail(onNull())) : Right(value),
      );

  /// {@category constructors}
  static Effect<void, void, R> function<R>(FutureOr<R> Function() f) =>
      Effect._(
        (_) => f().then(Right.new),
      );

  /// {@category constructors}
  static Effect<void, L, Never> fail<L>(L value) =>
      Effect._((_) => Left(Fail(value)));

  /// {@category constructors}
  static Effect<void, void, R> succeed<R>(R value) =>
      Effect._((_) => Right(value));

  /// {@category constructors}
  static Effect<Never, Never, fpdart_unit.Unit> unit() => Effect._(
        (_) => Right(fpdart_unit.unit),
      );

  /// {@category collecting}
  static Effect<E, L, Iterable<R>> forEach<E, L, R, A>(
    Iterable<A> iterable,
    Effect<E, L, R> Function(A a, int index) f,
  ) =>
      Effect._(
        (env) {
          if (iterable.isEmpty) {
            return Right([]);
          }

          return iterable
              .mapWithIndex(f)
              .fold<Effect<E, L, Iterable<R>>>(
                Effect.succeed(Iterable.empty()),
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
        (env) => _unsafeRun(f(env!)),
      );

  /// {@category do_notation}
  static Effect<E, L, E> env<E, L>() => Effect._(
        (env) => Right(env!),
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

  /// {@category mapping}
  Effect<E, R, L> get flip => Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Fail<L>(error: final error) => Right(error),
                Empty() => Left(cause),
                Die() => Left(cause),
              },
            Right(value: final value) => Left(Fail(value)),
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
                Fail<L>(error: final error) => Left(Fail(f(error))),
                Empty() => Left(cause),
                Die() => Left(cause),
              },
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
                Fail<L>(error: final error) => Left(Fail(fl(error))),
                Empty() => Left(cause),
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
                Fail<L>(error: final error) => f(error)._unsafeRun(env).then(
                      (_) => Left(Fail(error)),
                    ),
                Empty() => Left(cause),
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
                Fail<L>(error: final error) => orElse(error)._unsafeRun(env),
                Empty() => Left(cause),
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
            Left(value: final cause) => Left(Die.current(cause, stackTrace)),
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
                Fail<L>(error: final error) =>
                  Left(Die.current(onError(error))),
                Empty() => Left(cause),
                Die() => Left(cause),
              },
            Right(value: final value) =>
              Effect<E, Never, R>.succeed(value)._unsafeRun(env),
          },
        ),
      );

  /// {@category error_handling}
  Effect<E, Never, R> catchError(
    Effect<E, Never, R> Function(L error) f,
  ) =>
      Effect._(
        (env) => _unsafeRun(env).then(
          (exit) => switch (exit) {
            Left(value: final cause) => switch (cause) {
                Fail<L>(error: final error) => f(error)._unsafeRun(env),
                Empty() => Left(cause),
                Die() => Left(cause),
              },
            Right(value: final value) =>
              Effect<E, Never, R>.succeed(value)._unsafeRun(env),
          },
        ),
      );
}

extension ProvideNever<L, R> on Effect<Never, L, R> {
  /// Add a required dependency instead of [Never].
  ///
  /// {@category do_notation}
  Effect<V, L, R> withEnv<V>() => Effect._(
        (env) => _unsafeRun(null),
      );

  /// {@category execution}
  R runSyncNoEnv() {
    final result = _unsafeRun(null);
    if (result is Future) {
      throw Die.current(result, stackTrace);
    }

    return switch (result) {
      Left(value: final cause) => throw cause,
      Right(value: final value) => value,
    };
  }

  /// {@category execution}
  Exit<L, R> runSyncExitNoEnv() {
    final result = _unsafeRun(null);
    if (result is Future) {
      return Left(Die.current(""));
    }
    return result;
  }

  /// {@category execution}
  Future<R> runFutureNoEnv() async {
    final result = await _unsafeRun(null);
    return switch (result) {
      Left(value: final cause) => throw cause,
      Right(value: final value) => value,
    };
  }

  /// {@category execution}
  Future<Exit<L, R>> runFutureExitNoEnv() async => _unsafeRun(null);
}

extension ProvideVoid<L, R> on Effect<void, L, R> {
  /// {@category execution}
  Effect<V, L, R> provideVoid<V>() => provide((env) {});
}
