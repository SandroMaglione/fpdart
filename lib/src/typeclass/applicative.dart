import 'functor.dart';
import 'hkt.dart';

mixin Applicative<G, A> on HKT<G, A>, Functor<G, A> {
  HKT<G, B> pure<B>(B a);
  HKT<G, B> ap<B>(HKT<G, B Function(A a)> a);

  @override
  HKT<G, B> map<B>(B Function(A a) f) => ap(pure(f));
}

mixin Applicative2<G, A, B> on HKT2<G, A, B>, Functor2<G, A, B> {
  HKT2<G, A, C> pure<C>(C a);
  HKT2<G, A, C> ap<C>(HKT2<G, A, C Function(B a)> a);

  @override
  HKT2<G, A, C> map<C>(C Function(B a) f) => ap(pure(f));
}
