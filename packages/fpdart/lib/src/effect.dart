import 'dart:async';

import 'package:meta/meta.dart';

import 'exit.dart';

part 'either.dart';
part 'option.dart';

final class _EffectThrow<L> {
  final L value;
  const _EffectThrow(this.value);
}

typedef DoAdapterEffect<E, L> = Future<A> Function<A>(IEffect<E, L, A>);

DoAdapterEffect<E, L> _doAdapter<E, L>(E env) => <A>(effect) => Future.sync(
      () => effect.asEffect._runEffect(env).then(
            (exit) => switch (exit) {
              Failure(value: final value) => throw _EffectThrow(value),
              Success(value: final value) => value,
            },
          ),
    );

typedef DoFunctionEffect<E, L, A> = Future<A> Function(DoAdapterEffect<E, L> _);

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
  Future<Exit<L, R>> _runEffect(E env) async => _unsafeRun(env);

  /// {@category execution}
  Future<Exit<L, R>> call(E env) => _runEffect(env);

  /// {@category execution}
  R runSync(E env) {
    final result = _unsafeRun(env);
    if (result is Future) {
      throw Exception("Cannot use runSync for an async Effect");
    }

    return switch (result) {
      Failure<L, R>() => throw Exception("Failed runSync Effect"),
      Success<L, R>(value: final value) => value,
    };
  }

  /// {@category execution}
  Future<R> runFuture(E env) async {
    final result = await _unsafeRun(env);
    return switch (result) {
      Failure<L, R>() => throw Exception("Failed runFuture Effect"),
      Success<L, R>(value: final value) => value,
    };
  }

  /// {@category constructors}
  // ignore: non_constant_identifier_names
  factory Effect.gen(DoFunctionEffect<E, L, R> f) => Effect<E, L, R>._(
        (env) async {
          try {
            return Exit.success(await f(_doAdapter<E, L>(env)));
          } on _EffectThrow<L> catch (e) {
            return Exit.failure(e.value);
          }
        },
      );

  /// {@category constructors}
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

  /// {@category constructors}
  factory Effect.function(FutureOr<R> Function() f) => Effect._(
        (_) async => Exit.success(await f()),
      );

  /// {@category constructors}
  factory Effect.fail(L value) => Effect._((_) async => Exit.failure(value));

  /// {@category constructors}
  factory Effect.succeed(R value) => Effect._((_) async => Exit.success(value));

  /// {@category constructors}
  static Effect<Never, Never, void> unit() => Effect._(
        (_) async => Exit.success(null),
      );

  /// Extract the required dependency from the complete environment.
  ///
  /// {@category do_notation}
  Effect<V, L, R> provide<V>(E Function(V env) f) => Effect._(
        (env) => _unsafeRun(f(env)),
      );

  /// {@category do_notation}
  static Effect<E, L, E> env<E, L>() => Effect._(
        (env) async => Exit.success(env),
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
  Effect<E, L, V> map<V>(V Function(R r) f) => ap(Effect.succeed(f));

  /// {@category mapping}
  Effect<E, C, R> mapError<C>(C Function(L l) f) => Effect._(
        (env) async => switch ((await _runEffect(env))) {
          Failure(value: final value) => Exit.failure(f(value)),
          Success(value: final value) => Exit.success(value),
        },
      );

  /// {@category mapping}
  Effect<E, C, D> mapBoth<C, D>(C Function(L l) fl, D Function(R r) fr) =>
      Effect._(
        (env) async => switch ((await _runEffect(env))) {
          Failure(value: final value) => Exit.failure(fl(value)),
          Success(value: final value) => Exit.success(fr(value)),
        },
      );

  /// {@category sequencing}
  Effect<E, L, C> flatMap<C>(Effect<E, L, C> Function(R r) f) => Effect._(
        (env) => _runEffect(env).then(
          (exit) async => switch (exit) {
            Failure(value: final value) => Future.value(Exit.failure(value)),
            Success(value: final value) => f(value)._runEffect(env),
          },
        ),
      );

  /// {@category sequencing}
  Effect<E, L, R> tap<C>(Effect<E, L, C> Function(R r) f) =>
      flatMap((r) => f(r).map((_) => r));

  /// {@category sequencing}
  Effect<E, L, R> tapError<C>(Effect<E, C, R> Function(L l) f) => Effect._(
        (env) async {
          switch ((await _runEffect(env))) {
            case Failure(value: final value):
              await f(value)._unsafeRun(env);
              return Exit<L, R>.failure(value);
            case Success(value: final value):
              return Exit.success(value);
          }
        },
      );

  /// {@category sequencing}
  Effect<E, L, C> andThen<C>(Effect<E, L, C> Function() then) =>
      flatMap((_) => then());

  /// {@category alternatives}
  Effect<E, C, R> orElse<C>(
    Effect<E, C, R> Function(L l) orElse,
  ) =>
      Effect._(
        (env) async => switch ((await _unsafeRun(env))) {
          Failure(value: final value) => orElse(value)._unsafeRun(env),
          Success(value: final value) =>
            Effect<E, C, R>.succeed(value)._unsafeRun(env),
        },
      );

  /// {@category error_handling}
  Effect<E, Never, R> catchError(
    Effect<E, Never, R> Function(L error) f,
  ) =>
      Effect._(
        (env) async => switch ((await _unsafeRun(env))) {
          Failure(value: final value) => f(value)._unsafeRun(env),
          Success(value: final value) =>
            Effect<E, Never, R>.succeed(value)._unsafeRun(env),
        },
      );
}
