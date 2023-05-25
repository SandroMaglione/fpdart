import 'either.dart';
import 'function.dart';
import 'option.dart';
import 'task.dart';
import 'typeclass/alt.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

final class _TaskEitherThrow<L> {
  final L value;
  const _TaskEitherThrow(this.value);
}

typedef DoAdapterTaskEither<E> = Future<A> Function<A>(TaskEither<E, A>);
DoAdapterTaskEither<L> _doAdapter<L>() =>
    <A>(taskEither) => taskEither.run().then(
          (either) => either.getOrElse((l) => throw _TaskEitherThrow(l)),
        );

typedef DoFunctionTaskEither<L, A> = Future<A> Function(
    DoAdapterTaskEither<L> $);

/// Tag the [HKT2] interface for the actual [TaskEither].
abstract final class _TaskEitherHKT {}

/// `TaskEither<L, R>` represents an asynchronous computation that
/// either yields a value of type `R` or fails yielding an error of type `L`.
///
/// If you want to represent an asynchronous computation that never fails, see [Task].
final class TaskEither<L, R> extends HKT2<_TaskEitherHKT, L, R>
    with
        Functor2<_TaskEitherHKT, L, R>,
        Applicative2<_TaskEitherHKT, L, R>,
        Monad2<_TaskEitherHKT, L, R>,
        Alt2<_TaskEitherHKT, L, R> {
  final Future<Either<L, R>> Function() _run;

  /// Build a [TaskEither] from a function returning a `Future<Either<L, R>>`.
  const TaskEither(this._run);

  /// Initialize a **Do Notation** chain.
  // ignore: non_constant_identifier_names
  factory TaskEither.Do(DoFunctionTaskEither<L, R> f) => TaskEither(() async {
        try {
          return Either.of(await f(_doAdapter<L>()));
        } on _TaskEitherThrow<L> catch (e) {
          return Either.left(e.value);
        }
      });

  /// Used to chain multiple functions that return a [TaskEither].
  ///
  /// You can extract the value of every [Right] in the chain without
  /// handling all possible missing cases.
  /// If running any of the tasks in the chain returns [Left], the result is [Left].
  @override
  TaskEither<L, C> flatMap<C>(covariant TaskEither<L, C> Function(R r) f) =>
      TaskEither(() => run().then(
            (either) async => either.match(
              left,
              (r) => f(r).run(),
            ),
          ));

  /// Chain an [Either] to [TaskEither] by converting it from sync to async.
  TaskEither<L, C> bindEither<C>(Either<L, C> either) =>
      flatMap((_) => either.toTaskEither());

  /// Chain a function that takes the current value `R` inside this [TaskEither]
  /// and returns [Either].
  ///
  /// Similar to `flatMap`, but `f` returns [Either] instead of [TaskEither].
  TaskEither<L, C> chainEither<C>(Either<L, C> Function(R r) f) => flatMap(
        (r) => f(r).toTaskEither(),
      );

  /// Returns a [TaskEither] that returns a `Right(a)`.
  @override
  TaskEither<L, C> pure<C>(C a) => TaskEither(() async => Right(a));

  /// Change the return type of this [TaskEither] based on its value of type `R` and the
  /// value of type `C` of another [TaskEither].
  @override
  TaskEither<L, D> map2<C, D>(
          covariant TaskEither<L, C> m1, D Function(R b, C c) f) =>
      flatMap((b) => m1.map((c) => f(b, c)));

  /// Change the return type of this [TaskEither] based on its value of type `R`, the
  /// value of type `C` of a second [TaskEither], and the value of type `D`
  /// of a third [TaskEither].
  @override
  TaskEither<L, E> map3<C, D, E>(covariant TaskEither<L, C> m1,
          covariant TaskEither<L, D> m2, E Function(R b, C c, D d) f) =>
      flatMap((b) => m1.flatMap((c) => m2.map((d) => f(b, c, d))));

  /// If running this [TaskEither] returns [Right], then return the result of calling `then`.
  /// Otherwise return [Left].
  @override
  TaskEither<L, C> andThen<C>(covariant TaskEither<L, C> Function() then) =>
      flatMap((_) => then());

  /// If running this [TaskEither] returns [Right], then change its value from type `R` to
  /// type `C` using function `f`.
  @override
  TaskEither<L, C> map<C>(C Function(R r) f) => ap(pure(f));

  /// Change the value in the [Left] of [TaskEither].
  TaskEither<C, R> mapLeft<C>(C Function(L l) f) => TaskEither(
        () async => (await run()).match((l) => Either.left(f(l)), Either.of),
      );

  /// Define two functions to change both the [Left] and [Right] value of the
  /// [TaskEither].
  ///
  /// {@macro fpdart_bimap_either}
  TaskEither<C, D> bimap<C, D>(C Function(L l) mLeft, D Function(R r) mRight) =>
      mapLeft(mLeft).map(mRight);

  /// Apply the function contained inside `a` to change the value on the [Right] from
  /// type `R` to a value of type `C`.
  @override
  TaskEither<L, C> ap<C>(covariant TaskEither<L, C Function(R r)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  /// Chain multiple functions having the same left type `L`.
  @override
  TaskEither<L, C> call<C>(covariant TaskEither<L, C> chain) =>
      flatMap((_) => chain);

  /// Change this [TaskEither] from `TaskEither<L, R>` to `TaskEither<R, L>`.
  TaskEither<R, L> swap() =>
      TaskEither(() async => (await run()).match(right, left));

  /// When this [TaskEither] returns [Right], then return the current [TaskEither].
  /// Otherwise return the result of `orElse`.
  ///
  /// Used to provide an **alt**ernative [TaskEither] in case the current one returns [Left].
  @override
  TaskEither<L, R> alt(covariant TaskEither<L, R> Function() orElse) =>
      TaskEither(() async => (await run()).match((_) => orElse().run(), right));

  /// If `f` applied on this [TaskEither] as [Right] returns `true`, then return this [TaskEither].
  /// If it returns `false`, return the result of `onFalse` in a [Left].
  TaskEither<L, R> filterOrElse(
          bool Function(R r) f, L Function(R r) onFalse) =>
      flatMap((r) => f(r) ? TaskEither.of(r) : TaskEither.left(onFalse(r)));

  /// When this [TaskEither] returns a [Left] then return the result of `orElse`.
  /// Otherwise return this [TaskEither].
  TaskEither<TL, R> orElse<TL>(TaskEither<TL, R> Function(L l) orElse) =>
      TaskEither(() async => (await run()).match(
          (l) => orElse(l).run(), (r) => TaskEither<TL, R>.right(r).run()));

  /// Convert this [TaskEither] to a [Task].
  ///
  /// The task returns a [Right] when [TaskEither] returns [Right].
  /// Otherwise map the type `L` of [TaskEither] to type `R` by calling `orElse`.
  Task<R> getOrElse(R Function(L l) orElse) =>
      Task(() async => (await run()).match(orElse, identity));

  /// Pattern matching to convert a [TaskEither] to a [Task].
  ///
  /// Execute `onLeft` when running this [TaskEither] returns a [Left].
  /// Otherwise execute `onRight`.
  Task<A> match<A>(A Function(L l) onLeft, A Function(R r) onRight) =>
      Task(() async => (await run()).match(onLeft, onRight));

  /// Creates a [TaskEither] that will complete after a time delay specified by a [Duration].
  TaskEither<L, R> delay(Duration duration) =>
      TaskEither(() => Future.delayed(duration, run));

  /// Chain a request that returns another [TaskEither], execute it, ignore
  /// the result, and return the same value as the current [TaskEither].
  @override
  TaskEither<L, R> chainFirst<C>(
    covariant TaskEither<L, C> Function(R b) chain,
  ) =>
      flatMap((b) => chain(b).map((c) => b).orElse((l) => TaskEither.right(b)));

  /// Run the task and return a `Future<Either<L, R>>`.
  Future<Either<L, R>> run() => _run();

  /// Build a [TaskEither] that returns a `Right(r)`.
  ///
  /// Same of `TaskEither.right`.
  factory TaskEither.of(R r) => TaskEither(() async => Either.of(r));

  /// Flat a [TaskEither] contained inside another [TaskEither] to be a single [TaskEither].
  factory TaskEither.flatten(TaskEither<L, TaskEither<L, R>> taskEither) =>
      taskEither.flatMap(identity);

  /// Build a [TaskEither] that returns a `Right(right)`.
  ///
  /// Same of `TaskEither.of`.
  factory TaskEither.right(R right) => TaskEither(() async => Either.of(right));

  /// Build a [TaskEither] that returns a `Left(left)`.
  factory TaskEither.left(L left) => TaskEither(() async => Left(left));

  /// Build a [TaskEither] that returns a [Left] containing the result of running `task`.
  factory TaskEither.leftTask(Task<L> task) =>
      TaskEither(() => task.run().then(left));

  /// Build a [TaskEither] that returns a [Right] containing the result of running `task`.
  ///
  /// Same of `TaskEither.fromTask`
  factory TaskEither.rightTask(Task<R> task) =>
      TaskEither(() async => Right(await task.run()));

  /// Build a [TaskEither] from the result of running `task`.
  ///
  /// Same of `TaskEither.rightTask`
  factory TaskEither.fromTask(Task<R> task) =>
      TaskEither(() async => Right(await task.run()));

  /// {@template fpdart_from_nullable_task_either}
  /// If `r` is `null`, then return the result of `onNull` in [Left].
  /// Otherwise return `Right(r)`.

  /// {@endtemplate}
  factory TaskEither.fromNullable(R? r, L Function() onNull) =>
      Either.fromNullable(r, onNull).toTaskEither();

  /// {@macro fpdart_from_nullable_task_either}
  factory TaskEither.fromNullableAsync(R? r, Task<L> onNull) => TaskEither(
      () async => r != null ? Either.of(r) : Either.left(await onNull.run()));

  /// When calling `predicate` with `value` returns `true`, then running [TaskEither] returns `Right(value)`.
  /// Otherwise return `onFalse`.
  factory TaskEither.fromPredicate(
          R value, bool Function(R a) predicate, L Function(R a) onFalse) =>
      TaskEither(
          () async => predicate(value) ? Right(value) : Left(onFalse(value)));

  /// Build a [TaskEither] from `option`.
  ///
  /// When `option` is [Some], then return [Right] when
  /// running [TaskEither]. Otherwise return `onNone`.
  factory TaskEither.fromOption(Option<R> option, L Function() onNone) =>
      TaskEither(() async => option.match(
            () => Left(onNone()),
            Right.new,
          ));

  /// Build a [TaskEither] that returns `either`.
  factory TaskEither.fromEither(Either<L, R> either) =>
      TaskEither(() async => either);

  /// {@template fpdart_try_catch_task_either}
  /// Execute an async function ([Future]) and convert the result to [Either]:
  /// - If the execution is successful, returns a [Right]
  /// - If the execution fails (`throw`), then return a [Left] based on `onError`
  ///
  /// Used to work with [Future] and exceptions using [Either] instead of `try`/`catch`.
  /// {@endtemplate}
  /// ```dart
  /// /// From [Future] to [TaskEither]
  /// Future<int> imperative(String str) async {
  ///   try {
  ///     return int.parse(str);
  ///   } catch (e) {
  ///     return -1; /// What does -1 means? 🤨
  ///   }
  /// }
  ///
  /// TaskEither<String, int> functional(String str) {
  ///   return TaskEither.tryCatch(
  ///     () async => int.parse(str),
  ///     /// Clear error 🪄
  ///     (error, stackTrace) => "Parsing error: $error",
  ///   );
  /// }
  /// ```
  factory TaskEither.tryCatch(Future<R> Function() run,
          L Function(Object error, StackTrace stackTrace) onError) =>
      TaskEither<L, R>(() async {
        try {
          return Right<L, R>(await run());
        } catch (error, stack) {
          return Left<L, R>(onError(error, stack));
        }
      });

  /// {@template fpdart_traverse_list_task_either}
  /// Map each element in the list to a [TaskEither] using the function `f`,
  /// and collect the result in an `TaskEither<E, List<B>>`.
  ///
  /// Each [TaskEither] is executed in parallel. This strategy is faster than
  /// sequence, but **the order of the request is not guaranteed**.
  ///
  /// If you need [TaskEither] to be executed in sequence, use `traverseListWithIndexSeq`.
  /// {@endtemplate}
  ///
  /// Same as `TaskEither.traverseList` but passing `index` in the map function.
  static TaskEither<E, List<B>> traverseListWithIndex<E, A, B>(
    List<A> list,
    TaskEither<E, B> Function(A a, int i) f,
  ) =>
      TaskEither<E, List<B>>(
        () async => Either.sequenceList(
          await Task.traverseListWithIndex<A, Either<E, B>>(
            list,
            (a, i) => Task(() => f(a, i).run()),
          ).run(),
        ),
      );

  /// {@macro fpdart_traverse_list_task_either}
  ///
  /// Same as `TaskEither.traverseListWithIndex` but without `index` in the map function.
  static TaskEither<E, List<B>> traverseList<E, A, B>(
    List<A> list,
    TaskEither<E, B> Function(A a) f,
  ) =>
      traverseListWithIndex<E, A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_task_either}
  /// Convert a `List<TaskEither<E, A>>` to a single `TaskEither<E, List<A>>`.
  ///
  /// Each [TaskEither] will be executed in parallel.
  ///
  /// If you need [TaskEither] to be executed in sequence, use `sequenceListSeq`.
  /// {@endtemplate}
  static TaskEither<E, List<A>> sequenceList<E, A>(
    List<TaskEither<E, A>> list,
  ) =>
      traverseList(list, identity);

  /// {@template fpdart_traverse_list_seq_task_either}
  /// Map each element in the list to a [TaskEither] using the function `f`,
  /// and collect the result in an `TaskEither<E, List<B>>`.
  ///
  /// Each [TaskEither] is executed in sequence. This strategy **takes more time than
  /// parallel**, but it ensures that all the request are executed in order.
  ///
  /// If you need [TaskEither] to be executed in parallel, use `traverseListWithIndex`.
  /// {@endtemplate}
  ///
  /// Same as `TaskEither.traverseList` but passing `index` in the map function.
  static TaskEither<E, List<B>> traverseListWithIndexSeq<E, A, B>(
    List<A> list,
    TaskEither<E, B> Function(A a, int i) f,
  ) =>
      TaskEither<E, List<B>>(
        () async => Either.sequenceList(
          await Task.traverseListWithIndexSeq<A, Either<E, B>>(
            list,
            (a, i) => Task(() => f(a, i).run()),
          ).run(),
        ),
      );

  /// {@macro fpdart_traverse_list_seq_task_either}
  ///
  /// Same as `TaskEither.traverseListWithIndex` but without `index` in the map function.
  static TaskEither<E, List<B>> traverseListSeq<E, A, B>(
    List<A> list,
    TaskEither<E, B> Function(A a) f,
  ) =>
      traverseListWithIndexSeq<E, A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_seq_task_either}
  /// Convert a `List<TaskEither<E, A>>` to a single `TaskEither<E, List<A>>`.
  ///
  /// Each [TaskEither] will be executed in sequence.
  ///
  /// If you need [TaskEither] to be executed in parallel, use `sequenceList`.
  /// {@endtemplate}
  static TaskEither<E, List<A>> sequenceListSeq<E, A>(
    List<TaskEither<E, A>> list,
  ) =>
      traverseListSeq(list, identity);

  /// {@macro fpdart_try_catch_task_either}
  ///
  /// It wraps the `TaskEither.tryCatch` factory to make chaining with `flatMap`
  /// easier.
  static TaskEither<L, R> Function(T a) tryCatchK<L, R, T>(
          Future<R> Function(T a) run,
          L Function(Object error, StackTrace stackTrace) onError) =>
      (a) => TaskEither.tryCatch(
            () => run(a),
            onError,
          );
}
