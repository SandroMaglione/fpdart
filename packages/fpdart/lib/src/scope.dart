part of "effect.dart";

mixin ScopeMixin {
  bool get scopeClosable => false;

  final scopeFinalizers = <Effect<Null, Never, Unit>>[];

  Effect<E, L, Unit> addScopeFinalizer<E, L>(
    Effect<Null, Never, Unit> finalizer,
  ) =>
      Effect.functionSucceed(() {
        scopeFinalizers.add(finalizer);
        return unit;
      });

  Effect<E, L, Unit> removeScopeFinalizer<L, E>(
    Effect<Null, Never, Unit> finalizer,
  ) =>
      Effect.functionSucceed(() {
        scopeFinalizers.remove(finalizer);
        return unit;
      });

  Effect<E, L, Unit> closeScope<E, L>() => Effect.lazy(
        () => scopeFinalizers.reversed.all.zipRight(Effect.functionSucceed(
          () {
            scopeFinalizers.clear();
            return unit;
          },
        )).withEnv(),
      );
}

class Scope<R> with ScopeMixin {
  final bool _closable;
  final R env;
  Scope._(this.env, this._closable);

  factory Scope.withEnv(R env, [bool closable = false]) =>
      Scope._(env, closable);

  @override
  bool get scopeClosable => _closable;
}
