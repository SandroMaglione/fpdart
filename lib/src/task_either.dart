import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/task.dart';

class TaskEither<L, R> extends Task<Either<L, R>> {
  TaskEither(Future<Either<L, R>> Function() run) : super(run);

  TaskEither<R, L> swap() => TaskEither(
      () async => (await run()).match((l) => Right(l), (r) => Left(r)));

  TaskEither<L, R> alt(TaskEither<L, R> Function() then) => TaskEither(
      () async => (await run()).match((_) => then().run(), (_) => run()));

  TaskEither<TL, R> orElse<TL>(TaskEither<TL, R> Function(L l) orElse) =>
      TaskEither(() async => (await run()).match(
          (l) => orElse(l).run(), (r) => TaskEither<TL, R>.right(r).run()));

  Task<R> getOrElse(R Function(L l) orElse) =>
      Task(() async => (await run()).match(orElse, identity));

  Task<A> match<A>(A Function(L l) onLeft, A Function(R r) onRight) =>
      Task(() async => (await run()).match(onLeft, onRight));

  factory TaskEither.right(R right) => TaskEither(() async => Right(right));
  factory TaskEither.left(L left) => TaskEither(() async => Left(left));

  factory TaskEither.fromTask(Task<R> task) =>
      TaskEither(() async => Right(await task.run()));

  factory TaskEither.fromPredicate(
          R value, bool Function(R a) predicate, L Function(R a) onFalse) =>
      TaskEither(
          () async => predicate(value) ? Right(value) : Left(onFalse(value)));

  factory TaskEither.fromOption(Option<R> option, L Function() onNone) =>
      TaskEither(
          () async => option.match((r) => Right(r), () => Left(onNone())));

  factory TaskEither.fromEither(Either<L, R> either) =>
      TaskEither(() async => either);

  factory TaskEither.tryCatch(Future<R> Function() run,
          L Function(Object error, StackTrace stackTrace) onError) =>
      TaskEither<L, R>(() async {
        try {
          return Right<L, R>(await run());
        } catch (error, stack) {
          return Left<L, R>(onError(error, stack));
        }
      });
}
