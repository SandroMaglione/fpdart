import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'either.dart';

part 'async_either.dart';
part 'sync.dart';
part 'sync_either.dart';

final class _EffectThrow<L> {
  final L value;
  const _EffectThrow(this.value);
}

typedef DoAdapterEffect<E, L> = Future<A> Function<A>(IEffect<E, L, A>);

DoAdapterEffect<E, L> _doAdapter<E, L>(E env) =>
    <A>(effect) => effect._runEffect(env).then(
          (either) => either.getOrElse((l) => throw _EffectThrow(l)),
        );

typedef DoFunctionEffect<E, L, A> = Future<A> Function(DoAdapterEffect<E, L> _);

typedef UnsafeRun<E, L, R> = FutureOr<Either<L, R>> Function(E env);

abstract interface class IEffect<E, L, R> {
  final UnsafeRun<E, L, R> _unsafeRun;
  const IEffect._(this._unsafeRun);

  Future<Either<L, R>> _runEffect(E env) async => _unsafeRun(env);

  @mustBeOverridden
  IEffect<E, L, C> flatMap<C>(
    IEffect<E, L, C> Function(R r) f,
  ) =>
      Effect._(
        (env) => _runEffect(env).then(
          (either) async => either.match(
            left,
            (r) => f(r)._runEffect(env),
          ),
        ),
      );

  @override
  String toString() {
    return "Effect(${_unsafeRun.runtimeType})";
  }
}

final class Effect<E, L, R> extends IEffect<E, L, R> {
  const Effect._(UnsafeRun<E, L, R> run) : super._(run);

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

  Future<Either<L, R>> call(E env) => _runEffect(env);

  @override
  String toString() {
    return "Effect(${_unsafeRun.runtimeType})";
  }

  @override
  Effect<E, L, C> flatMap<C>(covariant Effect<E, L, C> Function(R r) f) {
    return Effect._(super.flatMap(f)._unsafeRun);
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
