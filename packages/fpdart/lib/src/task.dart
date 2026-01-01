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

part 'task_extension.dart';

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
        final collect = <B>[];
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

  /// {@template fpdart_traverse_record_task}
  /// Apply the provided functions to each element of the record, executing each
  /// resulting [Task] in **parallel**, and collect the results in a record.
  ///
  /// For sequential execution, use the `Seq` variant.
  /// {@endtemplate}
  static Task<(B1, B2)> traverseRecord2<A1, A2, B1, B2>(
    (A1, A2) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
  ) =>
      Task(() async {
        final results = await (f1(record.$1).run(), f2(record.$2).run()).wait;
        return (results.$1, results.$2);
      });

  /// {@macro fpdart_traverse_record_task}
  static Task<(B1, B2, B3)> traverseRecord3<A1, A2, A3, B1, B2, B3>(
    (A1, A2, A3) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
  ) =>
      Task(() async {
        final results = await (
          f1(record.$1).run(),
          f2(record.$2).run(),
          f3(record.$3).run(),
        ).wait;
        return (results.$1, results.$2, results.$3);
      });

  /// {@macro fpdart_traverse_record_task}
  static Task<(B1, B2, B3, B4)> traverseRecord4<A1, A2, A3, A4, B1, B2, B3, B4>(
    (A1, A2, A3, A4) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
  ) =>
      Task(() async {
        final results = await (
          f1(record.$1).run(),
          f2(record.$2).run(),
          f3(record.$3).run(),
          f4(record.$4).run(),
        ).wait;
        return (results.$1, results.$2, results.$3, results.$4);
      });

  /// {@macro fpdart_traverse_record_task}
  static Task<(B1, B2, B3, B4, B5)>
      traverseRecord5<A1, A2, A3, A4, A5, B1, B2, B3, B4, B5>(
    (A1, A2, A3, A4, A5) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
    Task<B5> Function(A5) f5,
  ) =>
          Task(() async {
            final results = await (
              f1(record.$1).run(),
              f2(record.$2).run(),
              f3(record.$3).run(),
              f4(record.$4).run(),
              f5(record.$5).run(),
            ).wait;
            return (results.$1, results.$2, results.$3, results.$4, results.$5);
          });

  /// {@macro fpdart_traverse_record_task}
  static Task<(B1, B2, B3, B4, B5, B6)>
      traverseRecord6<A1, A2, A3, A4, A5, A6, B1, B2, B3, B4, B5, B6>(
    (A1, A2, A3, A4, A5, A6) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
    Task<B5> Function(A5) f5,
    Task<B6> Function(A6) f6,
  ) =>
          Task(() async {
            final results = await (
              f1(record.$1).run(),
              f2(record.$2).run(),
              f3(record.$3).run(),
              f4(record.$4).run(),
              f5(record.$5).run(),
              f6(record.$6).run(),
            ).wait;
            return (results.$1, results.$2, results.$3, results.$4, results.$5,
                results.$6);
          });

  /// {@macro fpdart_traverse_record_task}
  static Task<(B1, B2, B3, B4, B5, B6, B7)>
      traverseRecord7<A1, A2, A3, A4, A5, A6, A7, B1, B2, B3, B4, B5, B6, B7>(
    (A1, A2, A3, A4, A5, A6, A7) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
    Task<B5> Function(A5) f5,
    Task<B6> Function(A6) f6,
    Task<B7> Function(A7) f7,
  ) =>
          Task(() async {
            final results = await (
              f1(record.$1).run(),
              f2(record.$2).run(),
              f3(record.$3).run(),
              f4(record.$4).run(),
              f5(record.$5).run(),
              f6(record.$6).run(),
              f7(record.$7).run(),
            ).wait;
            return (results.$1, results.$2, results.$3, results.$4, results.$5,
                results.$6, results.$7);
          });

  /// {@macro fpdart_traverse_record_task}
  static Task<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseRecord8<A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5, B6, B7,
              B8>(
    (A1, A2, A3, A4, A5, A6, A7, A8) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
    Task<B5> Function(A5) f5,
    Task<B6> Function(A6) f6,
    Task<B7> Function(A7) f7,
    Task<B8> Function(A8) f8,
  ) =>
          Task(() async {
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
            return (results.$1, results.$2, results.$3, results.$4, results.$5,
                results.$6, results.$7, results.$8);
          });

  /// {@macro fpdart_traverse_record_task}
  static Task<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseRecord9<A1, A2, A3, A4, A5, A6, A7, A8, A9, B1, B2, B3, B4, B5, B6,
              B7, B8, B9>(
    (A1, A2, A3, A4, A5, A6, A7, A8, A9) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
    Task<B5> Function(A5) f5,
    Task<B6> Function(A6) f6,
    Task<B7> Function(A7) f7,
    Task<B8> Function(A8) f8,
    Task<B9> Function(A9) f9,
  ) =>
          Task(() async {
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
            return (results.$1, results.$2, results.$3, results.$4, results.$5,
                results.$6, results.$7, results.$8, results.$9);
          });

  /// {@template fpdart_sequence_record_task}
  /// Execute all [Task] in the record in **parallel** and collect results.
  ///
  /// For sequential execution, use the `Seq` variant.
  /// {@endtemplate}
  static Task<(A, B)> sequenceRecord2<A, B>(
    (Task<A>, Task<B>) record,
  ) =>
      traverseRecord2(record, identity, identity);

  /// {@macro fpdart_sequence_record_task}
  static Task<(A, B, C)> sequenceRecord3<A, B, C>(
    (Task<A>, Task<B>, Task<C>) record,
  ) =>
      traverseRecord3(record, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task}
  static Task<(A, B, C, D)> sequenceRecord4<A, B, C, D>(
    (Task<A>, Task<B>, Task<C>, Task<D>) record,
  ) =>
      traverseRecord4(record, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task}
  static Task<(A, B, C, D, F)> sequenceRecord5<A, B, C, D, F>(
    (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>) record,
  ) =>
      traverseRecord5(record, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task}
  static Task<(A, B, C, D, F, G)> sequenceRecord6<A, B, C, D, F, G>(
    (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>, Task<G>) record,
  ) =>
      traverseRecord6(
          record, identity, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_task}
  static Task<(A, B, C, D, F, G, H)> sequenceRecord7<A, B, C, D, F, G, H>(
    (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>, Task<G>, Task<H>) record,
  ) =>
      traverseRecord7(record, identity, identity, identity, identity, identity,
          identity, identity);

  /// {@macro fpdart_sequence_record_task}
  static Task<(A, B, C, D, F, G, H, I)> sequenceRecord8<A, B, C, D, F, G, H, I>(
    (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>, Task<G>, Task<H>, Task<I>)
        record,
  ) =>
      traverseRecord8(record, identity, identity, identity, identity, identity,
          identity, identity, identity);

  /// {@macro fpdart_sequence_record_task}
  static Task<(A, B, C, D, F, G, H, I, J)>
      sequenceRecord9<A, B, C, D, F, G, H, I, J>(
    (
      Task<A>,
      Task<B>,
      Task<C>,
      Task<D>,
      Task<F>,
      Task<G>,
      Task<H>,
      Task<I>,
      Task<J>
    ) record,
  ) =>
          traverseRecord9(record, identity, identity, identity, identity,
              identity, identity, identity, identity, identity);

  /// {@template fpdart_traverse_record_seq_task}
  /// Apply the provided functions to each element of the record, executing each
  /// resulting [Task] in **sequence**, and collect the results in a record.
  ///
  /// For parallel execution, use the non-Seq variant.
  /// {@endtemplate}
  static Task<(B1, B2)> traverseRecord2Seq<A1, A2, B1, B2>(
    (A1, A2) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
  ) =>
      f1(record.$1).flatMap((b1) => f2(record.$2).map((b2) => (b1, b2)));

  /// {@macro fpdart_traverse_record_seq_task}
  static Task<(B1, B2, B3)> traverseRecord3Seq<A1, A2, A3, B1, B2, B3>(
    (A1, A2, A3) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
  ) =>
      f1(record.$1).flatMap((b1) =>
          f2(record.$2).flatMap((b2) => f3(record.$3).map((b3) => (b1, b2, b3))));

  /// {@macro fpdart_traverse_record_seq_task}
  static Task<(B1, B2, B3, B4)> traverseRecord4Seq<A1, A2, A3, A4, B1, B2, B3, B4>(
    (A1, A2, A3, A4) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
  ) =>
      f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
          f3(record.$3).flatMap((b3) => f4(record.$4).map((b4) => (b1, b2, b3, b4)))));

  /// {@macro fpdart_traverse_record_seq_task}
  static Task<(B1, B2, B3, B4, B5)>
      traverseRecord5Seq<A1, A2, A3, A4, A5, B1, B2, B3, B4, B5>(
    (A1, A2, A3, A4, A5) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
    Task<B5> Function(A5) f5,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4)
                  .flatMap((b4) => f5(record.$5).map((b5) => (b1, b2, b3, b4, b5))))));

  /// {@macro fpdart_traverse_record_seq_task}
  static Task<(B1, B2, B3, B4, B5, B6)>
      traverseRecord6Seq<A1, A2, A3, A4, A5, A6, B1, B2, B3, B4, B5, B6>(
    (A1, A2, A3, A4, A5, A6) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
    Task<B5> Function(A5) f5,
    Task<B6> Function(A6) f6,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap(
                      (b5) => f6(record.$6).map((b6) => (b1, b2, b3, b4, b5, b6)))))));

  /// {@macro fpdart_traverse_record_seq_task}
  static Task<(B1, B2, B3, B4, B5, B6, B7)>
      traverseRecord7Seq<A1, A2, A3, A4, A5, A6, A7, B1, B2, B3, B4, B5, B6, B7>(
    (A1, A2, A3, A4, A5, A6, A7) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
    Task<B5> Function(A5) f5,
    Task<B6> Function(A6) f6,
    Task<B7> Function(A7) f7,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).map((b7) => (b1, b2, b3, b4, b5, b6, b7))))))));

  /// {@macro fpdart_traverse_record_seq_task}
  static Task<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseRecord8Seq<A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5, B6,
              B7, B8>(
    (A1, A2, A3, A4, A5, A6, A7, A8) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
    Task<B5> Function(A5) f5,
    Task<B6> Function(A6) f6,
    Task<B7> Function(A7) f7,
    Task<B8> Function(A8) f8,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8)
                          .map((b8) => (b1, b2, b3, b4, b5, b6, b7, b8)))))))));

  /// {@macro fpdart_traverse_record_seq_task}
  static Task<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseRecord9Seq<A1, A2, A3, A4, A5, A6, A7, A8, A9, B1, B2, B3, B4, B5,
              B6, B7, B8, B9>(
    (A1, A2, A3, A4, A5, A6, A7, A8, A9) record,
    Task<B1> Function(A1) f1,
    Task<B2> Function(A2) f2,
    Task<B3> Function(A3) f3,
    Task<B4> Function(A4) f4,
    Task<B5> Function(A5) f5,
    Task<B6> Function(A6) f6,
    Task<B7> Function(A7) f7,
    Task<B8> Function(A8) f8,
    Task<B9> Function(A9) f9,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8).flatMap((b8) =>
                          f9(record.$9)
                              .map((b9) => (b1, b2, b3, b4, b5, b6, b7, b8, b9))))))))));

  /// {@template fpdart_sequence_record_seq_task}
  /// Execute all [Task] in the record in **sequence** and collect results.
  ///
  /// For parallel execution, use the non-Seq variant.
  /// {@endtemplate}
  static Task<(A, B)> sequenceRecord2Seq<A, B>(
    (Task<A>, Task<B>) record,
  ) =>
      traverseRecord2Seq(record, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task}
  static Task<(A, B, C)> sequenceRecord3Seq<A, B, C>(
    (Task<A>, Task<B>, Task<C>) record,
  ) =>
      traverseRecord3Seq(record, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task}
  static Task<(A, B, C, D)> sequenceRecord4Seq<A, B, C, D>(
    (Task<A>, Task<B>, Task<C>, Task<D>) record,
  ) =>
      traverseRecord4Seq(record, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task}
  static Task<(A, B, C, D, F)> sequenceRecord5Seq<A, B, C, D, F>(
    (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>) record,
  ) =>
      traverseRecord5Seq(
          record, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task}
  static Task<(A, B, C, D, F, G)> sequenceRecord6Seq<A, B, C, D, F, G>(
    (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>, Task<G>) record,
  ) =>
      traverseRecord6Seq(record, identity, identity, identity, identity,
          identity, identity);

  /// {@macro fpdart_sequence_record_seq_task}
  static Task<(A, B, C, D, F, G, H)> sequenceRecord7Seq<A, B, C, D, F, G, H>(
    (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>, Task<G>, Task<H>) record,
  ) =>
      traverseRecord7Seq(record, identity, identity, identity, identity,
          identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task}
  static Task<(A, B, C, D, F, G, H, I)>
      sequenceRecord8Seq<A, B, C, D, F, G, H, I>(
    (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>, Task<G>, Task<H>, Task<I>)
        record,
  ) =>
          traverseRecord8Seq(record, identity, identity, identity, identity,
              identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_seq_task}
  static Task<(A, B, C, D, F, G, H, I, J)>
      sequenceRecord9Seq<A, B, C, D, F, G, H, I, J>(
    (
      Task<A>,
      Task<B>,
      Task<C>,
      Task<D>,
      Task<F>,
      Task<G>,
      Task<H>,
      Task<I>,
      Task<J>
    ) record,
  ) =>
          traverseRecord9Seq(record, identity, identity, identity, identity,
              identity, identity, identity, identity, identity);
}
