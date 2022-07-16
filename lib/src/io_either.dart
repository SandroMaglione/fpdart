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

/// Tag the [HKT2] interface for the actual [IOEither].
abstract class _IOEitherHKT {}

/// `IOEither<L, R>` represents a **non-deterministic synchronous** computation that
/// can **cause side effects**, yields a value of type `R` or **can fail** by returning
/// a value of type `L`.
///
/// If you want to represent a synchronous computation that may never fail, see [IO].
class IOEither<L, R> extends HKT2<_IOEitherHKT, L, R>
    with
        Functor2<_IOEitherHKT, L, R>,
        Applicative2<_IOEitherHKT, L, R>,
        Monad2<_IOEitherHKT, L, R>,
        Alt2<_IOEitherHKT, L, R> {
  final Either<L, R> Function() _run;

  /// Build an instance of [IOEither] from `Either<L, R> Function()`.
  const IOEither(this._run);

  /// Used to chain multiple functions that return a [IOEither].
  ///
  /// You can extract the value of every [Right] in the chain without
  /// handling all possible missing cases.
  /// If running any of the IOs in the chain returns [Left], the result is [Left].
  @override
  IOEither<L, C> flatMap<C>(covariant IOEither<L, C> Function(R r) f) =>
      IOEither(
        () => run().match(
          (l) => Either.left(l),
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
          (l) => Either.left(l),
          (r) => f(r).run(),
        ),
      );

  /// Lift this [IOEither] to a [TaskEither].
  ///
  /// Return a `Future<Either<L, R>>` ([TaskEither]) instead of
  /// a `Either<L, R>` ([IOEither]).
  TaskEither<L, R> toTask() => TaskEither(() async => run());

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

  /// Apply the function contained inside `a` to change the value on the [Right] from
  /// type `R` to a value of type `C`.
  @override
  IOEither<L, C> ap<C>(covariant IOEither<L, C Function(R r)> a) =>
      a.flatMap((f) => flatMap((v) => pure(f(v))));

  /// Change this [IOEither] from `IOEither<L, R>` to `IOEither<R, L>`.
  IOEither<R, L> swap() =>
      IOEither(() => run().match((l) => Right(l), (r) => Left(r)));

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
      flatMap((b) => chain(b).map((c) => b));

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
      IOEither(() => option.match((r) => Right(r), () => Left(onNone())));

  /// Build a [IOEither] that returns `either`.
  factory IOEither.fromEither(Either<L, R> either) => IOEither(() => either);

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
}
