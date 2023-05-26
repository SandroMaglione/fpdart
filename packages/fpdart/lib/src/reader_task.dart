import 'either.dart';
import 'function.dart';
import 'reader_task_either.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

typedef DoAdapterReaderTask<E> = Future<A> Function<A>(ReaderTask<E, A>);
DoAdapterReaderTask<E> _doAdapter<E>(E env) =>
    <A>(ReaderTask<E, A> task) => task.run(env);

typedef DoFunctionReaderTask<E, A> = Future<A> Function(
    DoAdapterReaderTask<E> $);

/// Tag the [HKT] interface for the actual [ReaderTask].
abstract final class _ReaderTaskHKT {}

/// [ReaderTask] represents an asynchronous computation that yields a value of type `A`
/// from a context of type `E` and **never fails**.
///
/// If you want to represent an asynchronous computation that may fail, see [ReaderTaskEither].
final class ReaderTask<E, A> extends HKT2<_ReaderTaskHKT, E, A>
    with
        Functor2<_ReaderTaskHKT, E, A>,
        Applicative2<_ReaderTaskHKT, E, A>,
        Monad2<_ReaderTaskHKT, E, A> {
  final Future<A> Function(E env) _run;

  /// Build a [ReaderTask] from a function returning a [Future] given `E`.
  const ReaderTask(this._run);

  /// Initialize a **Do Notation** chain.
  // ignore: non_constant_identifier_names
  factory ReaderTask.Do(DoFunctionReaderTask<E, A> f) =>
      ReaderTask((env) => f(_doAdapter(env)));

  /// Build a [ReaderTask] that returns `a`.
  factory ReaderTask.of(A a) => ReaderTask((_) async => a);

  /// Flat a [ReaderTask] contained inside another [ReaderTask] to be a single [ReaderTask].
  factory ReaderTask.flatten(ReaderTask<E, ReaderTask<E, A>> task) =>
      task.flatMap(identity);

  /// Apply the function contained inside `a` to change the value of type `A` to
  /// a value of type `B`.
  @override
  ReaderTask<E, B> ap<B>(covariant ReaderTask<E, B Function(A a)> a) =>
      ReaderTask(
        (env) => a.run(env).then(
              (f) => run(env).then(
                (v) => f(v),
              ),
            ),
      );

  /// Used to chain multiple functions that return a [ReaderTask].
  ///
  /// You can extract the value inside the [ReaderTask] without actually running it.
  @override
  ReaderTask<E, B> flatMap<B>(covariant ReaderTask<E, B> Function(A a) f) =>
      ReaderTask(
        (env) => run(env).then(
          (v) => f(v).run(env),
        ),
      );

  /// Return a [ReaderTask] returning the value `b`.
  @override
  ReaderTask<E, B> pure<B>(B a) => ReaderTask((_) async => a);

  /// Change the returning value of the [ReaderTask] from type
  /// `A` to type `B` using `f`.
  @override
  ReaderTask<E, B> map<B>(B Function(A a) f) => ap(pure(f));

  /// Change type of this [ReaderTask] based on its value of type `A` and the
  /// value of type `C` of another [ReaderTask].
  @override
  ReaderTask<E, D> map2<C, D>(
          covariant ReaderTask<E, C> mc, D Function(A a, C c) f) =>
      flatMap(
        (a) => mc.map(
          (c) => f(a, c),
        ),
      );

  /// Change type of this [ReaderTask] based on its value of type `A`, the
  /// value of type `C` of a second [ReaderTask], and the value of type `D`
  /// of a third [ReaderTask].
  @override
  ReaderTask<E, F> map3<C, D, F>(
    covariant ReaderTask<E, C> mc,
    covariant ReaderTask<E, D> md,
    F Function(A a, C c, D d) f,
  ) =>
      flatMap(
        (a) => mc.flatMap(
          (c) => md.map(
            (d) => f(a, c, d),
          ),
        ),
      );

  /// Run this [ReaderTask] and right after the [ReaderTask] returned from `then`.
  @override
  ReaderTask<E, B> andThen<B>(covariant ReaderTask<E, B> Function() then) =>
      flatMap(
        (_) => then(),
      );

  @override
  ReaderTask<E, A> chainFirst<B>(
    covariant ReaderTask<E, B> Function(A a) chain,
  ) =>
      flatMap(
        (a) => chain(a).map((b) => a),
      );

  /// Chain multiple [ReaderTask] functions.
  @override
  ReaderTask<E, B> call<B>(covariant ReaderTask<E, B> chain) => flatMap(
        (_) => chain,
      );

  /// Run the task and return a [Future].
  Future<A> run(E env) => _run(env);

  /// Convert this [ReaderTask] to [ReaderTaskEither].
  ReaderTaskEither<E, L, A> toReaderTaskEither<L>() => ReaderTaskEither(
        (env) async => Either.of(
          await run(env),
        ),
      );

  /// Extract a value `A` given the current dependency `E`.
  factory ReaderTask.asks(A Function(E) f) => ReaderTask(
        (env) async => f(env),
      );

  /// Read the current dependency `E`.
  static ReaderTask<E, E> ask<E, A>() => ReaderTask(
        (env) async => env,
      );
}
