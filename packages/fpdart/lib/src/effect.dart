import 'dart:async';

import 'package:meta/meta.dart';

import 'exit.dart';

part 'n_either.dart';
part 'n_option.dart';

final class _EffectThrow<L> {
  final L value;
  const _EffectThrow(this.value);
}

typedef DoAdapterEffect<E, L> = Future<A> Function<A>(IEffect<E, L, A>);

DoAdapterEffect<E, L> _doAdapter<E, L>(E env) => <A>(effect) => Future.sync(
      () => effect._runEffect(env).then(
            (exit) => switch (exit) {
              Failure(value: final value) => throw _EffectThrow(value),
              Success(value: final value) => value,
            },
          ),
    );

typedef DoFunctionEffect<E, L, A> = Future<A> Function(DoAdapterEffect<E, L> _);

typedef UnsafeRun<E, L, R> = FutureOr<Exit<L, R>> Function(E env);

abstract interface class IEffect<E, L, R> {
  final UnsafeRun<E, L, R> _unsafeRun;
  const IEffect._(this._unsafeRun);

  Future<Exit<L, R>> _runEffect(E env) async => _unsafeRun(env);

  @mustBeOverridden
  IEffect<E, L, C> andThen<C>(IEffect<E, L, C> Function() then) =>
      flatMap((_) => then());

  @mustBeOverridden
  IEffect<E, L, C> flatMap<C>(
    IEffect<E, L, C> Function(R r) f,
  ) =>
      Effect._(
        (env) => _runEffect(env).then(
          (exit) async => switch (exit) {
            Failure(value: final value) => Future.value(Exit.failure(value)),
            Success(value: final value) => f(value)._runEffect(env),
          },
        ),
      );

  @mustBeOverridden
  IEffect<E, L, V> ap<V>(IEffect<E, L, V Function(R r)> f);

  @mustBeOverridden
  IEffect<E, L, V> map<V>(V Function(R r) f);

  @override
  String toString() {
    return "Effect(${_unsafeRun.runtimeType})";
  }
}

final class Effect<E, L, R> extends IEffect<E, L, R> {
  const Effect._(UnsafeRun<E, L, R> run) : super._(run);

  factory Effect.tryCatch(
    FutureOr<R> Function() execute,
    L Function(Object error, StackTrace stackTrace) onError,
  ) =>
      Effect._(
        (env) async {
          try {
            return Exit.success(await execute());
          } catch (e, s) {
            return Exit.failure(onError(e, s));
          }
        },
      );

  factory Effect.function(FutureOr<R> Function() f) =>
      Effect._((_) async => Exit.success(await f()));
  factory Effect.fail(L value) => Effect._((_) async => Exit.failure(value));
  factory Effect.succeed(R value) => Effect._((_) async => Exit.success(value));

  Effect<V, L, R> withEnv<V>(E Function(V env) f) => Effect._(
        (env) => _unsafeRun(f(env)),
      );

  static Effect<E, L, E> ask<E, L>() => Effect._(
        (env) async => Exit.success(env),
      );

  Future<Exit<L, R>> call(E env) => _runEffect(env);

  @override
  String toString() {
    return "Effect(${_unsafeRun.runtimeType})";
  }

  @override
  Effect<E, L, C> flatMap<C>(covariant Effect<E, L, C> Function(R r) f) =>
      Effect._(super.flatMap(f)._unsafeRun);

  @override
  Effect<E, L, V> ap<V>(
    covariant Effect<E, L, V Function(R r)> f,
  ) =>
      f.flatMap(
        (f) => flatMap(
          (v) => Effect.succeed(f(v)),
        ),
      );

  @override
  Effect<E, L, V> map<V>(V Function(R r) f) => ap(Effect.succeed(f));

  @override
  Effect<E, L, C> andThen<C>(covariant Effect<E, L, C> Function() then) =>
      Effect._(super.andThen(then)._unsafeRun);

  Effect<E, C, R> mapLeft<C>(C Function(L l) f) => Effect._(
        (env) async => switch ((await _runEffect(env))) {
          Failure(value: final value) => Exit.failure(f(value)),
          Success(value: final value) => Exit.success(value),
        },
      );

  Effect<E, C, R> orElse<C>(
    covariant Effect<E, C, R> Function(L l) orElse,
  ) =>
      Effect._(
        (env) async => switch ((await _unsafeRun(env))) {
          Failure(value: final value) => orElse(value)._unsafeRun(env),
          Success(value: final value) =>
            Effect<E, C, R>.succeed(value)._unsafeRun(env),
        },
      );
}

Effect<E, L, R> doEffect<E, L, R>(DoFunctionEffect<E, L, R> f) =>
    Effect<E, L, R>._(
      (env) async {
        try {
          return Exit.success(await f(_doAdapter<E, L>(env)));
        } on _EffectThrow<L> catch (e) {
          return Exit.failure(e.value);
        }
      },
    );
