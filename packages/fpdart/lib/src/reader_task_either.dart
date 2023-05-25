import 'either.dart';
import 'function.dart';
import 'option.dart';
import 'reader.dart';
import 'task.dart';
import 'task_either.dart';
import 'typeclass/hkt.dart';

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

/// `ReaderTaskEither<L, R>` represents an asynchronous computation that
/// either yields a value of type `R` or fails yielding an error of type `L`.
///
/// If you want to represent an asynchronous computation that never fails, see [Task].
final class ReaderTaskEither<E, L, R>
    extends HKT3<_ReaderTaskEitherHKT, E, L, R>
// with
//     Functor2<_ReaderTaskEitherHKT, L, R>,
//     Applicative2<_ReaderTaskEitherHKT, L, R>,
//     Monad2<_ReaderTaskEitherHKT, L, R>,
//     Alt2<_ReaderTaskEitherHKT, L, R>
{
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
  ReaderTaskEither<E, L, C> pure<C>(C a) => ReaderTaskEither(
        (_) async => Right(a),
      );

  /// Used to chain multiple functions that return a [ReaderTaskEither].
  ///
  /// You can extract the value of every [Right] in the chain without
  /// handling all possible missing cases.
  ///
  /// If running any of the tasks in the chain returns [Left], the result is [Left].
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
  ReaderTaskEither<E, L, C> andThen<C>(
    covariant ReaderTaskEither<E, L, C> Function() then,
  ) =>
      flatMap((_) => then());

  /// If running this [ReaderTaskEither] returns [Right], then change its value from type `R` to
  /// type `C` using function `f`.
  ReaderTaskEither<E, L, C> map<C>(C Function(R r) f) => ap(pure(f));

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
  ReaderTaskEither<E, L, C> ap<C>(
    covariant ReaderTaskEither<E, L, C Function(R r)> a,
  ) =>
      a.flatMap(
        (f) => flatMap(
          (v) => pure(f(v)),
        ),
      );

  /// Chain multiple functions having the same left type `L`.
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

  /// Flat a [ReaderTaskEither] contained inside another [ReaderTaskEither] to be a single [ReaderTaskEither].
  factory ReaderTaskEither.flatten(
    ReaderTaskEither<E, L, ReaderTaskEither<E, L, R>> readerTaskEither,
  ) =>
      readerTaskEither.flatMap(identity);

  /// Build a [ReaderTaskEither] from a `Reader<E, R>`.
  factory ReaderTaskEither.rightReader(Reader<E, R> reader) => ReaderTaskEither(
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
  ///
  /// Same of `ReaderTaskEither.fromTask`
  factory ReaderTaskEither.fromTask(Task<R> task) => ReaderTaskEither(
        (_) async => Right(await task.run()),
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
    Future<R> Function() run,
    L Function(Object error, StackTrace stackTrace) onError,
  ) =>
      ReaderTaskEither<E, L, R>((_) async {
        try {
          return Right<L, R>(await run());
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
