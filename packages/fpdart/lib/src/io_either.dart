import 'either.dart';
import 'function.dart';
import 'io.dart';
import 'option.dart';
import 'task_either.dart';
import 'typeclass/alt.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

part 'io_either_extension.dart';

final class _IOEitherThrow<L> implements Exception {
  final L value;
  const _IOEitherThrow(this.value);
}

typedef DoAdapterIOEither<E> = A Function<A>(IOEither<E, A>);
DoAdapterIOEither<L> _doAdapter<L>() =>
    <A>(ioEither) => ioEither.run().getOrElse((l) => throw _IOEitherThrow(l));

typedef DoFunctionIOEither<L, A> = A Function(DoAdapterIOEither<L> $);

/// Tag the [HKT2] interface for the actual [IOEither].
abstract final class _IOEitherHKT {}

/// `IOEither<L, R>` represents a **non-deterministic synchronous** computation that
/// can **cause side effects**, yields a value of type `R` or **can fail** by returning
/// a value of type `L`.
///
/// If you want to represent a synchronous computation that may never fail, see [IO].
final class IOEither<L, R> extends HKT2<_IOEitherHKT, L, R>
    with
        Functor2<_IOEitherHKT, L, R>,
        Applicative2<_IOEitherHKT, L, R>,
        Monad2<_IOEitherHKT, L, R>,
        Alt2<_IOEitherHKT, L, R> {
  final Either<L, R> Function() _run;

  /// Build an instance of [IOEither] from `Either<L, R> Function()`.
  const IOEither(this._run);

  /// Initialize a **Do Notation** chain.
  // ignore: non_constant_identifier_names
  factory IOEither.Do(DoFunctionIOEither<L, R> f) => IOEither(() {
        try {
          return Either.of(f(_doAdapter<L>()));
        } on _IOEitherThrow<L> catch (e) {
          return Either.left(e.value);
        }
      });

  /// Used to chain multiple functions that return a [IOEither].
  ///
  /// You can extract the value of every [Right] in the chain without
  /// handling all possible missing cases.
  /// If running any of the IOs in the chain returns [Left], the result is [Left].
  @override
  IOEither<L, C> flatMap<C>(covariant IOEither<L, C> Function(R r) f) =>
      IOEither(
        () => run().match(
          Either.left,
          (r) => f(r).run(),
        ),
      );

  /// Chain a [TaskEither] with an [IOEither].
  ///
  /// Allows to chain a function that returns a `Either<L, R>` ([IOEither]) to
  /// a function that returns a `Future<Either<L, C>>` ([TaskEither]).
  TaskEither<L, C> flatMapTask<C>(TaskEither<L, C> Function(R r) f) =>
      TaskEither(
        () async => run().match(
          Either.left,
          (r) => f(r).run(),
        ),
      );

  /// Convert this [IOEither] to [TaskEither].
  TaskEither<L, R> toTaskEither() => TaskEither(() async => run());

  /// Returns a [IOEither] that returns a `Right(a)`.
  @override
  IOEither<L, C> pure<C>(C a) => IOEither(() => Right(a));

  /// Change the return type of this [IOEither] based on its value of type `R` and the
  /// value of type `C` of another [IOEither].
  @override
  IOEither<L, D> map2<C, D>(
          covariant IOEither<L, C> m1, D Function(R b, C c) f) =>
      flatMap((b) => m1.map((c) => f(b, c)));

  /// Change the return type of this [IOEither] based on its value of type `R`, the
  /// value of type `C` of a second [IOEither], and the value of type `D`
  /// of a third [IOEither].
  @override
  IOEither<L, E> map3<C, D, E>(covariant IOEither<L, C> m1,
          covariant IOEither<L, D> m2, E Function(R b, C c, D d) f) =>
      flatMap((b) => m1.flatMap((c) => m2.map((d) => f(b, c, d))));

  /// If running this [IOEither] returns [Right], then return the result of calling `then`.
  /// Otherwise return [Left].
  @override
  IOEither<L, C> andThen<C>(covariant IOEither<L, C> Function() then) =>
      flatMap((_) => then());

  /// If running this [IOEither] returns [Right], then change its value from type `R` to
  /// type `C` using function `f`.
  @override
  IOEither<L, C> map<C>(C Function(R r) f) => ap(pure(f));

  /// Change the value in the [Left] of [IOEither].
  IOEither<C, R> mapLeft<C>(C Function(L l) f) => IOEither(
        () => run().match((l) => Either.left(f(l)), Either.of),
      );

  /// Define two functions to change both the [Left] and [Right] value of the
  /// [IOEither].
  ///
  /// {@macro fpdart_bimap_either}
  IOEither<C, D> bimap<C, D>(C Function(L a) mLeft, D Function(R b) mRight) =>
      mapLeft(mLeft).map(mRight);

  /// Apply the function contained inside `a` to change the value on the [Right] from
  /// type `R` to a value of type `C`.
  @override
  IOEither<L, C> ap<C>(covariant IOEither<L, C Function(R r)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  /// Change this [IOEither] from `IOEither<L, R>` to `IOEither<R, L>`.
  IOEither<R, L> swap() => IOEither(() => run().match(Right.new, Left.new));

  /// When this [IOEither] returns [Right], then return the current [IOEither].
  /// Otherwise return the result of `orElse`.
  ///
  /// Used to provide an **alt**ernative [IOEither] in case the current one returns [Left].
  @override
  IOEither<L, R> alt(covariant IOEither<L, R> Function() orElse) =>
      IOEither(() => run().match((_) => orElse().run(), right));

  /// Chain multiple functions having the same left type `L`.
  @override
  IOEither<L, C> call<C>(covariant IOEither<L, C> chain) =>
      flatMap((_) => chain);

  /// If `f` applied on this [IOEither] as [Right] returns `true`, then return this [IOEither].
  /// If it returns `false`, return the result of `onFalse` in a [Left].
  IOEither<L, R> filterOrElse(bool Function(R r) f, L Function(R r) onFalse) =>
      flatMap((r) => f(r) ? IOEither.of(r) : IOEither.left(onFalse(r)));

  /// When this [IOEither] returns a [Left] then return the result of `orElse`.
  /// Otherwise return this [IOEither].
  IOEither<TL, R> orElse<TL>(IOEither<TL, R> Function(L l) orElse) =>
      IOEither(() => run().match(
          (l) => orElse(l).run(), (r) => IOEither<TL, R>.right(r).run()));

  /// Convert this [IOEither] to a [IO].
  ///
  /// The IO returns a [Right] when [IOEither] returns [Right].
  /// Otherwise map the type `L` of [IOEither] to type `R` by calling `orElse`.
  IO<R> getOrElse(R Function(L l) orElse) =>
      IO(() => run().match(orElse, identity));

  /// Pattern matching to convert a [IOEither] to a [IO].
  ///
  /// Execute `onLeft` when running this [IOEither] returns a [Left].
  /// Otherwise execute `onRight`.
  IO<A> match<A>(A Function(L l) onLeft, A Function(R r) onRight) =>
      IO(() => run().match(onLeft, onRight));

  /// Chain a request that returns another [IOEither], execute it, ignore
  /// the result, and return the same value as the current [IOEither].
  @override
  IOEither<L, R> chainFirst<C>(
    covariant IOEither<L, C> Function(R b) chain,
  ) =>
      flatMap((b) => chain(b).map((c) => b).orElse((l) => IOEither.right(b)));

  /// Run the IO and return a `Either<L, R>`.
  Either<L, R> run() => _run();

  /// Build a [IOEither] that returns a `Right(r)`.
  ///
  /// Same of `IOEither.right`.
  factory IOEither.of(R r) => IOEither(() => Either.of(r));

  /// Flat a [IOEither] contained inside another [IOEither] to be a single [IOEither].
  factory IOEither.flatten(IOEither<L, IOEither<L, R>> ioEither) =>
      ioEither.flatMap(identity);

  /// Build a [IOEither] that returns a `Right(right)`.
  ///
  /// Same of `IOEither.of`.
  factory IOEither.right(R right) => IOEither(() => Either.of(right));

  /// Build a [IOEither] that returns a `Left(left)`.
  factory IOEither.left(L left) => IOEither(() => Left(left));

  /// Build a [IOEither] that returns a [Left] containing the result of running `io`.
  factory IOEither.leftIO(IO<L> io) => IOEither(() => Either.left(io.run()));

  /// Build a [IOEither] that returns a [Right] containing the result of running `io`.
  ///
  /// Same of `IOEither.fromIO`
  factory IOEither.rightIO(IO<R> io) => IOEither(() => Right(io.run()));

  /// Build a [IOEither] from the result of running `io`.
  ///
  /// Same of `IOEither.rightIO`
  factory IOEither.fromIO(IO<R> io) => IOEither(() => Right(io.run()));

  /// When calling `predicate` with `value` returns `true`, then running [IOEither] returns `Right(value)`.
  /// Otherwise return `onFalse`.
  factory IOEither.fromPredicate(
          R value, bool Function(R a) predicate, L Function(R a) onFalse) =>
      IOEither(() => predicate(value) ? Right(value) : Left(onFalse(value)));

  /// Build a [IOEither] from `option`.
  ///
  /// When `option` is [Some], then return [Right] when
  /// running [IOEither]. Otherwise return `onNone`.
  factory IOEither.fromOption(Option<R> option, L Function() onNone) =>
      IOEither(() => option.match(
            () => Left(onNone()),
            Right.new,
          ));

  /// Build a [IOEither] that returns `either`.
  factory IOEither.fromEither(Either<L, R> either) => IOEither(() => either);

  /// If `r` is `null`, then return the result of `onNull` in [Left].
  /// Otherwise return `Right(r)`.
  factory IOEither.fromNullable(R? r, L Function() onNull) =>
      Either.fromNullable(r, onNull).toIOEither();

  /// Converts a [Function] that may throw to a [Function] that never throws
  /// but returns a [Either] instead.
  ///
  /// Used to handle asynchronous computations that may throw using [Either].
  factory IOEither.tryCatch(R Function() run,
          L Function(Object error, StackTrace stackTrace) onError) =>
      IOEither<L, R>(() {
        try {
          return Right<L, R>(run());
        } catch (error, stack) {
          return Left<L, R>(onError(error, stack));
        }
      });

  /// {@template fpdart_traverse_list_io_either}
  /// Map each element in the list to a [IOEither] using the function `f`,
  /// and collect the result in an `IOEither<E, List<B>>`.
  /// {@endtemplate}
  ///
  /// Same as `IOEither.traverseList` but passing `index` in the map function.
  static IOEither<E, List<B>> traverseListWithIndex<E, A, B>(
    List<A> list,
    IOEither<E, B> Function(A a, int i) f,
  ) =>
      IOEither<E, List<B>>(
        () => Either.sequenceList(
          IO
              .traverseListWithIndex<A, Either<E, B>>(
                list,
                (a, i) => IO(() => f(a, i).run()),
              )
              .run(),
        ),
      );

  /// {@macro fpdart_traverse_list_io_either}
  ///
  /// Same as `IOEither.traverseListWithIndex` but without `index` in the map function.
  static IOEither<E, List<B>> traverseList<E, A, B>(
    List<A> list,
    IOEither<E, B> Function(A a) f,
  ) =>
      traverseListWithIndex<E, A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_io_either}
  /// Convert a `List<IOEither<E, A>>` to a single `IOEither<E, List<A>>`.
  /// {@endtemplate}
  static IOEither<E, List<A>> sequenceList<E, A>(
    List<IOEither<E, A>> list,
  ) =>
      traverseList(list, identity);

  /// {@template fpdart_traverse_record_io_either}
  /// Apply the provided functions to each element of the record and collect
  /// the results in an [IOEither] containing a record.
  ///
  /// If any [IOEither] returns [Left], the result is [Left] with the first
  /// error encountered.
  /// {@endtemplate}
  static IOEither<E, (B1, B2)> traverseRecord2<E, A1, A2, B1, B2>(
    (A1, A2) record,
    IOEither<E, B1> Function(A1) f1,
    IOEither<E, B2> Function(A2) f2,
  ) =>
      f1(record.$1).flatMap((b1) => f2(record.$2).map((b2) => (b1, b2)));

  /// {@macro fpdart_traverse_record_io_either}
  static IOEither<E, (B1, B2, B3)> traverseRecord3<E, A1, A2, A3, B1, B2, B3>(
    (A1, A2, A3) record,
    IOEither<E, B1> Function(A1) f1,
    IOEither<E, B2> Function(A2) f2,
    IOEither<E, B3> Function(A3) f3,
  ) =>
      f1(record.$1).flatMap((b1) =>
          f2(record.$2).flatMap((b2) => f3(record.$3).map((b3) => (b1, b2, b3))));

  /// {@macro fpdart_traverse_record_io_either}
  static IOEither<E, (B1, B2, B3, B4)>
      traverseRecord4<E, A1, A2, A3, A4, B1, B2, B3, B4>(
    (A1, A2, A3, A4) record,
    IOEither<E, B1> Function(A1) f1,
    IOEither<E, B2> Function(A2) f2,
    IOEither<E, B3> Function(A3) f3,
    IOEither<E, B4> Function(A4) f4,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3)
                  .flatMap((b3) => f4(record.$4).map((b4) => (b1, b2, b3, b4)))));

  /// {@macro fpdart_traverse_record_io_either}
  static IOEither<E, (B1, B2, B3, B4, B5)>
      traverseRecord5<E, A1, A2, A3, A4, A5, B1, B2, B3, B4, B5>(
    (A1, A2, A3, A4, A5) record,
    IOEither<E, B1> Function(A1) f1,
    IOEither<E, B2> Function(A2) f2,
    IOEither<E, B3> Function(A3) f3,
    IOEither<E, B4> Function(A4) f4,
    IOEither<E, B5> Function(A5) f5,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap(
                  (b4) => f5(record.$5).map((b5) => (b1, b2, b3, b4, b5))))));

  /// {@macro fpdart_traverse_record_io_either}
  static IOEither<E, (B1, B2, B3, B4, B5, B6)>
      traverseRecord6<E, A1, A2, A3, A4, A5, A6, B1, B2, B3, B4, B5, B6>(
    (A1, A2, A3, A4, A5, A6) record,
    IOEither<E, B1> Function(A1) f1,
    IOEither<E, B2> Function(A2) f2,
    IOEither<E, B3> Function(A3) f3,
    IOEither<E, B4> Function(A4) f4,
    IOEither<E, B5> Function(A5) f5,
    IOEither<E, B6> Function(A6) f6,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) =>
                      f6(record.$6).map((b6) => (b1, b2, b3, b4, b5, b6)))))));

  /// {@macro fpdart_traverse_record_io_either}
  static IOEither<E, (B1, B2, B3, B4, B5, B6, B7)>
      traverseRecord7<E, A1, A2, A3, A4, A5, A6, A7, B1, B2, B3, B4, B5, B6, B7>(
    (A1, A2, A3, A4, A5, A6, A7) record,
    IOEither<E, B1> Function(A1) f1,
    IOEither<E, B2> Function(A2) f2,
    IOEither<E, B3> Function(A3) f3,
    IOEither<E, B4> Function(A4) f4,
    IOEither<E, B5> Function(A5) f5,
    IOEither<E, B6> Function(A6) f6,
    IOEither<E, B7> Function(A7) f7,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7)
                          .map((b7) => (b1, b2, b3, b4, b5, b6, b7))))))));

  /// {@macro fpdart_traverse_record_io_either}
  static IOEither<E, (B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseRecord8<E, A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5, B6,
              B7, B8>(
    (A1, A2, A3, A4, A5, A6, A7, A8) record,
    IOEither<E, B1> Function(A1) f1,
    IOEither<E, B2> Function(A2) f2,
    IOEither<E, B3> Function(A3) f3,
    IOEither<E, B4> Function(A4) f4,
    IOEither<E, B5> Function(A5) f5,
    IOEither<E, B6> Function(A6) f6,
    IOEither<E, B7> Function(A7) f7,
    IOEither<E, B8> Function(A8) f8,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8)
                          .map((b8) => (b1, b2, b3, b4, b5, b6, b7, b8)))))))));

  /// {@macro fpdart_traverse_record_io_either}
  static IOEither<E, (B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseRecord9<E, A1, A2, A3, A4, A5, A6, A7, A8, A9, B1, B2, B3, B4, B5,
              B6, B7, B8, B9>(
    (A1, A2, A3, A4, A5, A6, A7, A8, A9) record,
    IOEither<E, B1> Function(A1) f1,
    IOEither<E, B2> Function(A2) f2,
    IOEither<E, B3> Function(A3) f3,
    IOEither<E, B4> Function(A4) f4,
    IOEither<E, B5> Function(A5) f5,
    IOEither<E, B6> Function(A6) f6,
    IOEither<E, B7> Function(A7) f7,
    IOEither<E, B8> Function(A8) f8,
    IOEither<E, B9> Function(A9) f9,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8).flatMap((b8) =>
                          f9(record.$9).map((b9) =>
                              (b1, b2, b3, b4, b5, b6, b7, b8, b9))))))))));

  /// {@template fpdart_sequence_record_io_either}
  /// Collect all [IOEither] values in the record and combine their results.
  ///
  /// If any [IOEither] is [Left], the result is [Left] with the first error.
  /// {@endtemplate}
  static IOEither<E, (A, B)> sequenceRecord2<E, A, B>(
    (IOEither<E, A>, IOEither<E, B>) record,
  ) =>
      traverseRecord2(record, identity, identity);

  /// {@macro fpdart_sequence_record_io_either}
  static IOEither<E, (A, B, C)> sequenceRecord3<E, A, B, C>(
    (IOEither<E, A>, IOEither<E, B>, IOEither<E, C>) record,
  ) =>
      traverseRecord3(record, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_either}
  static IOEither<E, (A, B, C, D)> sequenceRecord4<E, A, B, C, D>(
    (IOEither<E, A>, IOEither<E, B>, IOEither<E, C>, IOEither<E, D>) record,
  ) =>
      traverseRecord4(record, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_either}
  static IOEither<E, (A, B, C, D, F)> sequenceRecord5<E, A, B, C, D, F>(
    (
      IOEither<E, A>,
      IOEither<E, B>,
      IOEither<E, C>,
      IOEither<E, D>,
      IOEither<E, F>
    ) record,
  ) =>
      traverseRecord5(record, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_either}
  static IOEither<E, (A, B, C, D, F, G)> sequenceRecord6<E, A, B, C, D, F, G>(
    (
      IOEither<E, A>,
      IOEither<E, B>,
      IOEither<E, C>,
      IOEither<E, D>,
      IOEither<E, F>,
      IOEither<E, G>
    ) record,
  ) =>
      traverseRecord6(
          record, identity, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_either}
  static IOEither<E, (A, B, C, D, F, G, H)>
      sequenceRecord7<E, A, B, C, D, F, G, H>(
    (
      IOEither<E, A>,
      IOEither<E, B>,
      IOEither<E, C>,
      IOEither<E, D>,
      IOEither<E, F>,
      IOEither<E, G>,
      IOEither<E, H>
    ) record,
  ) =>
          traverseRecord7(record, identity, identity, identity, identity,
              identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_either}
  static IOEither<E, (A, B, C, D, F, G, H, I)>
      sequenceRecord8<E, A, B, C, D, F, G, H, I>(
    (
      IOEither<E, A>,
      IOEither<E, B>,
      IOEither<E, C>,
      IOEither<E, D>,
      IOEither<E, F>,
      IOEither<E, G>,
      IOEither<E, H>,
      IOEither<E, I>
    ) record,
  ) =>
          traverseRecord8(record, identity, identity, identity, identity,
              identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_either}
  static IOEither<E, (A, B, C, D, F, G, H, I, J)>
      sequenceRecord9<E, A, B, C, D, F, G, H, I, J>(
    (
      IOEither<E, A>,
      IOEither<E, B>,
      IOEither<E, C>,
      IOEither<E, D>,
      IOEither<E, F>,
      IOEither<E, G>,
      IOEither<E, H>,
      IOEither<E, I>,
      IOEither<E, J>
    ) record,
  ) =>
          traverseRecord9(record, identity, identity, identity, identity,
              identity, identity, identity, identity, identity);
}
