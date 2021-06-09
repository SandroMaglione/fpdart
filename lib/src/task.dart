import 'package:fpdart/fpdart.dart';

abstract class TaskHKT {}

class Task<A> extends HKT<TaskHKT, A> with Monad<TaskHKT, A> {
  final Future<A> Function() _run;
  Task(this._run);

  factory Task.of(A a) => Task(() async => a);

  @override
  Task<B> ap<B>(covariant Task<B Function(A a)> a) =>
      Task(() => a.run().then((f) => run().then((v) => f(v))));

  @override
  Task<B> flatMap<B>(covariant Task<B> Function(A a) f) =>
      Task(() => run().then((v) => f(v).run()));

  @override
  Task<B> pure<B>(B a) => Task(() async => a);

  @override
  Task<B> map<B>(B Function(A a) f) => ap(pure(f));

  Future<A> run() => _run();
}
