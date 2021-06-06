import 'package:fpdart/src/functor.dart';
import 'package:fpdart/src/hkt.dart';

abstract class Applicative<G, A> extends HKT<G, A> with Functor<G, A> {
  HKT<G, B> pure<B>(B a);
  HKT<G, B> ap<B>(HKT<G, B Function(A a)> a);

  @override
  HKT<G, B> map<B>(B Function(A a) f) => ap(pure(f));
}
