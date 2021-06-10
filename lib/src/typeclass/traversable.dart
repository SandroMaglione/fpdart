import 'applicative.dart';
import 'foldable.dart';
import 'functor.dart';
import 'hkt.dart';

abstract class Traversable<KT, A> extends HKT<KT, A>
    with Functor<KT, A>, Foldable<KT, A> {
  HKT<ZKT, HKT<KT, Z>> traverse<Z, ZKT>(
      Applicative<ZKT, Z> applicative, HKT<ZKT, Z> Function(A a) f);
}
