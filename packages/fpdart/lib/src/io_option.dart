import 'either.dart';
import 'extension/option_extension.dart';
import 'function.dart';
import 'io.dart';
import 'io_either.dart';
import 'option.dart';
import 'task_either.dart';
import 'task_option.dart';
import 'typeclass/alt.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

part 'io_option_extension.dart';

final class _IOOptionThrow implements Exception {
  const _IOOptionThrow();
}

typedef DoAdapterIOOption = A Function<A>(IOOption<A>);
A _doAdapter<A>(IOOption<A> iOOption) => iOOption.run().getOrElse(
      () => throw const _IOOptionThrow(),
    );

typedef DoFunctionIOOption<A> = A Function(DoAdapterIOOption $);

/// Tag the [HKT] interface for the actual [IOOption].
abstract final class _IOOptionHKT {}

/// `IOOption<R>` represents an **synchronous** computation that
/// may fails yielding a [None] or returns a `Some(R)` when successful.
///
/// If you want to represent an synchronous computation that never fails, see [IO].
///
/// If you want to represent an synchronous computation that returns an object when it fails,
/// see [IOEither].
final class IOOption<R> extends HKT<_IOOptionHKT, R>
    with
        Functor<_IOOptionHKT, R>,
        Applicative<_IOOptionHKT, R>,
        Monad<_IOOptionHKT, R>,
        Alt<_IOOptionHKT, R> {
  final Option<R> Function() _run;

  /// Build a [IOOption] from a function returning a `Option<R>`.
  const IOOption(this._run);

  /// Initialize a **Do Notation** chain.
  // ignore: non_constant_identifier_names
  factory IOOption.Do(DoFunctionIOOption<R> f) => IOOption(() {
        try {
          return Option.of(f(_doAdapter));
        } on _IOOptionThrow catch (_) {
          return const Option.none();
        }
      });

  /// Used to chain multiple functions that return a [IOOption].
  ///
  /// You can extract the value of every [Some] in the chain without
  /// handling all possible missing cases.
  /// If running any of the functions in the chain returns [None], the result is [None].
  @override
  IOOption<C> flatMap<C>(covariant IOOption<C> Function(R r) f) =>
      IOOption(() => run().match(
            Option.none,
            (r) => f(r).run(),
          ));

  /// Returns a [IOOption] that returns `Some(c)`.
  @override
  IOOption<C> pure<C>(C c) => IOOption(() => Option.of(c));

  /// Change the return type of this [IOOption] based on its value of type `R` and the
  /// value of type `C` of another [IOOption].
  @override
  IOOption<D> map2<C, D>(covariant IOOption<C> m1, D Function(R b, C c) f) =>
      flatMap((b) => m1.map((c) => f(b, c)));

  /// Change the return type of this [IOOption] based on its value of type `R`, the
  /// value of type `C` of a second [IOOption], and the value of type `D`
  /// of a third [IOOption].
  @override
  IOOption<E> map3<C, D, E>(covariant IOOption<C> m1, covariant IOOption<D> m2,
          E Function(R b, C c, D d) f) =>
      flatMap((b) => m1.flatMap((c) => m2.map((d) => f(b, c, d))));

  /// If running this [IOOption] returns [Some], then return the result of calling `then`.
  /// Otherwise return [None].
  @override
  IOOption<C> andThen<C>(covariant IOOption<C> Function() then) =>
      flatMap((_) => then());

  /// Chain multiple [IOOption] functions.
  @override
  IOOption<B> call<B>(covariant IOOption<B> chain) => flatMap((_) => chain);

  /// If running this [IOOption] returns [Some], then change its value from type `R` to
  /// type `C` using function `f`.
  @override
  IOOption<C> map<C>(C Function(R r) f) => ap(pure(f));

  /// Apply the function contained inside `a` to change the value on the [Some] from
  /// type `R` to a value of type `C`.
  @override
  IOOption<C> ap<C>(covariant IOOption<C Function(R r)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  /// When this [IOOption] returns [Some], then return the current [IOOption].
  /// Otherwise return the result of `orElse`.
  ///
  /// Used to provide an **alt**ernative [IOOption] in case the current one returns [None].
  @override
  IOOption<R> alt(covariant IOOption<R> Function() orElse) =>
      IOOption(() => run().match(
            () => orElse().run(),
            some,
          ));

  /// When this [IOOption] returns a [None] then return the result of `orElse`.
  /// Otherwise return this [IOOption].
  IOOption<R> orElse<TL>(IOOption<R> Function() orElse) =>
      IOOption(() => run().match(
            () => orElse().run(),
            (r) => IOOption<R>.some(r).run(),
          ));

  /// Extract the result of this [IOOption] into a [IO].
  ///
  /// The IO returns a [Some] when [IOOption] returns [Some].
  /// Otherwise map the type `L` of [IOOption] to type `R` by calling `orElse`.
  IO<R> getOrElse(R Function() orElse) => IO(() => run().match(
        orElse,
        identity,
      ));

  /// Pattern matching to convert a [IOOption] to a [IO].
  ///
  /// Execute `onNone` when running this [IOOption] returns a [None].
  /// Otherwise execute `onSome`.
  IO<A> match<A>(A Function() onNone, A Function(R r) onSome) =>
      IO(() => run().match(
            onNone,
            onSome,
          ));

  /// Run the IO and return a `Option<R>`.
  Option<R> run() => _run();

  /// Convert this [IOOption] to [IOEither].
  ///
  /// If the value inside [IOOption] is [None], then use `onNone` to convert it
  /// to a value of type `L`.
  IOEither<L, R> toIOEither<L>(L Function() onNone) =>
      IOEither(() => Either.fromOption(run(), onNone));

  /// Convert this [IOOption] to [TaskOption].
  TaskOption<R> toTaskOption<L>() => TaskOption(() async => run());

  /// Convert this [IOOption] to [TaskEither].
  ///
  /// If the value inside [IOOption] is [None], then use `onNone` to convert it
  /// to a value of type `L`.
  TaskEither<L, R> toTaskEither<L>(L Function() onNone) =>
      TaskEither(() async => Either.fromOption(run(), onNone));

  /// Build a [IOOption] that returns a `Some(r)`.
  ///
  /// Same of `IOOption.some`.
  factory IOOption.of(R r) => IOOption(() => Option.of(r));

  /// Flat a [IOOption] contained inside another [IOOption] to be a single [IOOption].
  factory IOOption.flatten(IOOption<IOOption<R>> ioOption) =>
      ioOption.flatMap(identity);

  /// Build a [IOOption] that returns a `Some(r)`.
  ///
  /// Same of `IOOption.of`.
  factory IOOption.some(R r) => IOOption(() => Option.of(r));

  /// Build a [IOOption] that returns a [None].
  factory IOOption.none() => IOOption(() => const Option.none());

  /// If `r` is `null`, then return [None].
  /// Otherwise return `Right(r)`.
  factory IOOption.fromNullable(R? r) => Option.fromNullable(r).toIOOption();

  /// When calling `predicate` with `value` returns `true`, then running [IOOption] returns `Some(value)`.
  /// Otherwise return [None].
  factory IOOption.fromPredicate(R value, bool Function(R a) predicate) =>
      IOOption(
        () => predicate(value) ? Option.of(value) : const Option.none(),
      );

  /// Converts a function that may throw to a function that never throws
  /// but returns a [Option] instead.
  ///
  /// Used to handle synchronous computations that may throw using [Option].
  factory IOOption.tryCatch(R Function() run) => IOOption<R>(() {
        try {
          return Option.of(run());
        } catch (_) {
          return const Option.none();
        }
      });

  /// {@template fpdart_traverse_list_io_option}
  /// Map each element in the list to a [IOOption] using the function `f`,
  /// and collect the result in an `IOOption<List<B>>`.
  /// {@endtemplate}
  ///
  /// Same as `IOOption.traverseList` but passing `index` in the map function.
  static IOOption<List<B>> traverseListWithIndex<A, B>(
    List<A> list,
    IOOption<B> Function(A a, int i) f,
  ) =>
      IOOption<List<B>>(
        () => Option.sequenceList(
          IO
              .traverseListWithIndex<A, Option<B>>(
                list,
                (a, i) => IO(() => f(a, i).run()),
              )
              .run(),
        ),
      );

  /// {@macro fpdart_traverse_list_io_option}
  ///
  /// Same as `IOOption.traverseListWithIndex` but without `index` in the map function.
  static IOOption<List<B>> traverseList<A, B>(
    List<A> list,
    IOOption<B> Function(A a) f,
  ) =>
      traverseListWithIndex<A, B>(list, (a, _) => f(a));

  /// {@template fpdart_sequence_list_io_option}
  /// Convert a `List<IOOption<A>>` to a single `IOOption<List<A>>`.
  /// {@endtemplate}
  static IOOption<List<A>> sequenceList<A>(
    List<IOOption<A>> list,
  ) =>
      traverseList(list, identity);

  /// Build a [IOOption] from `either` that returns [None] when
  /// `either` is [Left], otherwise it returns [Some].
  static IOOption<R> fromEither<L, R>(Either<L, R> either) =>
      IOOption(() => either.match((_) => const Option.none(), some));

  /// Converts a function that may throw to a function that never throws
  /// but returns a [Option] instead.
  ///
  /// Used to handle synchronous computations that may throw using [Option].
  ///
  /// It wraps the `IOOption.tryCatch` factory to make chaining with `flatMap`
  /// easier.
  static IOOption<R> Function(A a) tryCatchK<R, A>(R Function(A a) run) =>
      (a) => IOOption.tryCatch(() => run(a));

  /// {@template fpdart_traverse_record_io_option}
  /// Apply the provided functions to each element of the record,
  /// and collect the results in an [IOOption] of a record.
  ///
  /// If any result is [None], the entire result is [None].
  /// {@endtemplate}
  static IOOption<(B1, B2)> traverseRecord2<A1, A2, B1, B2>(
    (A1, A2) record,
    IOOption<B1> Function(A1) f1,
    IOOption<B2> Function(A2) f2,
  ) =>
      f1(record.$1).flatMap((b1) => f2(record.$2).map((b2) => (b1, b2)));

  /// {@macro fpdart_traverse_record_io_option}
  static IOOption<(B1, B2, B3)> traverseRecord3<A1, A2, A3, B1, B2, B3>(
    (A1, A2, A3) record,
    IOOption<B1> Function(A1) f1,
    IOOption<B2> Function(A2) f2,
    IOOption<B3> Function(A3) f3,
  ) =>
      f1(record.$1).flatMap((b1) =>
          f2(record.$2).flatMap((b2) => f3(record.$3).map((b3) => (b1, b2, b3))));

  /// {@macro fpdart_traverse_record_io_option}
  static IOOption<(B1, B2, B3, B4)>
      traverseRecord4<A1, A2, A3, A4, B1, B2, B3, B4>(
    (A1, A2, A3, A4) record,
    IOOption<B1> Function(A1) f1,
    IOOption<B2> Function(A2) f2,
    IOOption<B3> Function(A3) f3,
    IOOption<B4> Function(A4) f4,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3)
                  .flatMap((b3) => f4(record.$4).map((b4) => (b1, b2, b3, b4)))));

  /// {@macro fpdart_traverse_record_io_option}
  static IOOption<(B1, B2, B3, B4, B5)>
      traverseRecord5<A1, A2, A3, A4, A5, B1, B2, B3, B4, B5>(
    (A1, A2, A3, A4, A5) record,
    IOOption<B1> Function(A1) f1,
    IOOption<B2> Function(A2) f2,
    IOOption<B3> Function(A3) f3,
    IOOption<B4> Function(A4) f4,
    IOOption<B5> Function(A5) f5,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4)
                  .flatMap((b4) => f5(record.$5).map((b5) => (b1, b2, b3, b4, b5))))));

  /// {@macro fpdart_traverse_record_io_option}
  static IOOption<(B1, B2, B3, B4, B5, B6)>
      traverseRecord6<A1, A2, A3, A4, A5, A6, B1, B2, B3, B4, B5, B6>(
    (A1, A2, A3, A4, A5, A6) record,
    IOOption<B1> Function(A1) f1,
    IOOption<B2> Function(A2) f2,
    IOOption<B3> Function(A3) f3,
    IOOption<B4> Function(A4) f4,
    IOOption<B5> Function(A5) f5,
    IOOption<B6> Function(A6) f6,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap(
                      (b5) => f6(record.$6).map((b6) => (b1, b2, b3, b4, b5, b6)))))));

  /// {@macro fpdart_traverse_record_io_option}
  static IOOption<(B1, B2, B3, B4, B5, B6, B7)>
      traverseRecord7<A1, A2, A3, A4, A5, A6, A7, B1, B2, B3, B4, B5, B6, B7>(
    (A1, A2, A3, A4, A5, A6, A7) record,
    IOOption<B1> Function(A1) f1,
    IOOption<B2> Function(A2) f2,
    IOOption<B3> Function(A3) f3,
    IOOption<B4> Function(A4) f4,
    IOOption<B5> Function(A5) f5,
    IOOption<B6> Function(A6) f6,
    IOOption<B7> Function(A7) f7,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).map((b7) => (b1, b2, b3, b4, b5, b6, b7))))))));

  /// {@macro fpdart_traverse_record_io_option}
  static IOOption<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseRecord8<A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B3, B4, B5, B6, B7,
              B8>(
    (A1, A2, A3, A4, A5, A6, A7, A8) record,
    IOOption<B1> Function(A1) f1,
    IOOption<B2> Function(A2) f2,
    IOOption<B3> Function(A3) f3,
    IOOption<B4> Function(A4) f4,
    IOOption<B5> Function(A5) f5,
    IOOption<B6> Function(A6) f6,
    IOOption<B7> Function(A7) f7,
    IOOption<B8> Function(A8) f8,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8)
                          .map((b8) => (b1, b2, b3, b4, b5, b6, b7, b8)))))))));

  /// {@macro fpdart_traverse_record_io_option}
  static IOOption<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseRecord9<A1, A2, A3, A4, A5, A6, A7, A8, A9, B1, B2, B3, B4, B5, B6,
              B7, B8, B9>(
    (A1, A2, A3, A4, A5, A6, A7, A8, A9) record,
    IOOption<B1> Function(A1) f1,
    IOOption<B2> Function(A2) f2,
    IOOption<B3> Function(A3) f3,
    IOOption<B4> Function(A4) f4,
    IOOption<B5> Function(A5) f5,
    IOOption<B6> Function(A6) f6,
    IOOption<B7> Function(A7) f7,
    IOOption<B8> Function(A8) f8,
    IOOption<B9> Function(A9) f9,
  ) =>
          f1(record.$1).flatMap((b1) => f2(record.$2).flatMap((b2) =>
              f3(record.$3).flatMap((b3) => f4(record.$4).flatMap((b4) =>
                  f5(record.$5).flatMap((b5) => f6(record.$6).flatMap((b6) =>
                      f7(record.$7).flatMap((b7) => f8(record.$8).flatMap((b8) =>
                          f9(record.$9)
                              .map((b9) => (b1, b2, b3, b4, b5, b6, b7, b8, b9))))))))));

  /// {@template fpdart_sequence_record_io_option}
  /// Combine all [IOOption] in the record and collect results.
  ///
  /// If any [IOOption] is [None], the result is [None].
  /// {@endtemplate}
  static IOOption<(A, B)> sequenceRecord2<A, B>(
    (IOOption<A>, IOOption<B>) record,
  ) =>
      traverseRecord2(record, identity, identity);

  /// {@macro fpdart_sequence_record_io_option}
  static IOOption<(A, B, C)> sequenceRecord3<A, B, C>(
    (IOOption<A>, IOOption<B>, IOOption<C>) record,
  ) =>
      traverseRecord3(record, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_option}
  static IOOption<(A, B, C, D)> sequenceRecord4<A, B, C, D>(
    (IOOption<A>, IOOption<B>, IOOption<C>, IOOption<D>) record,
  ) =>
      traverseRecord4(record, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_option}
  static IOOption<(A, B, C, D, F)> sequenceRecord5<A, B, C, D, F>(
    (IOOption<A>, IOOption<B>, IOOption<C>, IOOption<D>, IOOption<F>) record,
  ) =>
      traverseRecord5(record, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_option}
  static IOOption<(A, B, C, D, F, G)> sequenceRecord6<A, B, C, D, F, G>(
    (
      IOOption<A>,
      IOOption<B>,
      IOOption<C>,
      IOOption<D>,
      IOOption<F>,
      IOOption<G>
    ) record,
  ) =>
      traverseRecord6(
          record, identity, identity, identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_option}
  static IOOption<(A, B, C, D, F, G, H)> sequenceRecord7<A, B, C, D, F, G, H>(
    (
      IOOption<A>,
      IOOption<B>,
      IOOption<C>,
      IOOption<D>,
      IOOption<F>,
      IOOption<G>,
      IOOption<H>
    ) record,
  ) =>
      traverseRecord7(record, identity, identity, identity, identity, identity,
          identity, identity);

  /// {@macro fpdart_sequence_record_io_option}
  static IOOption<(A, B, C, D, F, G, H, I)>
      sequenceRecord8<A, B, C, D, F, G, H, I>(
    (
      IOOption<A>,
      IOOption<B>,
      IOOption<C>,
      IOOption<D>,
      IOOption<F>,
      IOOption<G>,
      IOOption<H>,
      IOOption<I>
    ) record,
  ) =>
          traverseRecord8(record, identity, identity, identity, identity,
              identity, identity, identity, identity);

  /// {@macro fpdart_sequence_record_io_option}
  static IOOption<(A, B, C, D, F, G, H, I, J)>
      sequenceRecord9<A, B, C, D, F, G, H, I, J>(
    (
      IOOption<A>,
      IOOption<B>,
      IOOption<C>,
      IOOption<D>,
      IOOption<F>,
      IOOption<G>,
      IOOption<H>,
      IOOption<I>,
      IOOption<J>
    ) record,
  ) =>
          traverseRecord9(record, identity, identity, identity, identity,
              identity, identity, identity, identity, identity);
}
