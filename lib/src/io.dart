import 'package:fpdart/fpdart.dart';

/// Tag the [HKT] interface for the actual [Option].
abstract class _IOHKT {}

/// `IO<A>` represents a **non-deterministic synchronous** computation that
/// can **cause side effects**, yields a value of type `A` and **never fails**.
///
/// If you want to represent a synchronous computation that may fail, see [IOEither].
class IO<A> extends HKT<_IOHKT, A>
    with Functor<_IOHKT, A>, Applicative<_IOHKT, A>, Monad<_IOHKT, A> {
  final A Function() _run;

  /// Build an instance of [IO] from `A Function()`.
  const IO(this._run);

  /// Flat a [IO] contained inside another [IO] to be a single [IO].
  factory IO.flatten(IO<IO<A>> io) => io.flatMap(identity);

  /// Build a [IO] that returns `a`.
  factory IO.of(A a) => IO(() => a);

  /// Used to chain multiple functions that return a [IO].
  @override
  IO<B> flatMap<B>(covariant IO<B> Function(A a) f) => IO(() => f(run()).run());

  /// Chain a [Task] with an [IO].
  ///
  /// Allows to chain a function that returns a `R` ([IO]) to
  /// a function that returns a `Future<B>` ([Task]).
  Task<B> flatMapTask<B>(Task<B> Function(A a) f) => f(run());

  /// Lift this [IO] to a [Task].
  ///
  /// Return a `Future<A>` ([Task]) instead of a `R` ([IO]).
  Task<A> toTask() => Task(() async => run());

  /// Return an [IO] that returns the value `b`.
  @override
  IO<B> pure<B>(B b) => IO(() => b);

  /// Change the value of type `A` to a value of type `B` using function `f`.
  @override
  IO<B> map<B>(B Function(A a) f) => ap(pure(f));

  /// Apply the function contained inside `a` to change the value of type `A` to
  /// a value of type `B`.
  @override
  IO<B> ap<B>(covariant IO<B Function(A a)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  /// Change type of this [IO] based on its value of type `A` and the
  /// value of type `C` of another [IO].
  @override
  IO<D> map2<C, D>(covariant IO<C> mc, D Function(A a, C c) f) =>
      flatMap((a) => mc.map((c) => f(a, c)));

  /// Change type of this [IO] based on its value of type `A`, the
  /// value of type `C` of a second [IO], and the value of type `D`
  /// of a third [IO].
  @override
  IO<E> map3<C, D, E>(covariant IO<C> mc, covariant IO<D> md,
          E Function(A a, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  /// Chain multiple [IO] functions.
  @override
  IO<B> call<B>(covariant IO<B> chain) => flatMap((_) => chain);

  /// Chain the result of `then` to this [IO].
  @override
  IO<B> andThen<B>(covariant IO<B> Function() then) => flatMap((_) => then());

  /// Execute the IO function.
  A run() => _run();

  @override
  bool operator ==(Object other) => (other is IO) && other._run == _run;

  @override
  int get hashCode => _run.hashCode;
}
