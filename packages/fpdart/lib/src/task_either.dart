import 'either.dart';
import 'function.dart';
import 'option.dart';
import 'task.dart';
import 'typeclass/alt.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

part 'task_either_extension.dart';

final class _TaskEitherThrow<L> implements Exception {
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
            (either) => either.match(
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

  /// Build a [TaskEither] from a `Task<Either<L, R>>`.
  factory TaskEither.fromTaskFlatten(Task<Either<L, R>> composedTaskEither) =>
      TaskEither(() => composedTaskEither.run());

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
  ///   } on Exception catch (e) {
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

  /// {@template fpdart_traverse_record_task_either}
  /// Apply the provided functions to each element of the record, executing each
  /// resulting [TaskEither] in **parallel**, and collect the results in a record.
  ///
  /// If any [TaskEither] returns [Left], the result is [Left] with the first
  /// error encountered.
  ///
  /// For sequential execution, use the `Seq` variant.
  /// {@endtemplate}
  static TaskEither<E, (B1, B2)> traverseRecord2<E, A1, A2, B1, B2>(
    (A1, A2) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
  ) =>
      TaskEither(() async {
        final results = await (f1(record.$1).run(), f2(record.$2).run()).wait;
        return results.$1.flatMap((b1) => results.$2.map((b2) => (b1, b2)));
      });

  /// {@macro fpdart_traverse_record_task_either}
  static TaskEither<E, (B1, B2, B3)> traverseRecord3<E, A1, A2, A3, B1, B2, B3>(
    (A1, A2, A3) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
  ) =>
      TaskEither(() async {
        final results = await (
          f1(record.$1).run(),
          f2(record.$2).run(),
          f3(record.$3).run(),
        ).wait;
        return results.$1.flatMap((b1) =>
            results.$2.flatMap((b2) => results.$3.map((b3) => (b1, b2, b3))));
      });

  /// {@macro fpdart_traverse_record_task_either}
  static TaskEither<E, (B1, B2, B3, B4)>
      traverseRecord4<E, A1, A2, A3, A4, B1, B2, B3, B4>(
    (A1, A2, A3, A4) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
  ) =>
          TaskEither(() async {
            final results = await (
              f1(record.$1).run(),
              f2(record.$2).run(),
              f3(record.$3).run(),
              f4(record.$4).run(),
            ).wait;
            return results.$1.flatMap((b1) => results.$2.flatMap((b2) =>
                results.$3
                    .flatMap((b3) => results.$4.map((b4) => (b1, b2, b3, b4)))));
          });

  /// {@macro fpdart_traverse_record_task_either}
  static TaskEither<E, (B1, B2, B3, B4, B5)>
      traverseRecord5<E, A1, A2, A3, A4, A5, B1, B2, B3, B4, B5>(
    (A1, A2, A3, A4, A5) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
    TaskEither<E, B5> Function(A5) f5,
  ) =>
          TaskEither(() async {
            final results = await (
              f1(record.$1).run(),
              f2(record.$2).run(),
              f3(record.$3).run(),
              f4(record.$4).run(),
              f5(record.$5).run(),
            ).wait;
            return results.$1.flatMap((b1) => results.$2.flatMap((b2) =>
                results.$3.flatMap((b3) => results.$4.flatMap(
                    (b4) => results.$5.map((b5) => (b1, b2, b3, b4, b5))))));
          });

  /// {@macro fpdart_traverse_record_task_either}
  static TaskEither<E, (B1, B2, B3, B4, B5, B6)>
      traverseRecord6<E, A1, A2, A3, A4, A5, A6, B1, B2, B3, B4, B5, B6>(
    (A1, A2, A3, A4, A5, A6) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
    TaskEither<E, B5> Function(A5) f5,
    TaskEither<E, B6> Function(A6) f6,
  ) =>
          TaskEither(() async {
            final results = await (
              f1(record.$1).run(),
              f2(record.$2).run(),
              f3(record.$3).run(),
              f4(record.$4).run(),
              f5(record.$5).run(),
              f6(record.$6).run(),
            ).wait;
            return results.$1.flatMap((b1) => results.$2.flatMap((b2) =>
                results.$3.flatMap((b3) => results.$4.flatMap((b4) =>
                    results.$5.flatMap((b5) =>
                        results.$6.map((b6) => (b1, b2, b3, b4, b5, b6)))))));
          });

  /// {@macro fpdart_traverse_record_task_either}
  static TaskEither<E, (B1, B2, B3, B4, B5, B6, B7)>
      traverseRecord7<E, A1, A2, A3, A4, A5, A6, A7, B1, B2, B3, B4, B5, B6, B7>(
    (A1, A2, A3, A4, A5, A6, A7) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
    TaskEither<E, B5> Function(A5) f5,
    TaskEither<E, B6> Function(A6) f6,
    TaskEither<E, B7> Function(A7) f7,
  ) =>
          TaskEither(() async {
            final results = await (
              f1(record.$1).run(),
              f2(record.$2).run(),
              f3(record.$3).run(),
              f4(record.$4).run(),
              f5(record.$5).run(),
              f6(record.$6).run(),
              f7(record.$7).run(),
            ).wait;
            return results.$1.flatMap((b1) => results.$2.flatMap((b2) =>
                results.$3.flatMap((b3) => results.$4.flatMap((b4) =>
                    results.$5.flatMap((b5) => results.$6.flatMap((b6) =>
                        results.$7
                            .map((b7) => (b1, b2, b3, b4, b5, b6, b7))))))));
          });

  /// {@macro fpdart_traverse_record_task_either}
  static TaskEither<E, (B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseRecord8<E, A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5, B6,
              B7, B8>(
    (A1, A2, A3, A4, A5, A6, A7, A8) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
    TaskEither<E, B5> Function(A5) f5,
    TaskEither<E, B6> Function(A6) f6,
    TaskEither<E, B7> Function(A7) f7,
    TaskEither<E, B8> Function(A8) f8,
  ) =>
          TaskEither(() async {
            final results = await (
              f1(record.$1).run(),
              f2(record.$2).run(),
              f3(record.$3).run(),
              f4(record.$4).run(),
              f5(record.$5).run(),
              f6(record.$6).run(),
              f7(record.$7).run(),
              f8(record.$8).run(),
            ).wait;
            return results.$1.flatMap((b1) => results.$2.flatMap((b2) =>
                results.$3.flatMap((b3) => results.$4.flatMap((b4) =>
                    results.$5.flatMap((b5) => results.$6.flatMap((b6) =>
                        results.$7.flatMap((b7) => results.$8
                            .map((b8) => (b1, b2, b3, b4, b5, b6, b7, b8)))))))));
          });

  /// {@macro fpdart_traverse_record_task_either}
  static TaskEither<E, (B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseRecord9<E, A1, A2, A3, A4, A5, A6, A7, A8, A9, B1, B2, B3, B4, B5,
              B6, B7, B8, B9>(
    (A1, A2, A3, A4, A5, A6, A7, A8, A9) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
    TaskEither<E, B5> Function(A5) f5,
    TaskEither<E, B6> Function(A6) f6,
    TaskEither<E, B7> Function(A7) f7,
    TaskEither<E, B8> Function(A8) f8,
    TaskEither<E, B9> Function(A9) f9,
  ) =>
          TaskEither(() async {
            final results = await (
              f1(record.$1).run(),
              f2(record.$2).run(),
              f3(record.$3).run(),
              f4(record.$4).run(),
              f5(record.$5).run(),
              f6(record.$6).run(),
              f7(record.$7).run(),
              f8(record.$8).run(),
              f9(record.$9).run(),
            ).wait;
            return results.$1.flatMap((b1) => results.$2.flatMap((b2) =>
                results.$3.flatMap((b3) => results.$4.flatMap((b4) =>
                    results.$5.flatMap((b5) => results.$6.flatMap((b6) =>
                        results.$7.flatMap((b7) => results.$8.flatMap((b8) =>
                            results.$9.map((b9) =>
                                (b1, b2, b3, b4, b5, b6, b7, b8, b9))))))))));
          });

  /// {@template fpdart_sequence_record_task_either}
  /// Execute all [TaskEither] in the record in **parallel** and collect results.
  ///
  /// If any [TaskEither] returns [Left], the result is [Left] with the first error.
  ///
  /// For sequential execution, use the `Seq` variant.
  /// {@endtemplate}
  static TaskEither<E, (A, B)> sequenceRecord2<E, A, B>(
    (TaskEither<E, A>, TaskEither<E, B>) record,
  ) =>
      traverseRecord2(record, identity, identity);

  /// {@macro fpdart_sequence_record_task_either}
  static TaskEither<E, (A, B, C)> sequenceRecord3<E, A, B, C>(
    (TaskEither<E, A>, TaskEither<E, B>, TaskEither<E, C>) record,
  ) =>
      traverseRecord3(record, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_either}
  static TaskEither<E, (A, B, C, D)> sequenceRecord4<E, A, B, C, D>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>
    ) record,
  ) =>
      traverseRecord4(record, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_either}
  static TaskEither<E, (A, B, C, D, F)> sequenceRecord5<E, A, B, C, D, F>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>
    ) record,
  ) =>
      traverseRecord5(record, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_either}
  static TaskEither<E, (A, B, C, D, F, G)> sequenceRecord6<E, A, B, C, D, F, G>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>
    ) record,
  ) =>
      traverseRecord6(
          record, identity, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_either}
  static TaskEither<E, (A, B, C, D, F, G, H)>
      sequenceRecord7<E, A, B, C, D, F, G, H>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>,
      TaskEither<E, H>
    ) record,
  ) =>
          traverseRecord7(record, identity, identity, identity, identity,
              identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_either}
  static TaskEither<E, (A, B, C, D, F, G, H, I)>
      sequenceRecord8<E, A, B, C, D, F, G, H, I>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>,
      TaskEither<E, H>,
      TaskEither<E, I>
    ) record,
  ) =>
          traverseRecord8(record, identity, identity, identity, identity,
              identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_either}
  static TaskEither<E, (A, B, C, D, F, G, H, I, J)>
      sequenceRecord9<E, A, B, C, D, F, G, H, I, J>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>,
      TaskEither<E, H>,
      TaskEither<E, I>,
      TaskEither<E, J>
    ) record,
  ) =>
          traverseRecord9(record, identity, identity, identity, identity,
              identity, identity, identity, identity, identity);

  /// {@template fpdart_traverse_record_seq_task_either}
  /// Apply the provided functions to each element of the record, executing each
  /// resulting [TaskEither] in **sequence**, and collect the results in a record.
  ///
  /// For parallel execution, use the non-Seq variant.
  /// {@endtemplate}
  static TaskEither<E, (B1, B2)> traverseRecord2Seq<E, A1, A2, B1, B2>(
    (A1, A2) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
  ) =>
      f1(record.$1).flatMap((b1) => f2(record.$2).map((b2) => (b1, b2)));

  /// {@macro fpdart_traverse_record_seq_task_either}
  static TaskEither<E, (B1, B2, B3)>
      traverseRecord3Seq<E, A1, A2, A3, B1, B2, B3>(
    (A1, A2, A3) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
  ) =>
          f1(record.$1).flatMap((b1) =>
              f2(record.$2).flatMap((b2) => f3(record.$3).map((b3) => (b1, b2, b3))));

  /// {@macro fpdart_traverse_record_seq_task_either}
  static TaskEither<E, (B1, B2, B3, B4)>
      traverseRecord4Seq<E, A1, A2, A3, A4, B1, B2, B3, B4>(
    (A1, A2, A3, A4) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3)
                  .flatMap((b3) => f4(record.$4).map((b4) => (b1, b2, b3, b4)))));

  /// {@macro fpdart_traverse_record_seq_task_either}
  static TaskEither<E, (B1, B2, B3, B4, B5)>
      traverseRecord5Seq<E, A1, A2, A3, A4, A5, B1, B2, B3, B4, B5>(
    (A1, A2, A3, A4, A5) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
    TaskEither<E, B5> Function(A5) f5,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap(
                  (b4) => f5(record.$5).map((b5) => (b1, b2, b3, b4, b5))))));

  /// {@macro fpdart_traverse_record_seq_task_either}
  static TaskEither<E, (B1, B2, B3, B4, B5, B6)>
      traverseRecord6Seq<E, A1, A2, A3, A4, A5, A6, B1, B2, B3, B4, B5, B6>(
    (A1, A2, A3, A4, A5, A6) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
    TaskEither<E, B5> Function(A5) f5,
    TaskEither<E, B6> Function(A6) f6,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) =>
                      f6(record.$6).map((b6) => (b1, b2, b3, b4, b5, b6)))))));

  /// {@macro fpdart_traverse_record_seq_task_either}
  static TaskEither<E, (B1, B2, B3, B4, B5, B6, B7)>
      traverseRecord7Seq<E, A1, A2, A3, A4, A5, A6, A7, B1, B2, B3, B4, B5, B6,
              B7>(
    (A1, A2, A3, A4, A5, A6, A7) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
    TaskEither<E, B5> Function(A5) f5,
    TaskEither<E, B6> Function(A6) f6,
    TaskEither<E, B7> Function(A7) f7,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7)
                          .map((b7) => (b1, b2, b3, b4, b5, b6, b7))))))));

  /// {@macro fpdart_traverse_record_seq_task_either}
  static TaskEither<E, (B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseRecord8Seq<E, A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5,
              B6, B7, B8>(
    (A1, A2, A3, A4, A5, A6, A7, A8) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
    TaskEither<E, B5> Function(A5) f5,
    TaskEither<E, B6> Function(A6) f6,
    TaskEither<E, B7> Function(A7) f7,
    TaskEither<E, B8> Function(A8) f8,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8)
                          .map((b8) => (b1, b2, b3, b4, b5, b6, b7, b8)))))))));

  /// {@macro fpdart_traverse_record_seq_task_either}
  static TaskEither<E, (B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseRecord9Seq<E, A1, A2, A3, A4, A5, A6, A7, A8, A9, B1, B2, B3, B4,
              B5, B6, B7, B8, B9>(
    (A1, A2, A3, A4, A5, A6, A7, A8, A9) record,
    TaskEither<E, B1> Function(A1) f1,
    TaskEither<E, B2> Function(A2) f2,
    TaskEither<E, B3> Function(A3) f3,
    TaskEither<E, B4> Function(A4) f4,
    TaskEither<E, B5> Function(A5) f5,
    TaskEither<E, B6> Function(A6) f6,
    TaskEither<E, B7> Function(A7) f7,
    TaskEither<E, B8> Function(A8) f8,
    TaskEither<E, B9> Function(A9) f9,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8).flatMap((b8) =>
                          f9(record.$9).map((b9) =>
                              (b1, b2, b3, b4, b5, b6, b7, b8, b9))))))))));

  /// {@template fpdart_sequence_record_seq_task_either}
  /// Execute all [TaskEither] in the record in **sequence** and collect results.
  ///
  /// For parallel execution, use the non-Seq variant.
  /// {@endtemplate}
  static TaskEither<E, (A, B)> sequenceRecord2Seq<E, A, B>(
    (TaskEither<E, A>, TaskEither<E, B>) record,
  ) =>
      traverseRecord2Seq(record, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_either}
  static TaskEither<E, (A, B, C)> sequenceRecord3Seq<E, A, B, C>(
    (TaskEither<E, A>, TaskEither<E, B>, TaskEither<E, C>) record,
  ) =>
      traverseRecord3Seq(record, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_either}
  static TaskEither<E, (A, B, C, D)> sequenceRecord4Seq<E, A, B, C, D>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>
    ) record,
  ) =>
      traverseRecord4Seq(record, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_either}
  static TaskEither<E, (A, B, C, D, F)> sequenceRecord5Seq<E, A, B, C, D, F>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>
    ) record,
  ) =>
      traverseRecord5Seq(
          record, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_either}
  static TaskEither<E, (A, B, C, D, F, G)>
      sequenceRecord6Seq<E, A, B, C, D, F, G>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>
    ) record,
  ) =>
          traverseRecord6Seq(record, identity, identity, identity, identity,
              identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_either}
  static TaskEither<E, (A, B, C, D, F, G, H)>
      sequenceRecord7Seq<E, A, B, C, D, F, G, H>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>,
      TaskEither<E, H>
    ) record,
  ) =>
          traverseRecord7Seq(record, identity, identity, identity, identity,
              identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_either}
  static TaskEither<E, (A, B, C, D, F, G, H, I)>
      sequenceRecord8Seq<E, A, B, C, D, F, G, H, I>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>,
      TaskEither<E, H>,
      TaskEither<E, I>
    ) record,
  ) =>
          traverseRecord8Seq(record, identity, identity, identity, identity,
              identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_either}
  static TaskEither<E, (A, B, C, D, F, G, H, I, J)>
      sequenceRecord9Seq<E, A, B, C, D, F, G, H, I, J>(
    (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>,
      TaskEither<E, H>,
      TaskEither<E, I>,
      TaskEither<E, J>
    ) record,
  ) =>
          traverseRecord9Seq(record, identity, identity, identity, identity,
              identity, identity, identity, identity, identity);
}
