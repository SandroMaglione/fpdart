import 'function.dart';
import 'state.dart';
import 'tuple.dart';
import 'typeclass/typeclass.export.dart';
import 'unit.dart';

/// Tag the [HKT2] interface for the actual [StateAsync].
abstract class _StateAsyncHKT {}

/// `StateAsync<S, A>` is used to store, update, and extract async state in a functional way.
///
/// `S` is a State (e.g. the current _State_ of your Bank Account).
/// `A` is value that you _extract out of the [StateAsync]_
/// (Account Balance fetched from the current state of your Bank Account `S`).
///
/// Used when fetching and updating the state is **asynchronous**. Use [State] otherwise.
class StateAsync<S, A> extends HKT2<_StateAsyncHKT, S, A>
    with
        Functor2<_StateAsyncHKT, S, A>,
        Applicative2<_StateAsyncHKT, S, A>,
        Monad2<_StateAsyncHKT, S, A> {
  final Future<Tuple2<A, S>> Function(S state) _run;

  /// Build a new [StateAsync] given a `Future<Tuple2<A, S>> Function(S)`.
  const StateAsync(this._run);

  /// Flat a [StateAsync] contained inside another [StateAsync] to be a single [StateAsync].
  factory StateAsync.flatten(StateAsync<S, StateAsync<S, A>> state) =>
      state.flatMap(identity);

  /// Build a new [StateAsync] by lifting a sync [State] to async.
  factory StateAsync.fromState(State<S, A> state) =>
      StateAsync((s) async => state.run(s));

  /// Used to chain multiple functions that return a [StateAsync].
  @override
  StateAsync<S, C> flatMap<C>(covariant StateAsync<S, C> Function(A a) f) =>
      StateAsync((state) async {
        final tuple = await run(state);
        return f(tuple.first).run(tuple.second);
      });

  /// Apply the function contained inside `a` to change the value of type `A` to
  /// a value of type `C`.
  @override
  StateAsync<S, C> ap<C>(covariant StateAsync<S, C Function(A a)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  /// Return a `StateAsync<S, C>` containing `c` as value.
  @override
  StateAsync<S, C> pure<C>(C c) =>
      StateAsync((state) async => Tuple2(c, state));

  /// Change the value inside `StateAsync<S, A>` from type `A` to type `C` using `f`.
  @override
  StateAsync<S, C> map<C>(C Function(A a) f) => ap(pure(f));

  /// Change type of this [StateAsync] based on its value of type `A` and the
  /// value of type `C` of another [StateAsync].
  @override
  StateAsync<S, D> map2<C, D>(
          covariant StateAsync<S, C> m1, D Function(A a, C c) f) =>
      flatMap((a) => m1.map((c) => f(a, c)));

  /// Change type of this [StateAsync] based on its value of type `A`, the
  /// value of type `C` of a second [StateAsync], and the value of type `D`
  /// of a third [StateAsync].
  @override
  StateAsync<S, E> map3<C, D, E>(covariant StateAsync<S, C> m1,
          covariant StateAsync<S, D> m2, E Function(A a, C c, D d) f) =>
      flatMap((a) => m1.flatMap((c) => m2.map((d) => f(a, c, d))));

  /// Chain the result of `then` to this [StateAsync].
  @override
  StateAsync<S, C> andThen<C>(covariant StateAsync<S, C> Function() then) =>
      flatMap((_) => then());

  /// Chain multiple functions having the same state `S`.
  @override
  StateAsync<S, C> call<C>(covariant StateAsync<S, C> state) =>
      flatMap((_) => state);

  /// Extract the current state `S`.
  StateAsync<S, S> get() => StateAsync((state) async => Tuple2(state, state));

  /// Change the value getter based on the current state `S`.
  StateAsync<S, A> gets(A Function(S state) f) =>
      StateAsync((state) async => Tuple2(f(state), state));

  /// Change the current state `S` using `f` and return nothing ([Unit]).
  StateAsync<S, Unit> modify(S Function(S state) f) =>
      StateAsync((state) async => Tuple2(unit, f(state)));

  /// Set a new state and return nothing ([Unit]).
  StateAsync<S, Unit> put(S state) =>
      StateAsync((_) async => Tuple2(unit, state));

  /// Execute `run` and extract the value `A`.
  ///
  /// To extract both the value and the state use `run`.
  ///
  /// To extract only the state `S` use `execute`.
  Future<A> evaluate(S state) async => (await run(state)).first;

  /// Execute `run` and extract the state `S`.
  ///
  /// To extract both the value and the state use `run`.
  ///
  /// To extract only the value `A` use `evaluate`.
  Future<S> execute(S state) async => (await run(state)).second;

  /// Chain a request that returns another [StateAsync], execute it, ignore
  /// the result, and return the same value as the current [StateAsync].
  ///
  /// **Note**: `chainFirst` will not change the value of `first` for the state,
  /// but **it will change the value of `second`** when calling `run()`.
  @override
  StateAsync<S, A> chainFirst<C>(
    covariant StateAsync<S, C> Function(A a) chain,
  ) =>
      flatMap((a) => chain(a).map((_) => a));

  /// Extract value `A` and state `S` by passing the original state `S`.
  ///
  /// To extract only the value `A` use `evaluate`.
  ///
  /// To extract only the state `S` use `execute`.
  Future<Tuple2<A, S>> run(S state) => _run(state);

  @override
  bool operator ==(Object other) => (other is StateAsync) && other._run == _run;

  @override
  int get hashCode => _run.hashCode;
}
