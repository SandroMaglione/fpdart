import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/extension/future_or_extension.dart';
import 'package:fpdart/src/extension/iterable_extension.dart';
import 'package:meta/meta.dart';

import 'unit.dart' as fpdart_unit;

part 'either.dart';
part 'option.dart';

final class _EffectThrow<L> {
  final Cause<L> cause;
  const _EffectThrow(this.cause);
}

typedef DoAdapterEffect<E, L> = Future<A> Function<A>(IEffect<E, L, A>);

DoAdapterEffect<E, L> _doAdapter<E, L>(E? env) => <A>(effect) => Future.sync(
      () => effect.asEffect._unsafeRun(env).then(
            (exit) => switch (exit) {
              Left(value: final cause) => throw _EffectThrow(cause),
              Right(value: final value) => value,
            },
          ),
    );

typedef DoFunctionEffect<E, L, A> = Future<A> Function(DoAdapterEffect<E, L> _);

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
        (env) async {
          try {
            return Right(await f(_doAdapter<E, L>(env)));
          } on _EffectThrow<L> catch (err) {
            return Left(err.cause);
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
            return execute().then(Right.new);
          } catch (err, stack) {
            return Left(Fail(onError(err, stack), stack));
          }
        },
      );

  /// {@category constructors}
  factory Effect.fromNullable(R? value, L Function() onNull) => Effect._(
        (_) => value == null ? Left(Fail(onNull())) : Right(value),
      );

  /// {@category constructors}
  factory Effect.function(FutureOr<R> Function() f) => Effect._(
        (_) => f().then(Right.new),
      );

  /// {@category constructors}
  factory Effect.fail(L value) => Effect._((_) => Left(Fail(value)));

  /// {@category constructors}
  factory Effect.succeed(R value) => Effect._((_) => Right(value));

  /// {@category constructors}
  static Effect<Never, Never, fpdart_unit.Unit> unit() => Effect._(
        (_) => Right(fpdart_unit.unit),
      );

  /// {@category collecting}
  static Effect<E, L, Iterable<R>> allIterable<E, L, R, A>(
    Iterable<A> iterable,
    Effect<E, L, R> Function(A _) f,
  ) =>
      Effect._(
        (env) {
          if (iterable.isEmpty) {
            return Right([]);
          }

          return iterable
              .map(f)
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
      Effect.allIterable(
        iterable,
        identity,
      );

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

  /// {@category sequencing}
  Effect<E, L, C> andThen<C>(Effect<E, L, C> Function() then) =>
      flatMap((_) => then());

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
}
