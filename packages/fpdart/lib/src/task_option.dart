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

part 'task_option_extension.dart';

final class _TaskOptionThrow implements Exception {
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
            (option) => option.match(
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

  /// Build a [TaskOption] from a `Task<Option<R>>`.
  factory TaskOption.fromTaskFlatten(Task<Option<R>> composedTaskOption) =>
      TaskOption(() => composedTaskOption.run());

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

  /// {@template fpdart_traverse_record_task_option}
  /// Apply the provided functions to each element of the record, executing each
  /// resulting [TaskOption] in **parallel**, and collect the results in a record.
  ///
  /// If any [TaskOption] returns [None], the result is [None].
  ///
  /// For sequential execution, use the `Seq` variant.
  /// {@endtemplate}
  static TaskOption<(B1, B2)> traverseRecord2<A1, A2, B1, B2>(
    (A1, A2) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
  ) =>
      TaskOption(() async {
        final results = await (f1(record.$1).run(), f2(record.$2).run()).wait;
        return results.$1.flatMap((b1) => results.$2.map((b2) => (b1, b2)));
      });

  /// {@macro fpdart_traverse_record_task_option}
  static TaskOption<(B1, B2, B3)> traverseRecord3<A1, A2, A3, B1, B2, B3>(
    (A1, A2, A3) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
  ) =>
      TaskOption(() async {
        final results = await (
          f1(record.$1).run(),
          f2(record.$2).run(),
          f3(record.$3).run(),
        ).wait;
        return results.$1.flatMap((b1) =>
            results.$2.flatMap((b2) => results.$3.map((b3) => (b1, b2, b3))));
      });

  /// {@macro fpdart_traverse_record_task_option}
  static TaskOption<(B1, B2, B3, B4)>
      traverseRecord4<A1, A2, A3, A4, B1, B2, B3, B4>(
    (A1, A2, A3, A4) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
  ) =>
          TaskOption(() async {
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

  /// {@macro fpdart_traverse_record_task_option}
  static TaskOption<(B1, B2, B3, B4, B5)>
      traverseRecord5<A1, A2, A3, A4, A5, B1, B2, B3, B4, B5>(
    (A1, A2, A3, A4, A5) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
    TaskOption<B5> Function(A5) f5,
  ) =>
          TaskOption(() async {
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

  /// {@macro fpdart_traverse_record_task_option}
  static TaskOption<(B1, B2, B3, B4, B5, B6)>
      traverseRecord6<A1, A2, A3, A4, A5, A6, B1, B2, B3, B4, B5, B6>(
    (A1, A2, A3, A4, A5, A6) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
    TaskOption<B5> Function(A5) f5,
    TaskOption<B6> Function(A6) f6,
  ) =>
          TaskOption(() async {
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

  /// {@macro fpdart_traverse_record_task_option}
  static TaskOption<(B1, B2, B3, B4, B5, B6, B7)>
      traverseRecord7<A1, A2, A3, A4, A5, A6, A7, B1, B2, B3, B4, B5, B6, B7>(
    (A1, A2, A3, A4, A5, A6, A7) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
    TaskOption<B5> Function(A5) f5,
    TaskOption<B6> Function(A6) f6,
    TaskOption<B7> Function(A7) f7,
  ) =>
          TaskOption(() async {
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

  /// {@macro fpdart_traverse_record_task_option}
  static TaskOption<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseRecord8<A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5, B6,
              B7, B8>(
    (A1, A2, A3, A4, A5, A6, A7, A8) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
    TaskOption<B5> Function(A5) f5,
    TaskOption<B6> Function(A6) f6,
    TaskOption<B7> Function(A7) f7,
    TaskOption<B8> Function(A8) f8,
  ) =>
          TaskOption(() async {
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

  /// {@macro fpdart_traverse_record_task_option}
  static TaskOption<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseRecord9<A1, A2, A3, A4, A5, A6, A7, A8, A9, B1, B2, B3, B4, B5,
              B6, B7, B8, B9>(
    (A1, A2, A3, A4, A5, A6, A7, A8, A9) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
    TaskOption<B5> Function(A5) f5,
    TaskOption<B6> Function(A6) f6,
    TaskOption<B7> Function(A7) f7,
    TaskOption<B8> Function(A8) f8,
    TaskOption<B9> Function(A9) f9,
  ) =>
          TaskOption(() async {
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

  /// {@template fpdart_sequence_record_task_option}
  /// Execute all [TaskOption] in the record in **parallel** and collect results.
  ///
  /// If any [TaskOption] returns [None], the result is [None].
  ///
  /// For sequential execution, use the `Seq` variant.
  /// {@endtemplate}
  static TaskOption<(A, B)> sequenceRecord2<A, B>(
    (TaskOption<A>, TaskOption<B>) record,
  ) =>
      traverseRecord2(record, identity, identity);

  /// {@macro fpdart_sequence_record_task_option}
  static TaskOption<(A, B, C)> sequenceRecord3<A, B, C>(
    (TaskOption<A>, TaskOption<B>, TaskOption<C>) record,
  ) =>
      traverseRecord3(record, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_option}
  static TaskOption<(A, B, C, D)> sequenceRecord4<A, B, C, D>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>
    ) record,
  ) =>
      traverseRecord4(record, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_option}
  static TaskOption<(A, B, C, D, F)> sequenceRecord5<A, B, C, D, F>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>
    ) record,
  ) =>
      traverseRecord5(record, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_option}
  static TaskOption<(A, B, C, D, F, G)> sequenceRecord6<A, B, C, D, F, G>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>
    ) record,
  ) =>
      traverseRecord6(
          record, identity, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_option}
  static TaskOption<(A, B, C, D, F, G, H)>
      sequenceRecord7<A, B, C, D, F, G, H>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>,
      TaskOption<H>
    ) record,
  ) =>
          traverseRecord7(record, identity, identity, identity, identity,
              identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_option}
  static TaskOption<(A, B, C, D, F, G, H, I)>
      sequenceRecord8<A, B, C, D, F, G, H, I>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>,
      TaskOption<H>,
      TaskOption<I>
    ) record,
  ) =>
          traverseRecord8(record, identity, identity, identity, identity,
              identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task_option}
  static TaskOption<(A, B, C, D, F, G, H, I, J)>
      sequenceRecord9<A, B, C, D, F, G, H, I, J>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>,
      TaskOption<H>,
      TaskOption<I>,
      TaskOption<J>
    ) record,
  ) =>
          traverseRecord9(record, identity, identity, identity, identity,
              identity, identity, identity, identity, identity);

  /// {@template fpdart_traverse_record_seq_task_option}
  /// Apply the provided functions to each element of the record, executing each
  /// resulting [TaskOption] in **sequence**, and collect the results in a record.
  ///
  /// For parallel execution, use the non-Seq variant.
  /// {@endtemplate}
  static TaskOption<(B1, B2)> traverseRecord2Seq<A1, A2, B1, B2>(
    (A1, A2) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
  ) =>
      f1(record.$1).flatMap((b1) => f2(record.$2).map((b2) => (b1, b2)));

  /// {@macro fpdart_traverse_record_seq_task_option}
  static TaskOption<(B1, B2, B3)>
      traverseRecord3Seq<A1, A2, A3, B1, B2, B3>(
    (A1, A2, A3) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
  ) =>
          f1(record.$1).flatMap((b1) =>
              f2(record.$2).flatMap((b2) => f3(record.$3).map((b3) => (b1, b2, b3))));

  /// {@macro fpdart_traverse_record_seq_task_option}
  static TaskOption<(B1, B2, B3, B4)>
      traverseRecord4Seq<A1, A2, A3, A4, B1, B2, B3, B4>(
    (A1, A2, A3, A4) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3)
                  .flatMap((b3) => f4(record.$4).map((b4) => (b1, b2, b3, b4)))));

  /// {@macro fpdart_traverse_record_seq_task_option}
  static TaskOption<(B1, B2, B3, B4, B5)>
      traverseRecord5Seq<A1, A2, A3, A4, A5, B1, B2, B3, B4, B5>(
    (A1, A2, A3, A4, A5) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
    TaskOption<B5> Function(A5) f5,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap(
                  (b4) => f5(record.$5).map((b5) => (b1, b2, b3, b4, b5))))));

  /// {@macro fpdart_traverse_record_seq_task_option}
  static TaskOption<(B1, B2, B3, B4, B5, B6)>
      traverseRecord6Seq<A1, A2, A3, A4, A5, A6, B1, B2, B3, B4, B5, B6>(
    (A1, A2, A3, A4, A5, A6) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
    TaskOption<B5> Function(A5) f5,
    TaskOption<B6> Function(A6) f6,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) =>
                      f6(record.$6).map((b6) => (b1, b2, b3, b4, b5, b6)))))));

  /// {@macro fpdart_traverse_record_seq_task_option}
  static TaskOption<(B1, B2, B3, B4, B5, B6, B7)>
      traverseRecord7Seq<A1, A2, A3, A4, A5, A6, A7, B1, B2, B3, B4, B5, B6,
              B7>(
    (A1, A2, A3, A4, A5, A6, A7) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
    TaskOption<B5> Function(A5) f5,
    TaskOption<B6> Function(A6) f6,
    TaskOption<B7> Function(A7) f7,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7)
                          .map((b7) => (b1, b2, b3, b4, b5, b6, b7))))))));

  /// {@macro fpdart_traverse_record_seq_task_option}
  static TaskOption<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseRecord8Seq<A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5,
              B6, B7, B8>(
    (A1, A2, A3, A4, A5, A6, A7, A8) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
    TaskOption<B5> Function(A5) f5,
    TaskOption<B6> Function(A6) f6,
    TaskOption<B7> Function(A7) f7,
    TaskOption<B8> Function(A8) f8,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8)
                          .map((b8) => (b1, b2, b3, b4, b5, b6, b7, b8)))))))));

  /// {@macro fpdart_traverse_record_seq_task_option}
  static TaskOption<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseRecord9Seq<A1, A2, A3, A4, A5, A6, A7, A8, A9, B1, B2, B3, B4,
              B5, B6, B7, B8, B9>(
    (A1, A2, A3, A4, A5, A6, A7, A8, A9) record,
    TaskOption<B1> Function(A1) f1,
    TaskOption<B2> Function(A2) f2,
    TaskOption<B3> Function(A3) f3,
    TaskOption<B4> Function(A4) f4,
    TaskOption<B5> Function(A5) f5,
    TaskOption<B6> Function(A6) f6,
    TaskOption<B7> Function(A7) f7,
    TaskOption<B8> Function(A8) f8,
    TaskOption<B9> Function(A9) f9,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8).flatMap((b8) =>
                          f9(record.$9).map((b9) =>
                              (b1, b2, b3, b4, b5, b6, b7, b8, b9))))))))));

  /// {@template fpdart_sequence_record_seq_task_option}
  /// Execute all [TaskOption] in the record in **sequence** and collect results.
  ///
  /// For parallel execution, use the non-Seq variant.
  /// {@endtemplate}
  static TaskOption<(A, B)> sequenceRecord2Seq<A, B>(
    (TaskOption<A>, TaskOption<B>) record,
  ) =>
      traverseRecord2Seq(record, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_option}
  static TaskOption<(A, B, C)> sequenceRecord3Seq<A, B, C>(
    (TaskOption<A>, TaskOption<B>, TaskOption<C>) record,
  ) =>
      traverseRecord3Seq(record, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_option}
  static TaskOption<(A, B, C, D)> sequenceRecord4Seq<A, B, C, D>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>
    ) record,
  ) =>
      traverseRecord4Seq(record, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_option}
  static TaskOption<(A, B, C, D, F)> sequenceRecord5Seq<A, B, C, D, F>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>
    ) record,
  ) =>
      traverseRecord5Seq(
          record, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_option}
  static TaskOption<(A, B, C, D, F, G)>
      sequenceRecord6Seq<A, B, C, D, F, G>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>
    ) record,
  ) =>
          traverseRecord6Seq(record, identity, identity, identity, identity,
              identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_option}
  static TaskOption<(A, B, C, D, F, G, H)>
      sequenceRecord7Seq<A, B, C, D, F, G, H>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>,
      TaskOption<H>
    ) record,
  ) =>
          traverseRecord7Seq(record, identity, identity, identity, identity,
              identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_option}
  static TaskOption<(A, B, C, D, F, G, H, I)>
      sequenceRecord8Seq<A, B, C, D, F, G, H, I>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>,
      TaskOption<H>,
      TaskOption<I>
    ) record,
  ) =>
          traverseRecord8Seq(record, identity, identity, identity, identity,
              identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task_option}
  static TaskOption<(A, B, C, D, F, G, H, I, J)>
      sequenceRecord9Seq<A, B, C, D, F, G, H, I, J>(
    (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>,
      TaskOption<H>,
      TaskOption<I>,
      TaskOption<J>
    ) record,
  ) =>
          traverseRecord9Seq(record, identity, identity, identity, identity,
              identity, identity, identity, identity, identity);
}
