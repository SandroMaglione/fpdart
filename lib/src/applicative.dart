import 'package:fpdart/src/functor.dart';
import 'package:fpdart/src/hkt.dart';

abstract class Applicative<G, A> extends HKT<G, A> with Functor<G, A> {
  HKT<G, B> pure<B>(B a);
  HKT<G, B> ap<B>(HKT<G, B Function(A a)> a);

  @override
  HKT<G, B> map<B>(B Function(A a) f) => ap(pure(f));
}

abstract class Applicative2<G, A, B> extends HKT2<G, A, B>
    with Functor2<G, A, B> {
  HKT2<G, A, C> pure<C>(C a);
  HKT2<G, A, C> ap<C>(HKT2<G, A, C Function(B a)> a);

  @override
  HKT2<G, A, C> map<C>(C Function(B a) f) => ap(pure(f));
}
