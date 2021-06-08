import 'package:fpdart/src/applicative.dart';
import 'package:fpdart/src/hkt.dart';

abstract class Monad<G, A> extends HKT<G, A> with Applicative<G, A> {
  HKT<G, B> flatMap<B>(HKT<G, B> Function(A a) f);

  HKT<G, B> andThen<B>(HKT<G, B> Function() then) => flatMap((_) => then());
}

abstract class Monad2<G, A, B> extends HKT2<G, A, B>
    with Applicative2<G, A, B> {
  HKT2<G, A, C> flatMap<C>(HKT2<G, A, C> Function(B a) f);

  HKT2<G, A, C> andThen<C>(HKT2<G, A, C> Function() then) =>
      flatMap((_) => then());
}
