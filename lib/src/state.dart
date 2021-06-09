import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/tuple.dart';

abstract class StateHKT {}

/// `S` is a State
/// (Examples: The current State of your Bank Account, The current State of Random Number Generator Seed).
/// `A` is value that you _extract out of the State_
/// (Example: `A` can be Account Balance fetched from the current state of your Bank Account `S`).
class State<S, A> extends HKT2<StateHKT, S, A> with Monad2<StateHKT, S, A> {
  final Tuple2<A, S> Function(S state) _run;
  State(this._run);

  @override
  State<S, C> flatMap<C>(covariant State<S, C> Function(A a) f) =>
      State((state) => f(run(state).value1).run(state));

  @override
  State<S, C> ap<C>(covariant State<S, C Function(A a)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  @override
  State<S, C> pure<C>(C a) => State((state) => Tuple2(a, state));

  @override
  State<S, C> map<C>(C Function(A a) f) => ap(pure(f));

  /// Extract the current state [S].
  State<S, S> get() => State((state) => Tuple2(state, state));

  /// Set a new state and return nothing ([Unit]).
  State<S, Unit> put(S state) => State((_) => Tuple2(unit, state));

  /// Execute `run` and extract the value [A].
  A evalState(S state) => run(state).value1;

  /// Execute `run` and extract the state [S].
  S execState(S state) => run(state).value2;

  /// Extract value [A] and state [S] by passing the original state [S].
  Tuple2<A, S> run(S state) => _run(state);
}
