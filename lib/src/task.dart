import 'package:fpdart/fpdart.dart';

/// Tag the [HKT] interface for the actual [Task].
abstract class _TaskHKT {}

/// [Task] represents an asynchronous computation that yields a value of type `A` and **never fails**.
///
/// If you want to represent an asynchronous computation that may fail, see [TaskEither].
class Task<A> extends HKT<_TaskHKT, A>
    with Functor<_TaskHKT, A>, Applicative<_TaskHKT, A>, Monad<_TaskHKT, A> {
  final Future<A> Function() _run;

  /// Build a [Task] from a function returning a [Future].
  const Task(this._run);

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

  /// {@template fpdart_traverse_list_task}
  /// Map each element in the list to a [Task] using the function `f`,
  /// and collect the result in an `Task<List<B>>`.
  ///
  /// Each [Task] is executed in parallel.
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

  /// Convert a `List<Task<A>>` to a single `Task<List<A>>`.
  static Task<List<A>> sequenceList<A>(
    List<Task<A>> list,
  ) =>
      traverseList(list, identity);
}
