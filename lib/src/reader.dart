import 'package:fpdart/fpdart.dart';

/// Tag the [HKT2] interface for the actual [Reader].
abstract class ReaderHKT {}

/// `Reader<R, A>` allows to read values `A` from a dependency/context `R`
/// without explicitly passing the dependency between multiple nested
/// function calls.
class Reader<R, A> extends HKT2<ReaderHKT, R, A>
    with
        Functor2<ReaderHKT, R, A>,
        Applicative2<ReaderHKT, R, A>,
        Monad2<ReaderHKT, R, A> {
  final A Function(R r) _read;

  /// Build a [Reader] given `A Function(R)`.
  const Reader(this._read);

  /// Flat a [Option] contained inside another [Option] to be a single [Option].
  factory Reader.flatten(Reader<R, Reader<R, A>> reader) =>
      reader.flatMap(identity);

  /// Apply the function contained inside `a` to change the value of type `A` to
  /// a value of type `B`.
  @override
  Reader<R, C> ap<C>(covariant Reader<R, C Function(A a)> a) =>
      Reader((r) => a.run(r)(run(r)));

  /// Used to chain multiple functions that return a [Reader].
  @override
  Reader<R, C> flatMap<C>(covariant Reader<R, C> Function(A a) f) =>
      Reader((r) => f(run(r)).run(r));

  /// Return a [Reader] containing the value `c`.
  @override
  Reader<R, C> pure<C>(C c) => Reader((_) => c);

  /// Change the value of type `A` to a value of type `C` using function `f`.
  @override
  Reader<R, C> map<C>(C Function(A a) f) => ap(pure(f));

  /// Change type of this [Reader] based on its value of type `A` and the
  /// value of type `C` of another [Reader].
  @override
  Reader<R, D> map2<C, D>(covariant Reader<R, C> m1, D Function(A a, C c) f) =>
      flatMap((a) => m1.map((c) => f(a, c)));

  /// Change type of this [Reader] based on its value of type `A`, the
  /// value of type `C` of a second [Reader], and the value of type `D`
  /// of a third [Reader].
  @override
  Reader<R, E> map3<C, D, E>(covariant Reader<R, C> m1,
          covariant Reader<R, D> m2, E Function(A a, C c, D d) f) =>
      flatMap((a) => m1.flatMap((c) => m2.map((d) => f(a, c, d))));

  /// Chain the result of `then` to this [Reader].
  @override
  Reader<R, C> andThen<C>(covariant Reader<R, C> Function() then) =>
      flatMap((_) => then());

  /// Chain multiple functions having the reader `R`.
  @override
  Reader<R, C> call<C>(covariant Reader<R, C> chain) => flatMap((_) => chain);

  /// Compose the dependency `R` of this [Reader] to `reader`.
  Reader<R, C> compose<C>(Reader<R, C> reader) => Reader((r) => reader.run(r));

  /// Change dependency type of `Reader<R, A>` from `R` to `R1` after calling `run`.
  Reader<R1, A> local<R1>(R Function(R1 context) f) => Reader((r) => run(f(r)));

  /// Read the current dependecy `R`.
  Reader<R, R> ask() => Reader(identity);

  /// Change reading function to `f` given context/dependency `R`.
  Reader<R, A> asks(A Function(R r) f) => Reader((r) => f(r));

  /// Chain a request that returns another [Reader], execute it, ignore
  /// the result, and return the same value as the current [Reader].
  @override
  Reader<R, A> chainFirst<C>(
    covariant Reader<R, C> Function(A a) chain,
  ) =>
      flatMap((a) => chain(a).map((c) => a));

  /// Provide the value `R` (dependency) and extract result `A`.
  A run(R r) => _read(r);

  @override
  bool operator ==(Object other) => (other is Reader) && other._read == _read;

  @override
  int get hashCode => _read.hashCode;
}
