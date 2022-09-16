import 'foldable.dart';
import 'functor.dart';
import 'hkt.dart';

mixin Traversable<KT, A> on HKT<KT, A>, Functor<KT, A>, Foldable<KT, A> {
  HKT<KT, List<B>> Function(List<A> list) traverseListWithIndex<B>(
    HKT<KT, B> Function(A a, int i) f,
  );

  HKT<KT, List<B>> Function(List<A> list) traverseList<B>(
    HKT<KT, B> Function(A a) f,
  );
}
