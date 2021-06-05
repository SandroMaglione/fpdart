import 'package:fpdart/src/foldable.dart';

import 'functor.dart';
import 'hkt.dart';

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
    with Functor<MaybeHKT, A>, Foldable<MaybeHKT, A> {
  @override
  Maybe<B> map<B>(B Function(A a) f);

  B match<B>(B Function(A just) onJust, B Function() onNothing) =>
      this is Just ? onJust((this as Just<A>).a) : onNothing();
}

class Just<A> extends Maybe<A> {
  final A a;
  Just(this.a);

  @override
  Maybe<B> map<B>(B Function(A a) f) => Just(f(a));

  @override
  B foldRight<B>(B b, B Function(A a, B b) f) => f(a, b);
}

class Nothing<A> extends Maybe<A> {
  @override
  Maybe<B> map<B>(B Function(A a) f) => Nothing();

  @override
  B foldRight<B>(B b, B Function(A a, B b) f) => b;
}

final Maybe<int> maybeInt =
    Just(10).map((a) => 'null').map((a) => 10).map((a) => 10.0).map((a) => 1);
final maybeString = maybeInt.map<String>((a) => a.toString());
