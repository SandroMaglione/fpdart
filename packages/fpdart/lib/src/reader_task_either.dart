import 'either.dart';
import 'function.dart';
import 'io.dart';
import 'io_either.dart';
import 'io_option.dart';
import 'option.dart';
import 'reader.dart';
import 'reader_task.dart';
import 'task.dart';
import 'task_either.dart';
import 'task_option.dart';
import 'typeclass/alt.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

final class _ReaderTaskEitherThrow<L> {
  final L value;
  const _ReaderTaskEitherThrow(this.value);
}

typedef DoAdapterReaderTaskEither<E, L> = Future<A> Function<A>(
    ReaderTaskEither<E, L, A>);

DoAdapterReaderTaskEither<E, L> _doAdapter<E, L>(E env) =>
    <A>(readerTaskEither) => readerTaskEither.run(env).then(
          (either) => either.getOrElse((l) => throw _ReaderTaskEitherThrow(l)),
        );

typedef DoFunctionReaderTaskEither<E, L, A> = Future<A> Function(
    DoAdapterReaderTaskEither<E, L> $);

/// Tag the [HKT3] interface for the actual [ReaderTaskEither].
abstract final class _ReaderTaskEitherHKT {}

/// `ReaderTaskEither<E, L, R>` represents an asynchronous computation (`Task`) that
/// either yields a value of type `R` or fails yielding an error of type `L` (`Either`),
/// that allows to read values from a dependency/context `E` (`Reader`).
///
/// [ReaderTaskEither] models a complete program using `Reader` for dependency injection,
/// `Task` to perform asynchronous computation, and `Either` to handle errors.
final class ReaderTaskEither<E, L, R>
    extends HKT3<_ReaderTaskEitherHKT, E, L, R>
    with
        Functor3<_ReaderTaskEitherHKT, E, L, R>,
        Applicative3<_ReaderTaskEitherHKT, E, L, R>,
        Monad3<_ReaderTaskEitherHKT, E, L, R>,
        Alt3<_ReaderTaskEitherHKT, E, L, R> {
  final Future<Either<L, R>> Function(E env) _run;

  /// Build a [ReaderTaskEither] from a function returning a `Future<Either<L, R>>`.
  const ReaderTaskEither(this._run);

  /// Initialize a **Do Notation** chain.
  // ignore: non_constant_identifier_names
  factory ReaderTaskEither.Do(DoFunctionReaderTaskEither<E, L, R> f) =>
      ReaderTaskEither((env) async {
        try {
          return Either.of(await f(_doAdapter<E, L>(env)));
        } on _ReaderTaskEitherThrow<L> catch (e) {
          return Either.left(e.value);
        }
      });

  /// Run the task given `E` and return a `Future<Either<L, R>>`.
  Future<Either<L, R>> run(E env) => _run(env);

  /// Returns a [ReaderTaskEither] that returns a `Right(a)`.
  @override
  ReaderTaskEither<E, L, C> pure<C>(C a) => ReaderTaskEither(
        (_) async => Right(a),
      );

  /// Used to chain multiple functions that return a [ReaderTaskEither].
  ///
  /// You can extract the value of every [Right] in the chain without
  /// handling all possible missing cases.
  ///
  /// If running any of the tasks in the chain returns [Left], the result is [Left].
  @override
  ReaderTaskEither<E, L, C> flatMap<C>(
    covariant ReaderTaskEither<E, L, C> Function(R r) f,
  ) =>
      ReaderTaskEither((env) => run(env).then(
            (either) async => either.match(
              left,
              (r) => f(r).run(env),
            ),
          ));

  /// Chain a function that takes the current value `R` inside this [TaskEither]
  /// and returns [Either].
  ///
  /// Similar to `flatMap`, but `f` returns [Either] instead of [TaskEither].
  ReaderTaskEither<E, L, C> flatMapTaskEither<C>(
    TaskEither<L, C> Function(R r) f,
  ) =>
      ReaderTaskEither((env) => run(env).then(
            (either) async => either.match(
              left,
              (r) => f(r).run(),
            ),
          ));

  /// If running this [ReaderTaskEither] returns [Right], then return the result of calling `then`.
  /// Otherwise return [Left].
  @override
  ReaderTaskEither<E, L, C> andThen<C>(
    covariant ReaderTaskEither<E, L, C> Function() then,
  ) =>
      flatMap((_) => then());

  /// If running this [ReaderTaskEither] returns [Right], then change its value from type `R` to
  /// type `C` using function `f`.
  @override
  ReaderTaskEither<E, L, C> map<C>(C Function(R r) f) => ap(pure(f));

  @override
  ReaderTaskEither<E, L, N2> map2<N1, N2>(
    covariant ReaderTaskEither<E, L, N1> m1,
    N2 Function(R p1, N1 p2) f,
  ) =>
      flatMap((b) => m1.map((c) => f(b, c)));

  @override
  ReaderTaskEither<E, L, N3> map3<N1, N2, N3>(
    covariant ReaderTaskEither<E, L, N1> m1,
    covariant ReaderTaskEither<E, L, N2> m2,
    N3 Function(R p1, N1 p2, N2 p3) f,
  ) =>
      flatMap(
        (b) => m1.flatMap((c) => m2.map((d) => f(b, c, d))),
      );

  /// Change the value in the [Left] of [ReaderTaskEither].
  ReaderTaskEither<E, C, R> mapLeft<C>(C Function(L l) f) => ReaderTaskEither(
        (env) async => (await run(env)).match(
          (l) => Either.left(f(l)),
          Either.of,
        ),
      );

  /// Define two functions to change both the [Left] and [Right] value of the
  /// [ReaderTaskEither].
  ReaderTaskEither<E, C, D> bimap<C, D>(
    C Function(L l) mLeft,
    D Function(R r) mRight,
  ) =>
      mapLeft(mLeft).map(mRight);

  /// Apply the function contained inside `a` to change the value on the [Right] from
  /// type `R` to a value of type `C`.
  @override
  ReaderTaskEither<E, L, C> ap<C>(
    covariant ReaderTaskEither<E, L, C Function(R r)> a,
  ) =>
      a.flatMap(
        (f) => flatMap(
          (v) => pure(f(v)),
        ),
      );

  @override
  ReaderTaskEither<E, L, R> chainFirst<N1>(
    covariant ReaderTaskEither<E, L, N1> Function(R p1) chain,
  ) =>
      flatMap((b) => chain(b).map((c) => b));

  /// Chain multiple functions having the same left type `L`.
  @override
  ReaderTaskEither<E, L, C> call<C>(
    covariant ReaderTaskEither<E, L, C> chain,
  ) =>
      flatMap((_) => chain);

  /// Change this [ReaderTaskEither] from `ReaderTaskEither<L, R>` to `ReaderTaskEither<R, L>`.
  ReaderTaskEither<E, R, L> swap() => ReaderTaskEither(
        (env) async => (await run(env)).match(right, left),
      );

  /// When this [ReaderTaskEither] returns [Right], then return the current [ReaderTaskEither].
  /// Otherwise return the result of `orElse`.
  ///
  /// Used to provide an **alt**ernative [ReaderTaskEither] in case the current one returns [Left].
  @override
  ReaderTaskEither<E, L, R> alt(
    covariant ReaderTaskEither<E, L, R> Function() orElse,
  ) =>
      ReaderTaskEither(
        (env) async => (await run(env)).match(
          (_) => orElse().run(env),
          right,
        ),
      );

  /// If `f` applied on this [ReaderTaskEither] as [Right] returns `true`, then return this [ReaderTaskEither].
  /// If it returns `false`, return the result of `onFalse` in a [Left].
  ReaderTaskEither<E, L, R> filterOrElse(
    bool Function(R r) f,
    L Function(R r) onFalse,
  ) =>
      flatMap(
        (r) =>
            f(r) ? ReaderTaskEither.of(r) : ReaderTaskEither.left(onFalse(r)),
      );

  /// When this [ReaderTaskEither] returns a [Left] then return the result of `orElse`.
  /// Otherwise return this [ReaderTaskEither].
  ReaderTaskEither<E, TL, R> orElse<TL>(
    ReaderTaskEither<E, TL, R> Function(L l) orElse,
  ) =>
      ReaderTaskEither((env) async => (await run(env)).match(
            (l) => orElse(l).run(env),
            (r) => ReaderTaskEither<E, TL, R>.of(r).run(env),
          ));

  /// Convert this [ReaderTaskEither] to a [ReaderTask].
  ///
  /// The task returns a [Right] when [ReaderTaskEither] returns [Right].
  /// Otherwise map the type `L` of [ReaderTaskEither] to type `R` by calling `orElse`.
  ReaderTask<E, R> getOrElse(R Function(L left) orElse) => ReaderTask(
        (env) async => (await run(env)).match(
          orElse,
          identity,
        ),
      );

  /// Pattern matching to convert a [ReaderTaskEither] to a [ReaderTask].
  ///
  /// Execute `onLeft` when running this [ReaderTaskEither] returns a [Left].
  /// Otherwise execute `onRight`.
  ReaderTask<E, B> match<B>(
    B Function(L left) onLeft,
    B Function(R right) onRight,
  ) =>
      ReaderTask(
        (env) async => (await run(env)).match(
          onLeft,
          onRight,
        ),
      );

  /// Flat a [ReaderTaskEither] contained inside another [ReaderTaskEither] to be a single [ReaderTaskEither].
  factory ReaderTaskEither.flatten(
    ReaderTaskEither<E, L, ReaderTaskEither<E, L, R>> readerTaskEither,
  ) =>
      readerTaskEither.flatMap(identity);

  /// Build a [ReaderTaskEither] that returns a [Right] containing the result of running `reader`.
  factory ReaderTaskEither.fromReader(Reader<E, R> reader) => ReaderTaskEither(
        (env) async => Right(reader.run(env)),
      );

  /// Build a [ReaderTaskEither] from a `Reader<E, L>`.
  factory ReaderTaskEither.leftReader(Reader<E, L> reader) => ReaderTaskEither(
        (env) async => Left(reader.run(env)),
      );

  /// Build a [ReaderTaskEither] that returns a `Left(left)`.
  factory ReaderTaskEither.left(L left) => ReaderTaskEither(
        (_) async => Left(left),
      );

  /// Build a [ReaderTaskEither] that returns a [Left] containing the result of running `task`.
  factory ReaderTaskEither.leftTask(Task<L> task) => ReaderTaskEither(
        (_) => task.run().then(left),
      );

  /// Build a [ReaderTaskEither] that returns a [Right] containing the result of running `task`.
  factory ReaderTaskEither.fromTask(Task<R> task) => ReaderTaskEither(
        (_) async => Right(await task.run()),
      );

  /// Build a [ReaderTaskEither] that returns a [Right] containing the result of running `task`,
  /// or the result of `onNone` if `task` is [Left].
  factory ReaderTaskEither.fromTaskOption(
    TaskOption<R> task,
    L Function() onNone,
  ) =>
      ReaderTaskEither(
        (_) async => Either.fromOption(await task.run(), onNone),
      );

  /// Build a [ReaderTaskEither] that returns a [Right] containing the result of running `task`.
  factory ReaderTaskEither.fromTaskEither(TaskEither<L, R> task) =>
      ReaderTaskEither(
        (_) async => task.run(),
      );

  /// Build a [ReaderTaskEither] that returns a [Right] containing the result of running `io`.
  factory ReaderTaskEither.fromIO(IO<R> io) => ReaderTaskEither(
        (_) async => Right(io.run()),
      );

  /// Build a [ReaderTaskEither] that returns a [Right] containing the result of running `io`,
  /// or the result of `onNone` if `io` is [Left].
  factory ReaderTaskEither.fromIOOption(
    IOOption<R> io,
    L Function() onNone,
  ) =>
      ReaderTaskEither(
        (_) async => Either.fromOption(io.run(), onNone),
      );

  /// Build a [ReaderTaskEither] that returns a [Right] containing the result of running `io`.
  factory ReaderTaskEither.fromIOEither(IOEither<L, R> io) => ReaderTaskEither(
        (_) async => io.run(),
      );

  /// {@template fpdart_from_nullable_reader_task_either}
  /// If `r` is `null`, then return the result of `onNull` in [Left].
  /// Otherwise return `Right(r)`.
  /// {@endtemplate}
  factory ReaderTaskEither.fromNullable(R? r, L Function() onNull) =>
      ReaderTaskEither(
        (_) async => Either.fromNullable(r, onNull),
      );

  /// {@macro fpdart_from_nullable_reader_task_either}
  factory ReaderTaskEither.fromNullableAsync(R? r, Task<L> onNull) =>
      ReaderTaskEither(
        (_) async => r != null ? Either.of(r) : Either.left(await onNull.run()),
      );

  /// Build a [ReaderTaskEither] from `option`.
  ///
  /// When `option` is [Some], then return [Right] when
  /// running [ReaderTaskEither]. Otherwise return `onNone`.
  factory ReaderTaskEither.fromOption(Option<R> option, L Function() onNone) =>
      ReaderTaskEither((_) async => option.match(
            () => Left(onNone()),
            Right.new,
          ));

  /// Build a [ReaderTaskEither] that returns `either`.
  factory ReaderTaskEither.fromEither(Either<L, R> either) =>
      ReaderTaskEither((_) async => either);

  /// Build a [ReaderTaskEither] that returns a `Right(r)`.
  factory ReaderTaskEither.of(R r) => ReaderTaskEither(
        (_) async => Either.of(r),
      );

  /// Execute an async function ([Future]) and convert the result to [Either]:
  /// - If the execution is successful, returns a [Right]
  /// - If the execution fails (`throw`), then return a [Left] based on `onError`
  ///
  /// Used to work with [Future] and exceptions using [Either] instead of `try`/`catch`.
  factory ReaderTaskEither.tryCatch(
    Future<R> Function(E) run,
    L Function(Object error, StackTrace stackTrace) onError,
  ) =>
      ReaderTaskEither<E, L, R>((env) async {
        try {
          return Right<L, R>(await run(env));
        } catch (error, stack) {
          return Left<L, R>(onError(error, stack));
        }
      });

  /// Extract a value `A` given the current dependency `E`.
  factory ReaderTaskEither.asks(R Function(E) f) => ReaderTaskEither(
        (env) async => right(f(env)),
      );

  /// Read the current dependency `E`.
  static ReaderTaskEither<E, L, E> ask<E, L>() => ReaderTaskEither(
        (env) async => right(env),
      );
}
