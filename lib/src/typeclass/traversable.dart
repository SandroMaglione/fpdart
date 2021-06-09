import 'applicative.dart';
import 'foldable.dart';
import 'functor.dart';
import 'hkt.dart';

abstract class Traversable<G, A> extends HKT<G, A>
    with Functor<G, A>, Foldable<G, A> {
  Applicative<B, HKT<G, C>> traverse<B, C>(Applicative<B, C> Function(A a) f);
}
