import 'foldable.dart';
import 'hkt.dart';
import 'monad.dart';

/// Tag the `HKT` interface for the actual `Maybe`
abstract class MaybeHKT {}

/// `Maybe<A> implements Functor<MaybeHKT, A>` expresses correctly the
/// return type of the `map` function as `HKT<MaybeHKT, B>`.
/// This tells us that the actual type parameter changed from `A` to `B`,
/// according to the types `A` and `B` of the callable we actually passed as a parameter of `map`.
///
/// Moreover, it informs us that we are still considering an higher kinded type
/// with respect to the `MaybeHKT` tag
abstract class Maybe<A> extends HKT<MaybeHKT, A>
    with Monad<MaybeHKT, A>, Foldable<MaybeHKT, A> {
  @override
  Maybe<B> map<B>(B Function(A a) f);

  @override
  Maybe<B> ap<B>(covariant Maybe<B Function(A a)> a) =>
      a.match((f) => map(f), () => Nothing());

  @override
  Maybe<B> pure<B>(B b) => Just(b);

  @override
  Maybe<B> flatMap<B>(covariant Maybe<B> Function(A a) f);

  /// If `Just` then return the value inside, otherwise return the result of `orElse`.
  A getOrElse(A Function() orElse);

  /// Return the current `Maybe` if it is a `Just`, otherwise return the result of `orElse`.
  Maybe<A> alt(Maybe<A> Function() orElse);

  B match<B>(B Function(A just) onJust, B Function() onNothing);
}

class Just<A> extends Maybe<A> {
  final A a;
  Just(this.a);

  @override
  Maybe<B> map<B>(B Function(A a) f) => Just(f(a));

  @override
  B foldRight<B>(B b, B Function(A a, B b) f) => f(a, b);

  @override
  Maybe<B> flatMap<B>(covariant Maybe<B> Function(A a) f) => f(a);

  @override
  A getOrElse(A Function() orElse) => a;

  @override
  Maybe<A> alt(Maybe<A> Function() orElse) => this;

  @override
  B match<B>(B Function(A just) onJust, B Function() onNothing) => onJust(a);
}

class Nothing<A> extends Maybe<A> {
  @override
  Maybe<B> map<B>(B Function(A a) f) => Nothing();

  @override
  B foldRight<B>(B b, B Function(A a, B b) f) => b;

  @override
  Maybe<B> flatMap<B>(covariant Maybe<B> Function(A a) f) => Nothing();

  @override
  A getOrElse(A Function() orElse) => orElse();

  @override
  Maybe<A> alt(Maybe<A> Function() orElse) => orElse();

  @override
  B match<B>(B Function(A just) onJust, B Function() onNothing) => onNothing();
}
