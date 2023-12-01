import 'function.dart';
import 'state_async.dart';
import 'typeclass/typeclass.export.dart';
import 'unit.dart';

/// Tag the [HKT2] interface for the actual [State].
abstract final class _StateHKT {}

/// `State<S, A>` is used to store, update, and extract state in a functional way.
///
/// `S` is a State (e.g. the current _State_ of your Bank Account).
/// `A` is value that you _extract out of the [State]_
/// (Account Balance fetched from the current state of your Bank Account `S`).
final class State<S, A> extends HKT2<_StateHKT, S, A>
    with
        Functor2<_StateHKT, S, A>,
        Applicative2<_StateHKT, S, A>,
        Monad2<_StateHKT, S, A> {
  final (A, S) Function(S state) _run;

  /// Build a new [State] given a `(A, S) Function(S)`.
  const State(this._run);

  /// Flat a [State] contained inside another [State] to be a single [State].
  factory State.flatten(State<S, State<S, A>> state) => state.flatMap(identity);

  /// Lift a sync [State] to an async [StateAsync].
  StateAsync<S, A> toStateAsync() => StateAsync.fromState(this);

  /// Used to chain multiple functions that return a [State].
  @override
  State<S, C> flatMap<C>(covariant State<S, C> Function(A a) f) =>
      State((state) {
        final tuple = run(state);
        return f(tuple.$1).run(tuple.$2);
      });

  /// Apply the function contained inside `a` to change the value of type `A` to
  /// a value of type `C`.
  @override
  State<S, C> ap<C>(covariant State<S, C Function(A a)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  /// Return a `State<S, C>` containing `c` as value.
  @override
  State<S, C> pure<C>(C c) => State((state) => (c, state));

  /// Change the value inside `State<S, A>` from type `A` to type `C` using `f`.
  @override
  State<S, C> map<C>(C Function(A a) f) => ap(pure(f));

  /// Change type of this [State] based on its value of type `A` and the
  /// value of type `C` of another [State].
  @override
  State<S, D> map2<C, D>(covariant State<S, C> m1, D Function(A a, C c) f) =>
      flatMap((a) => m1.map((c) => f(a, c)));

  /// Change type of this [State] based on its value of type `A`, the
  /// value of type `C` of a second [State], and the value of type `D`
  /// of a third [State].
  @override
  State<S, E> map3<C, D, E>(covariant State<S, C> m1, covariant State<S, D> m2,
          E Function(A a, C c, D d) f) =>
      flatMap((a) => m1.flatMap((c) => m2.map((d) => f(a, c, d))));

  /// Chain the result of `then` to this [State].
  @override
  State<S, C> andThen<C>(covariant State<S, C> Function() then) =>
      flatMap((_) => then());

  /// Chain multiple functions having the same state `S`.
  @override
  State<S, C> call<C>(covariant State<S, C> state) => flatMap((_) => state);

  /// Extract the current state `S`.
  State<S, S> get() => State((state) => (state, state));

  /// Change the value getter based on the current state `S`.
  State<S, A> gets(A Function(S state) f) =>
      State((state) => (f(state), state));

  /// Change the current state `S` using `f` and return nothing ([Unit]).
  State<S, Unit> modify(S Function(S state) f) =>
      State((state) => (unit, f(state)));

  /// Set a new state and return nothing ([Unit]).
  State<S, Unit> put(S state) => State((_) => (unit, state));

  /// Chain a request that returns another [State], execute it, ignore
  /// the result, and return the same value as the current [State].
  ///
  /// **Note**: `chainFirst` will not change the value of `first` for the state,
  /// but **it will change the value of `second`** when calling `run()`.
  @override
  State<S, A> chainFirst<C>(
    covariant State<S, C> Function(A a) chain,
  ) =>
      flatMap((a) => chain(a).map((_) => a));

  /// Execute `run` and extract the value `A`.
  ///
  /// To extract both the value and the state use `run`.
  ///
  /// To extract only the state `S` use `execute`.
  A evaluate(S state) => run(state).$1;

  /// Execute `run` and extract the state `S`.
  ///
  /// To extract both the value and the state use `run`.
  ///
  /// To extract only the value `A` use `evaluate`.
  S execute(S state) => run(state).$2;

  /// Extract value `A` and state `S` by passing the original state `S`.
  ///
  /// To extract only the value `A` use `evaluate`.
  ///
  /// To extract only the state `S` use `execute`.
  (A, S) run(S state) => _run(state);

  /// {@template fpdart_traverse_list_state}
  /// Map each element in the list to a [State] using the function `f`,
  /// and collect the result in a `State<S, List<B>>`.
  /// {@endtemplate}
  ///
  /// Same as `State.traverseList` but passing `index` in the map function.
  static State<S, List<B>> traverseListWithIndex<S, A, B>(
      List<A> list, State<S, B> Function(A a, int i) f) {
    return State((state) {
      final resultList = <B>[];
      var out = state;
      for (var i = 0; i < list.length; i++) {
        final (b, s) = f(list[i], i).run(out);
        resultList.add(b);
        out = s;
      }
      return (resultList, out);
    });
  }

  /// {@macro fpdart_traverse_list_state}
  ///
  /// Same as `State.traverseListWithIndex` but without `index` in the map function.
  static State<S, List<B>> traverseList<S, A, B>(
          List<A> list, State<S, B> Function(A a) f) =>
      traverseListWithIndex<S, A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_state}
  /// Convert a `List<State<S, A>>` to a single `State<S, List<A>>`.
  /// {@endtemplate}
  static State<S, List<A>> sequenceList<S, A>(List<State<S, A>> list) =>
      traverseList(list, identity);

  @override
  bool operator ==(Object other) => (other is State) && other._run == _run;

  @override
  int get hashCode => _run.hashCode;
}
