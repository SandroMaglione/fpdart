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

part 'io_extension.dart';

typedef DoAdapterIO = A Function<A>(IO<A>);
A _doAdapter<A>(IO<A> io) => io.run();

typedef DoFunctionIO<A> = A Function(DoAdapterIO $);

/// Tag the [HKT] interface for the actual [Option].
abstract final class _IOHKT {}

/// `IO<A>` represents a **non-deterministic synchronous** computation that
/// can **cause side effects**, yields a value of type `A` and **never fails**.
///
/// If you want to represent a synchronous computation that may fail, see [IOEither].
///
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

  /// {@template fpdart_traverse_record_io}
  /// Apply the provided functions to each element of the record,
  /// and collect the results in an [IO] of a record.
  /// {@endtemplate}
  static IO<(B1, B2)> traverseRecord2<A1, A2, B1, B2>(
    (A1, A2) record,
    IO<B1> Function(A1) f1,
    IO<B2> Function(A2) f2,
  ) =>
      f1(record.$1).flatMap((b1) => f2(record.$2).map((b2) => (b1, b2)));

  /// {@macro fpdart_traverse_record_io}
  static IO<(B1, B2, B3)> traverseRecord3<A1, A2, A3, B1, B2, B3>(
    (A1, A2, A3) record,
    IO<B1> Function(A1) f1,
    IO<B2> Function(A2) f2,
    IO<B3> Function(A3) f3,
  ) =>
      f1(record.$1).flatMap((b1) =>
          f2(record.$2).flatMap((b2) => f3(record.$3).map((b3) => (b1, b2, b3))));

  /// {@macro fpdart_traverse_record_io}
  static IO<(B1, B2, B3, B4)>
      traverseRecord4<A1, A2, A3, A4, B1, B2, B3, B4>(
    (A1, A2, A3, A4) record,
    IO<B1> Function(A1) f1,
    IO<B2> Function(A2) f2,
    IO<B3> Function(A3) f3,
    IO<B4> Function(A4) f4,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3)
                  .flatMap((b3) => f4(record.$4).map((b4) => (b1, b2, b3, b4)))));

  /// {@macro fpdart_traverse_record_io}
  static IO<(B1, B2, B3, B4, B5)>
      traverseRecord5<A1, A2, A3, A4, A5, B1, B2, B3, B4, B5>(
    (A1, A2, A3, A4, A5) record,
    IO<B1> Function(A1) f1,
    IO<B2> Function(A2) f2,
    IO<B3> Function(A3) f3,
    IO<B4> Function(A4) f4,
    IO<B5> Function(A5) f5,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4)
                  .flatMap((b4) => f5(record.$5).map((b5) => (b1, b2, b3, b4, b5))))));

  /// {@macro fpdart_traverse_record_io}
  static IO<(B1, B2, B3, B4, B5, B6)>
      traverseRecord6<A1, A2, A3, A4, A5, A6, B1, B2, B3, B4, B5, B6>(
    (A1, A2, A3, A4, A5, A6) record,
    IO<B1> Function(A1) f1,
    IO<B2> Function(A2) f2,
    IO<B3> Function(A3) f3,
    IO<B4> Function(A4) f4,
    IO<B5> Function(A5) f5,
    IO<B6> Function(A6) f6,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap(
                      (b5) => f6(record.$6).map((b6) => (b1, b2, b3, b4, b5, b6)))))));

  /// {@macro fpdart_traverse_record_io}
  static IO<(B1, B2, B3, B4, B5, B6, B7)>
      traverseRecord7<A1, A2, A3, A4, A5, A6, A7, B1, B2, B3, B4, B5, B6, B7>(
    (A1, A2, A3, A4, A5, A6, A7) record,
    IO<B1> Function(A1) f1,
    IO<B2> Function(A2) f2,
    IO<B3> Function(A3) f3,
    IO<B4> Function(A4) f4,
    IO<B5> Function(A5) f5,
    IO<B6> Function(A6) f6,
    IO<B7> Function(A7) f7,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).map((b7) => (b1, b2, b3, b4, b5, b6, b7))))))));

  /// {@macro fpdart_traverse_record_io}
  static IO<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseRecord8<A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5, B6, B7,
              B8>(
    (A1, A2, A3, A4, A5, A6, A7, A8) record,
    IO<B1> Function(A1) f1,
    IO<B2> Function(A2) f2,
    IO<B3> Function(A3) f3,
    IO<B4> Function(A4) f4,
    IO<B5> Function(A5) f5,
    IO<B6> Function(A6) f6,
    IO<B7> Function(A7) f7,
    IO<B8> Function(A8) f8,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8)
                          .map((b8) => (b1, b2, b3, b4, b5, b6, b7, b8)))))))));

  /// {@macro fpdart_traverse_record_io}
  static IO<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseRecord9<A1, A2, A3, A4, A5, A6, A7, A8, A9, B1, B2, B3, B4, B5, B6,
              B7, B8, B9>(
    (A1, A2, A3, A4, A5, A6, A7, A8, A9) record,
    IO<B1> Function(A1) f1,
    IO<B2> Function(A2) f2,
    IO<B3> Function(A3) f3,
    IO<B4> Function(A4) f4,
    IO<B5> Function(A5) f5,
    IO<B6> Function(A6) f6,
    IO<B7> Function(A7) f7,
    IO<B8> Function(A8) f8,
    IO<B9> Function(A9) f9,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8).flatMap((b8) =>
                          f9(record.$9)
                              .map((b9) => (b1, b2, b3, b4, b5, b6, b7, b8, b9))))))))));

  /// {@template fpdart_sequence_record_io}
  /// Combine all [IO] in the record and collect results.
  /// {@endtemplate}
  static IO<(A, B)> sequenceRecord2<A, B>(
    (IO<A>, IO<B>) record,
  ) =>
      traverseRecord2(record, identity, identity);

  /// {@macro fpdart_sequence_record_io}
  static IO<(A, B, C)> sequenceRecord3<A, B, C>(
    (IO<A>, IO<B>, IO<C>) record,
  ) =>
      traverseRecord3(record, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io}
  static IO<(A, B, C, D)> sequenceRecord4<A, B, C, D>(
    (IO<A>, IO<B>, IO<C>, IO<D>) record,
  ) =>
      traverseRecord4(record, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io}
  static IO<(A, B, C, D, F)> sequenceRecord5<A, B, C, D, F>(
    (IO<A>, IO<B>, IO<C>, IO<D>, IO<F>) record,
  ) =>
      traverseRecord5(record, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io}
  static IO<(A, B, C, D, F, G)> sequenceRecord6<A, B, C, D, F, G>(
    (IO<A>, IO<B>, IO<C>, IO<D>, IO<F>, IO<G>) record,
  ) =>
      traverseRecord6(
          record, identity, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io}
  static IO<(A, B, C, D, F, G, H)> sequenceRecord7<A, B, C, D, F, G, H>(
    (
      IO<A>,
      IO<B>,
      IO<C>,
      IO<D>,
      IO<F>,
      IO<G>,
      IO<H>
    ) record,
  ) =>
      traverseRecord7(record, identity, identity, identity, identity, identity,
          identity, identity);

  /// {@macro fpdart_sequence_record_io}
  static IO<(A, B, C, D, F, G, H, I)> sequenceRecord8<A, B, C, D, F, G, H, I>(
    (
      IO<A>,
      IO<B>,
      IO<C>,
      IO<D>,
      IO<F>,
      IO<G>,
      IO<H>,
      IO<I>
    ) record,
  ) =>
      traverseRecord8(record, identity, identity, identity, identity, identity,
          identity, identity, identity);

  /// {@macro fpdart_sequence_record_io}
  static IO<(A, B, C, D, F, G, H, I, J)>
      sequenceRecord9<A, B, C, D, F, G, H, I, J>(
    (
      IO<A>,
      IO<B>,
      IO<C>,
      IO<D>,
      IO<F>,
      IO<G>,
      IO<H>,
      IO<I>,
      IO<J>
    ) record,
  ) =>
          traverseRecord9(record, identity, identity, identity, identity,
              identity, identity, identity, identity, identity);

  @override
  bool operator ==(Object other) => (other is IO) && other._run == _run;

  @override
  int get hashCode => _run.hashCode;
}
