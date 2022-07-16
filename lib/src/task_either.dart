import 'either.dart';
import 'function.dart';
import 'option.dart';
import 'task.dart';
import 'typeclass/alt.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

/// Tag the [HKT2] interface for the actual [TaskEither].
abstract class _TaskEitherHKT {}

/// `TaskEither<L, R>` represents an asynchronous computation that
/// either yields a value of type `R` or fails yielding an error of type `L`.
///
/// If you want to represent an asynchronous computation that never fails, see [Task].
class TaskEither<L, R> extends HKT2<_TaskEitherHKT, L, R>
    with
        Functor2<_TaskEitherHKT, L, R>,
        Applicative2<_TaskEitherHKT, L, R>,
        Monad2<_TaskEitherHKT, L, R>,
        Alt2<_TaskEitherHKT, L, R> {
  final Future<Either<L, R>> Function() _run;

  /// Build a [TaskEither] from a function returning a `Future<Either<L, R>>`.
  const TaskEither(this._run);

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
  TaskEither<C, R> mapLeft<C>(C Function(L l) f) => TaskEither(() async =>
      (await run()).match((l) => Either.left(f(l)), (r) => Either.of(r)));

  /// Define two functions to change both the [Left] and [Right] value of the
  /// [TaskEither].
  ///
  /// Same as `map`+`mapLeft` but for both [Left] and [Right]
  /// (`map` is only to change [Right], while `mapLeft` is only to change [Left]).
  TaskEither<C, D> bimap<C, D>(
          C Function(L l) mapLeft, D Function(R r) mapRight) =>
      map(mapRight).mapLeft(mapLeft);

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
      flatMap((b) => chain(b).map((c) => b));

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
      TaskEither(() async => option.match(right, () => Left(onNone())));

  /// Build a [TaskEither] that returns `either`.
  factory TaskEither.fromEither(Either<L, R> either) =>
      TaskEither(() async => either);

  /// Converts a [Future] that may throw to a [Future] that never throws
  /// but returns a [Either] instead.
  ///
  /// Used to handle asynchronous computations that may throw using [Either].
  factory TaskEither.tryCatch(Future<R> Function() run,
          L Function(Object error, StackTrace stackTrace) onError) =>
      TaskEither<L, R>(() async {
        try {
          return Right<L, R>(await run());
        } catch (error, stack) {
          return Left<L, R>(onError(error, stack));
        }
      });

  /// Converts a [Future] that may throw to a [Future] that never throws
  /// but returns a [Either] instead.
  ///
  /// Used to handle asynchronous computations that may throw using [Either].
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
