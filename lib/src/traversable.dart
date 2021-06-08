import 'package:fpdart/src/applicative.dart';
import 'package:fpdart/src/foldable.dart';
import 'package:fpdart/src/functor.dart';
import 'package:fpdart/src/hkt.dart';

abstract class Traversable<G, A> extends HKT<G, A>
    with Functor<G, A>, Foldable<G, A> {
  Applicative<B, HKT<G, C>> traverse<B, C>(Applicative<B, C> Function(A a) f);
}
