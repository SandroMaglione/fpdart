import 'package:fpdart/fpdart.dart';

abstract class ReaderHKT {}

class Reader<R, A> extends HKT2<ReaderHKT, R, A> with Monad2<ReaderHKT, R, A> {
  final A Function(R r) _read;
  Reader(this._read);

  @override
  Reader<R, C> ap<C>(covariant Reader<R, C Function(A a)> a) =>
      Reader((r) => a.run(r)(run(r)));

  @override
  Reader<R, C> flatMap<C>(covariant Reader<R, C> Function(A a) f) =>
      Reader((r) => f(run(r)).run(r));

  @override
  Reader<R, C> pure<C>(C a) => Reader((_) => a);

  @override
  Reader<R, C> map<C>(C Function(A a) f) => ap(pure(f));

  /// Provide the value [R] (dependency) and extract result [A].
  A run(R r) => _read(r);

  static Reader<D, D> ask<D>() => Reader(identity);
}
