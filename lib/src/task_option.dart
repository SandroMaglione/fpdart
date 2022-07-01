import 'either.dart';
import 'function.dart';
import 'option.dart';
import 'task.dart';
import 'typeclass/alt.dart';
import 'typeclass/applicative.dart';
import 'typeclass/functor.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

/// Tag the [HKT] interface for the actual [TaskOption].
abstract class _TaskOptionHKT {}

/// `TaskOption<R>` represents an asynchronous computation that
/// may fails yielding a [None] or returns a `Some(R)` when successful.
///
/// If you want to represent an asynchronous computation that never fails, see [Task].
///
/// If you want to represent an asynchronous computation that returns an object when it fails,
/// see [TaskEither].
class TaskOption<R> extends HKT<_TaskOptionHKT, R>
    with
        Functor<_TaskOptionHKT, R>,
        Applicative<_TaskOptionHKT, R>,
        Monad<_TaskOptionHKT, R>,
        Alt<_TaskOptionHKT, R> {
  final Future<Option<R>> Function() _run;

  /// Build a [TaskOption] from a function returning a `Future<Option<R>>`.
  const TaskOption(this._run);

  /// Used to chain multiple functions that return a [TaskOption].
  ///
  /// You can extract the value of every [Some] in the chain without
  /// handling all possible missing cases.
  /// If running any of the tasks in the chain returns [None], the result is [None].
  @override
  TaskOption<C> flatMap<C>(covariant TaskOption<C> Function(R r) f) =>
      TaskOption(() => run().then(
            (option) async => option.match(
              (r) => f(r).run(),
              () => Option.none(),
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
      TaskOption(() async => (await run()).match(some, () => orElse().run()));

  /// When this [TaskOption] returns a [None] then return the result of `orElse`.
  /// Otherwise return this [TaskOption].
  TaskOption<R> orElse<TL>(TaskOption<R> Function() orElse) =>
      TaskOption(() async => (await run())
          .match((r) => TaskOption<R>.some(r).run(), () => orElse().run()));

  /// Convert this [TaskOption] to a [Task].
  ///
  /// The task returns a [Some] when [TaskOption] returns [Some].
  /// Otherwise map the type `L` of [TaskOption] to type `R` by calling `orElse`.
  Task<R> getOrElse(R Function() orElse) =>
      Task(() async => (await run()).match(identity, orElse));

  /// Pattern matching to convert a [TaskOption] to a [Task].
  ///
  /// Execute `onNone` when running this [TaskOption] returns a [None].
  /// Otherwise execute `onSome`.
  Task<A> match<A>(A Function() onNone, A Function(R r) onSome) =>
      Task(() async => (await run()).match(onSome, onNone));

  /// Creates a [TaskOption] that will complete after a time delay specified by a [Duration].
  TaskOption<R> delay(Duration duration) =>
      TaskOption(() => Future.delayed(duration, run));

  /// Run the task and return a `Future<Option<R>>`.
  Future<Option<R>> run() => _run();

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
  factory TaskOption.none() => TaskOption(() async => Option.none());

  /// Build a [TaskOption] from the result of running `task`.
  factory TaskOption.fromTask(Task<R> task) =>
      TaskOption(() async => Option.of(await task.run()));

  /// When calling `predicate` with `value` returns `true`, then running [TaskOption] returns `Some(value)`.
  /// Otherwise return [None].
  factory TaskOption.fromPredicate(R value, bool Function(R a) predicate) =>
      TaskOption(
          () async => predicate(value) ? Option.of(value) : Option.none());

  /// Converts a [Future] that may throw to a [Future] that never throws
  /// but returns a [Option] instead.
  ///
  /// Used to handle asynchronous computations that may throw using [Option].
  factory TaskOption.tryCatch(Future<R> Function() run) =>
      TaskOption<R>(() async {
        try {
          return Option.of(await run());
        } catch (_) {
          return Option.none();
        }
      });

  /// Build a [TaskOption] from `either` that returns [None] when
  /// `either` is [Left], otherwise it returns [Some].
  static TaskOption<R> fromEither<L, R>(Either<L, R> either) =>
      TaskOption(() async => either.match((_) => Option.none(), some));

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
}
