part of "effect.dart";

final class _DoThrow<E> {
  final E value;
  const _DoThrow(this.value);
}

typedef _DoAdapter<R, E> = Future<A> Function<A>(Effect<R, E, A>);

_DoAdapter<R, E> _doAdapter<R, E>(R env) =>
    <A>(effect) => effect.runFutureExit(env).then(
          (either) => either.getOrElse((l) => throw _DoThrow(l)),
        );

typedef DoFunction<R, E, A> = Future<A> Function(_DoAdapter<R, E> _);
