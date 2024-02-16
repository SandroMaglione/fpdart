import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'either.dart';

final class _EffectThrow<L> {
  final L value;
  const _EffectThrow(this.value);
}

typedef DoAdapterEffect<E, L> = Future<A> Function<A>(Effect<E, L, A>);

DoAdapterEffect<E, L> _doAdapter<E, L>(E env) =>
    <A>(effect) => effect.runEffect(env).then(
          (either) => either.getOrElse((l) => throw _EffectThrow(l)),
        );

typedef DoFunctionEffect<E, L, A> = Future<A> Function(DoAdapterEffect<E, L> _);

typedef UnsafeRun<E, L, R> = FutureOr<Either<L, R>> Function(E env);

final class Effect<E, L, R> {
  final UnsafeRun<E, L, R> _unsafeRun;

  const Effect._(this._unsafeRun);

  factory Effect.tryFuture(
    FutureOr<R> Function() execute,
    L Function(Object error, StackTrace stackTrace) onError,
  ) =>
      Effect._(
        (env) async {
          try {
            return Either.right(await execute());
          } catch (e, s) {
            return Either.left(onError(e, s));
          }
        },
      );

  Future<Either<L, R>> runEffect(E env) async => _unsafeRun(env);

  Effect<E, L, C> flatMap<C>(
    Effect<E, L, C> Function(R r) f,
  ) =>
      Effect._(
        (env) => runEffect(env).then(
          (either) async => either.match(
            left,
            (r) => f(r).runEffect(env),
          ),
        ),
      );

  @override
  String toString() {
    return "Effect(${_unsafeRun.runtimeType})";
  }
}

final class AsyncEither<L, R> extends Effect<void, L, R> {
  const AsyncEither._(UnsafeRun<void, L, R> run) : super._(run);

  factory AsyncEither._fromEffect(Effect<void, L, R> effect) =>
      AsyncEither._(effect.runEffect);

  factory AsyncEither.tryFuture(
    FutureOr<R> Function() execute,
    L Function(Object error, StackTrace stackTrace) onError,
  ) =>
      AsyncEither._fromEffect(
        Effect<void, L, R>.tryFuture(execute, onError),
      );
}

final class SyncEither<L, R> extends Effect<void, L, R> {
  const SyncEither._(UnsafeRun<void, L, R> run) : super._(run);

  factory SyncEither._fromEffect(Effect<void, L, R> effect) =>
      SyncEither._(effect.runEffect);

  factory SyncEither.trySync(
    R Function() execute,
    L Function(Object error, StackTrace stackTrace) onError,
  ) =>
      SyncEither._fromEffect(
        Effect<void, L, R>.tryFuture(execute, onError),
      );
}

final class Sync<R> extends Effect<void, Never, R> {
  const Sync._(UnsafeRun<void, Never, R> run) : super._(run);

  factory Sync._fromEffect(Effect<void, Never, R> effect) =>
      Sync._(effect.runEffect);

  factory Sync.make(
    R Function() execute,
  ) =>
      Sync._fromEffect(
        Effect<void, Never, R>.tryFuture(
          execute,
          (_, __) => throw Exception(
            "Error when building Sync.make",
          ),
        ),
      );

  factory Sync.value(R value) => Sync._(
        (_) => Either.right(value),
      );

  @override
  Sync<C> flatMap<C>(covariant Sync<C> Function(R r) f) {
    return Sync._fromEffect(super.flatMap(f));
  }
}

Effect<E, L, R> doEffect<E, L, R>(DoFunctionEffect<E, L, R> f) =>
    Effect<E, L, R>._(
      (env) async {
        try {
          return Either.of(await f(_doAdapter<E, L>(env)));
        } on _EffectThrow<L> catch (e) {
          return Either.left(e.value);
        }
      },
    );
