import 'either.dart';
import 'extension/iterable_extension.dart';
import 'function.dart';
import 'option.dart';
import 'task_either.dart';
import 'task_option.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

typedef DoAdapterTask = Future<A> Function<A>(Task<A>);
Future<A> _doAdapter<A>(Task<A> task) => task.run();

typedef DoFunctionTask<A> = Future<A> Function(DoAdapterTask $);

/// Tag the [HKT] interface for the actual [Task].
abstract final class _TaskHKT {}

/// [Task] represents an asynchronous computation that yields a value of type `A` and **never fails**.
///
/// If you want to represent an asynchronous computation that may fail, see [TaskEither].
final class Task<A> extends HKT<_TaskHKT, A>
    with Functor<_TaskHKT, A>, Applicative<_TaskHKT, A>, Monad<_TaskHKT, A> {
  final Future<A> Function() _run;

  /// Build a [Task] from a function returning a [Future].
  const Task(this._run);

  /// Initialize a **Do Notation** chain.
  // ignore: non_constant_identifier_names
  factory Task.Do(DoFunctionTask<A> f) => Task(() => f(_doAdapter));

  /// Build a [Task] that returns `a`.
  factory Task.of(A a) => Task<A>(() async => a);

  /// Flat a [Task] contained inside another [Task] to be a single [Task].
  factory Task.flatten(Task<Task<A>> task) => task.flatMap(identity);

  /// Apply the function contained inside `a` to change the value of type `A` to
  /// a value of type `B`.
  @override
  Task<B> ap<B>(covariant Task<B Function(A a)> a) =>
      Task(() => a.run().then((f) => run().then((v) => f(v))));

  /// Used to chain multiple functions that return a [Task].
  ///
  /// You can extract the value inside the [Task] without actually running it.
  @override
  Task<B> flatMap<B>(covariant Task<B> Function(A a) f) =>
      Task(() => run().then((v) => f(v).run()));

  /// Return a [Task] returning the value `b`.
  @override
  Task<B> pure<B>(B a) => Task(() async => a);

  /// Change the returning value of the [Task] from type
  /// `A` to type `B` using `f`.
  @override
  Task<B> map<B>(B Function(A a) f) => ap(pure(f));

  /// Change type of this [Task] based on its value of type `A` and the
  /// value of type `C` of another [Task].
  @override
  Task<D> map2<C, D>(covariant Task<C> mc, D Function(A a, C c) f) =>
      flatMap((a) => mc.map((c) => f(a, c)));

  /// Change type of this [Task] based on its value of type `A`, the
  /// value of type `C` of a second [Task], and the value of type `D`
  /// of a third [Task].
  @override
  Task<E> map3<C, D, E>(covariant Task<C> mc, covariant Task<D> md,
          E Function(A a, C c, D d) f) =>
      flatMap((a) => mc.flatMap((c) => md.map((d) => f(a, c, d))));

  /// Run this [Task] and right after the [Task] returned from `then`.
  @override
  Task<B> andThen<B>(covariant Task<B> Function() then) =>
      flatMap((_) => then());

  @override
  Task<A> chainFirst<B>(covariant Task<B> Function(A a) chain) =>
      flatMap((a) => chain(a).map((b) => a));

  /// Chain multiple [Task] functions.
  @override
  Task<B> call<B>(covariant Task<B> chain) => flatMap((_) => chain);

  /// Creates a task that will complete after a time delay specified by a [Duration].
  Task<A> delay(Duration duration) => Task(() => Future.delayed(duration, run));

  /// Run the task and return a [Future].
  Future<A> run() => _run();

  /// Convert this [Task] to [TaskOption].
  TaskOption<A> toTaskOption() =>
      TaskOption(() async => Option.of(await run()));

  /// Convert this [Task] to [TaskEither].
  TaskEither<L, A> toTaskEither<L>() =>
      TaskEither<L, A>(() async => Either.of(await run()));

  /// {@template fpdart_traverse_list_task}
  /// Map each element in the list to a [Task] using the function `f`,
  /// and collect the result in an `Task<List<B>>`.
  ///
  /// Each [Task] is executed in parallel. This strategy is faster than
  /// sequence, but **the order of the request is not guaranteed**.
  ///
  /// If you need [Task] to be executed in sequence, use `traverseListWithIndexSeq`.
  /// {@endtemplate}
  ///
  /// Same as `Task.traverseList` but passing `index` in the map function.
  static Task<List<B>> traverseListWithIndex<A, B>(
    List<A> list,
    Task<B> Function(A a, int i) f,
  ) =>
      Task<List<B>>(
        () => Future.wait<B>(
          list.mapWithIndex(
            (a, i) => f(a, i).run(),
          ),
        ),
      );

  /// {@macro fpdart_traverse_list_task}
  ///
  /// Same as `Task.traverseListWithIndex` but without `index` in the map function.
  static Task<List<B>> traverseList<A, B>(
    List<A> list,
    Task<B> Function(A a) f,
  ) =>
      traverseListWithIndex<A, B>(list, (a, _) => f(a));

  /// {@template fpdart_traverse_list_seq_task}
  /// Map each element in the list to a [Task] using the function `f`,
  /// and collect the result in an `Task<List<B>>`.
  ///
  /// Each [Task] is executed in sequence. This strategy **takes more time than
  /// parallel**, but it ensures that all the request are executed in order.
  ///
  /// If you need [Task] to be executed in parallel, use `traverseListWithIndex`.
  /// {@endtemplate}
  ///
  /// Same as `Task.traverseListSeq` but passing `index` in the map function.
  static Task<List<B>> traverseListWithIndexSeq<A, B>(
    List<A> list,
    Task<B> Function(A a, int i) f,
  ) =>
      Task<List<B>>(() async {
        List<B> collect = [];
        for (var i = 0; i < list.length; i++) {
          collect.add(await f(list[i], i).run());
        }
        return collect;
      });

  /// {@macro fpdart_traverse_list_seq_task}
  ///
  /// Same as `Task.traverseListWithIndexSeq` but without `index` in the map function.
  static Task<List<B>> traverseListSeq<A, B>(
    List<A> list,
    Task<B> Function(A a) f,
  ) =>
      traverseListWithIndexSeq<A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_task}
  /// Convert a `List<Task<A>>` to a single `Task<List<A>>`.
  ///
  /// Each [Task] will be executed in parallel.
  ///
  /// If you need [Task] to be executed in sequence, use `sequenceListSeq`.
  /// {@endtemplate}
  static Task<List<A>> sequenceList<A>(
    List<Task<A>> list,
  ) =>
      traverseList(list, identity);

  /// {@template fpdart_sequence_list_seq_task}
  /// Convert a `List<Task<A>>` to a single `Task<List<A>>`.
  ///
  /// Each [Task] will be executed in sequence.
  ///
  /// If you need [Task] to be executed in parallel, use `sequenceList`.
  /// {@endtemplate}
  static Task<List<A>> sequenceListSeq<A>(
    List<Task<A>> list,
  ) =>
      traverseListSeq(list, identity);
}
