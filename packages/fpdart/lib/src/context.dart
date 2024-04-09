part of "effect.dart";

final class Context<E> {
  final E env;
  final Deferred<Never, Never> signal;

  const Context._({required this.env, required this.signal});

  factory Context({
    required E env,
    required Deferred<Never, Never> signal,
  }) =>
      Context._(env: env, signal: signal);

  factory Context.env(E env) =>
      Context._(env: env, signal: Deferred.unsafeMake());

  Context<C> withEnv<C>(C env) => Context._(env: env, signal: signal);

  Context<E> get withoutSignal => withSignal(Deferred.unsafeMake());
  Context<E> withSignal(Deferred<Never, Never> signal) =>
      copyWith(signal: signal);

  Context<E> copyWith({
    E? env,
    Deferred<Never, Never>? signal,
  }) =>
      Context._(
        env: env ?? this.env,
        signal: signal ?? this.signal,
      );
}
