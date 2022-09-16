import 'foldable.dart';
import 'functor.dart';
import 'hkt.dart';

mixin Traversable<KT, A> on HKT<KT, A>, Functor<KT, A>, Foldable<KT, A> {
  HKT<KT, List<B>> Function(List<A> list) traverseArray<B>(
      HKT<KT, B> Function(int i, A a) f);
}
