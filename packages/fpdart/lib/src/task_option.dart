import 'either.dart';
import 'extension/option_extension.dart';
import 'function.dart';
import 'option.dart';
import 'task.dart';
import 'task_either.dart';
import 'typeclass/alt.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

final class _TaskOptionThrow {
  const _TaskOptionThrow();
}

typedef DoAdapterTaskOption = Future<A> Function<A>(TaskOption<A>);
Future<A> _doAdapter<A>(TaskOption<A> taskOption) => taskOption.run().then(
      (option) => option.getOrElse(() => throw const _TaskOptionThrow()),
    );

typedef DoFunctionTaskOption<A> = Future<A> Function(DoAdapterTaskOption $);

/// Tag the [HKT] interface for the actual [TaskOption].
abstract final class _TaskOptionHKT {}

/// `TaskOption<R>` represents an **asynchronous** computation that
/// may fails yielding a [None] or returns a `Some(R)` when successful.
///
/// If you want to represent an asynchronous computation that never fails, see [Task].
///
/// If you want to represent an asynchronous computation that returns an object when it fails,
/// see [TaskEither].
final class TaskOption<R> extends HKT<_TaskOptionHKT, R>
    with
        Functor<_TaskOptionHKT, R>,
        Applicative<_TaskOptionHKT, R>,
        Monad<_TaskOptionHKT, R>,
        Alt<_TaskOptionHKT, R> {
  final Future<Option<R>> Function() _run;

  /// Build a [TaskOption] from a function returning a `Future<Option<R>>`.
  const TaskOption(this._run);

  /// Initialize a **Do Notation** chain.
  // ignore: non_constant_identifier_names
  factory TaskOption.Do(DoFunctionTaskOption<R> f) => TaskOption(() async {
        try {
          return Option.of(await f(_doAdapter));
        } on _TaskOptionThrow catch (_) {
          return const Option.none();
        }
      });

  /// Used to chain multiple functions that return a [TaskOption].
  ///
  /// You can extract the value of every [Some] in the chain without
  /// handling all possible missing cases.
  /// If running any of the tasks in the chain returns [None], the result is [None].
  @override
  TaskOption<C> flatMap<C>(covariant TaskOption<C> Function(R r) f) =>
      TaskOption(() => run().then(
            (option) async => option.match(
              Option.none,
              (r) => f(r).run(),
            ),
          ));

  /// Returns a [TaskOption] that returns `Some(c)`.
  @override
  TaskOption<C> pure<C>(C c) => TaskOption(() async => Option.of(c));

  /// Change the return type of this [TaskOption] based on its value of type `R` and the
  /// value of type `C` of another [TaskOption].
  @override
  TaskOption<D> map2<C, D>(
          covariant TaskOption<C> m1, D Function(R b, C c) f) =>
      flatMap((b) => m1.map((c) => f(b, c)));

  /// Change the return type of this [TaskOption] based on its value of type `R`, the
  /// value of type `C` of a second [TaskOption], and the value of type `D`
  /// of a third [TaskOption].
  @override
  TaskOption<E> map3<C, D, E>(covariant TaskOption<C> m1,
          covariant TaskOption<D> m2, E Function(R b, C c, D d) f) =>
      flatMap((b) => m1.flatMap((c) => m2.map((d) => f(b, c, d))));

  /// If running this [TaskOption] returns [Some], then return the result of calling `then`.
  /// Otherwise return [None].
  @override
  TaskOption<C> andThen<C>(covariant TaskOption<C> Function() then) =>
      flatMap((_) => then());

  /// Chain multiple [TaskOption] functions.
  @override
  TaskOption<B> call<B>(covariant TaskOption<B> chain) => flatMap((_) => chain);

  /// If running this [TaskOption] returns [Some], then change its value from type `R` to
  /// type `C` using function `f`.
  @override
  TaskOption<C> map<C>(C Function(R r) f) => ap(pure(f));

  /// Apply the function contained inside `a` to change the value on the [Some] from
  /// type `R` to a value of type `C`.
  @override
  TaskOption<C> ap<C>(covariant TaskOption<C Function(R r)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  /// When this [TaskOption] returns [Some], then return the current [TaskOption].
  /// Otherwise return the result of `orElse`.
  ///
  /// Used to provide an **alt**ernative [TaskOption] in case the current one returns [None].
  @override
  TaskOption<R> alt(covariant TaskOption<R> Function() orElse) =>
      TaskOption(() async => (await run()).match(
            () => orElse().run(),
            some,
          ));

  /// When this [TaskOption] returns a [None] then return the result of `orElse`.
  /// Otherwise return this [TaskOption].
  TaskOption<R> orElse<TL>(TaskOption<R> Function() orElse) =>
      TaskOption(() async => (await run()).match(
            () => orElse().run(),
            (r) => TaskOption<R>.some(r).run(),
          ));

  /// Convert this [TaskOption] to a [Task].
  ///
  /// The task returns a [Some] when [TaskOption] returns [Some].
  /// Otherwise map the type `L` of [TaskOption] to type `R` by calling `orElse`.
  Task<R> getOrElse(R Function() orElse) =>
      Task(() async => (await run()).match(
            orElse,
            identity,
          ));

  /// Pattern matching to convert a [TaskOption] to a [Task].
  ///
  /// Execute `onNone` when running this [TaskOption] returns a [None].
  /// Otherwise execute `onSome`.
  Task<A> match<A>(A Function() onNone, A Function(R r) onSome) =>
      Task(() async => (await run()).match(
            onNone,
            onSome,
          ));

  /// Creates a [TaskOption] that will complete after a time delay specified by a [Duration].
  TaskOption<R> delay(Duration duration) =>
      TaskOption(() => Future.delayed(duration, run));

  /// Run the task and return a `Future<Option<R>>`.
  Future<Option<R>> run() => _run();

  /// Convert this [TaskOption] to [TaskEither].
  ///
  /// If the value inside [TaskOption] is [None], then use `onNone` to convert it
  /// to a value of type `L`.
  TaskEither<L, R> toTaskEither<L>(L Function() onNone) =>
      TaskEither(() async => Either.fromOption(await run(), onNone));

  /// Build a [TaskOption] that returns a `Some(r)`.
  ///
  /// Same of `TaskOption.some`.
  factory TaskOption.of(R r) => TaskOption(() async => Option.of(r));

  /// Flat a [TaskOption] contained inside another [TaskOption] to be a single [TaskOption].
  factory TaskOption.flatten(TaskOption<TaskOption<R>> taskOption) =>
      taskOption.flatMap(identity);

  /// Build a [TaskOption] that returns a `Some(r)`.
  ///
  /// Same of `TaskOption.of`.
  factory TaskOption.some(R r) => TaskOption(() async => Option.of(r));

  /// Build a [TaskOption] that returns a [None].
  factory TaskOption.none() => TaskOption(() async => const Option.none());

  /// Build a [TaskOption] from the result of running `task`.
  factory TaskOption.fromTask(Task<R> task) =>
      TaskOption(() async => Option.of(await task.run()));

  /// If `r` is `null`, then return [None].
  /// Otherwise return `Right(r)`.
  factory TaskOption.fromNullable(R? r) =>
      Option.fromNullable(r).toTaskOption();

  /// When calling `predicate` with `value` returns `true`, then running [TaskOption] returns `Some(value)`.
  /// Otherwise return [None].
  factory TaskOption.fromPredicate(R value, bool Function(R a) predicate) =>
      TaskOption(
        () async => predicate(value) ? Option.of(value) : const Option.none(),
      );

  /// Converts a [Future] that may throw to a [Future] that never throws
  /// but returns a [Option] instead.
  ///
  /// Used to handle asynchronous computations that may throw using [Option].
  factory TaskOption.tryCatch(Future<R> Function() run) =>
      TaskOption<R>(() async {
        try {
          return Option.of(await run());
        } catch (_) {
          return const Option.none();
        }
      });

  /// {@template fpdart_traverse_list_task_option}
  /// Map each element in the list to a [TaskOption] using the function `f`,
  /// and collect the result in an `TaskOption<List<B>>`.
  ///
  /// Each [TaskOption] is executed in parallel. This strategy is faster than
  /// sequence, but **the order of the request is not guaranteed**.
  ///
  /// If you need [TaskOption] to be executed in sequence, use `traverseListWithIndexSeq`.
  /// {@endtemplate}
  ///
  /// Same as `TaskOption.traverseList` but passing `index` in the map function.
  static TaskOption<List<B>> traverseListWithIndex<A, B>(
    List<A> list,
    TaskOption<B> Function(A a, int i) f,
  ) =>
      TaskOption<List<B>>(
        () async => Option.sequenceList(
          await Task.traverseListWithIndex<A, Option<B>>(
            list,
            (a, i) => Task(() => f(a, i).run()),
          ).run(),
        ),
      );

  /// {@macro fpdart_traverse_list_task_option}
  ///
  /// Same as `TaskOption.traverseListWithIndex` but without `index` in the map function.
  static TaskOption<List<B>> traverseList<A, B>(
    List<A> list,
    TaskOption<B> Function(A a) f,
  ) =>
      traverseListWithIndex<A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_task_option}
  /// Convert a `List<TaskOption<A>>` to a single `TaskOption<List<A>>`.
  ///
  /// Each [TaskOption] will be executed in parallel.
  ///
  /// If you need [TaskOption] to be executed in sequence, use `sequenceListSeq`.
  /// {@endtemplate}
  static TaskOption<List<A>> sequenceList<A>(
    List<TaskOption<A>> list,
  ) =>
      traverseList(list, identity);

  /// {@template fpdart_traverse_list_seq_task_option}
  /// Map each element in the list to a [TaskOption] using the function `f`,
  /// and collect the result in an `TaskOption<List<B>>`.
  ///
  /// Each [TaskOption] is executed in sequence. This strategy **takes more time than
  /// parallel**, but it ensures that all the request are executed in order.
  ///
  /// If you need [TaskOption] to be executed in parallel, use `traverseListWithIndex`.
  /// {@endtemplate}
  ///
  /// Same as `TaskOption.traverseListSeq` but passing `index` in the map function.
  static TaskOption<List<B>> traverseListWithIndexSeq<A, B>(
    List<A> list,
    TaskOption<B> Function(A a, int i) f,
  ) =>
      TaskOption<List<B>>(
        () async => Option.sequenceList(
          await Task.traverseListWithIndexSeq<A, Option<B>>(
            list,
            (a, i) => Task(() => f(a, i).run()),
          ).run(),
        ),
      );

  /// {@macro fpdart_traverse_list_seq_task_option}
  ///
  /// Same as `TaskOption.traverseListWithIndexSeq` but without `index` in the map function.
  static TaskOption<List<B>> traverseListSeq<A, B>(
    List<A> list,
    TaskOption<B> Function(A a) f,
  ) =>
      traverseListWithIndexSeq<A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_seq_task_option}
  /// Convert a `List<TaskOption<A>>` to a single `TaskOption<List<A>>`.
  ///
  /// Each [TaskOption] will be executed in sequence.
  ///
  /// If you need [TaskOption] to be executed in parallel, use `sequenceList`.
  /// {@endtemplate}
  static TaskOption<List<A>> sequenceListSeq<A>(
    List<TaskOption<A>> list,
  ) =>
      traverseListSeq(list, identity);

  /// Build a [TaskOption] from `either` that returns [None] when
  /// `either` is [Left], otherwise it returns [Some].
  static TaskOption<R> fromEither<L, R>(Either<L, R> either) =>
      TaskOption(() async => either.match((_) => const Option.none(), some));

  /// Converts a [Future] that may throw to a [Future] that never throws
  /// but returns a [Option] instead.
  ///
  /// Used to handle asynchronous computations that may throw using [Option].
  ///
  /// It wraps the `TaskOption.tryCatch` factory to make chaining with `flatMap`
  /// easier.
  static TaskOption<R> Function(A a) tryCatchK<R, A>(
          Future<R> Function(A a) run) =>
      (a) => TaskOption.tryCatch(() => run(a));
}
