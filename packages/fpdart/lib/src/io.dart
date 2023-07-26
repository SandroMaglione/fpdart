import 'either.dart';
import 'function.dart';
import 'io_either.dart';
import 'io_option.dart';
import 'option.dart';
import 'task.dart';
import 'task_either.dart';
import 'task_option.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

typedef DoAdapterIO = A Function<A>(IO<A>);
A _doAdapter<A>(IO<A> io) => io.run();

typedef DoFunctionIO<A> = A Function(DoAdapterIO $);

/// Tag the [HKT] interface for the actual [Option].
abstract final class _IOHKT {}

/// `IO<A>` represents a **non-deterministic synchronous** computation that
/// can **cause side effects**, yields a value of type `A` and **never fails**.
///
/// If you want to represent a synchronous computation that may fail, see [IOEither].
final class IO<A> extends HKT<_IOHKT, A>
    with Functor<_IOHKT, A>, Applicative<_IOHKT, A>, Monad<_IOHKT, A> {
  final A Function() _run;

  /// Build an instance of [IO] from `A Function()`.
  const IO(this._run);

  /// Initialize a **Do Notation** chain.
  // ignore: non_constant_identifier_names
  factory IO.Do(DoFunctionIO<A> f) => IO(() => f(_doAdapter));

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

  /// Convert this [IO] to a [IOEither].
  IOEither<L, A> toIOEither<L>() => IOEither<L, A>(() => Either.of(run()));

  /// Lift this [IO] to a [Task].
  ///
  /// Return a `Future<A>` ([Task]) instead of a `R` ([IO]).
  Task<A> toTask() => Task<A>(() async => run());

  /// Convert this [IO] to a [TaskEither].
  TaskEither<L, A> toTaskEither<L>() =>
      TaskEither<L, A>(() async => Either.of(run()));

  /// Convert this [IO] to a [TaskOption].
  TaskOption<A> toTaskOption() => TaskOption<A>(() async => Option.of(run()));

  /// Convert this [IO] to a [IOOption].
  IOOption<A> toIOOption() => IOOption<A>(() => Option.of(run()));

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

  /// {@template fpdart_traverse_list_io}
  /// Map each element in the list to an [IO] using the function `f`,
  /// and collect the result in an `IO<List<B>>`.
  /// {@endtemplate}
  ///
  /// Same as `IO.traverseList` but passing `index` in the map function.
  static IO<List<B>> traverseListWithIndex<A, B>(
    List<A> list,
    IO<B> Function(A a, int i) f,
  ) =>
      IO<List<B>>(() {
        final resultList = <B>[];
        for (var i = 0; i < list.length; i++) {
          resultList.add(f(list[i], i).run());
        }
        return resultList;
      });

  /// {@macro fpdart_traverse_list_io}
  ///
  /// Same as `IO.traverseListWithIndex` but without `index` in the map function.
  static IO<List<B>> traverseList<A, B>(
    List<A> list,
    IO<B> Function(A a) f,
  ) =>
      traverseListWithIndex<A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_io}
  /// Convert a `List<IO<A>>` to a single `IO<List<A>>`.
  /// {@endtemplate}
  static IO<List<A>> sequenceList<A>(
    List<IO<A>> list,
  ) =>
      traverseList(list, identity);

  @override
  bool operator ==(Object other) => (other is IO) && other._run == _run;

  @override
  int get hashCode => _run.hashCode;
}
