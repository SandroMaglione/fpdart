import 'hkt.dart';

/// `Functor<G, A> extends HKT<G, A>` to express the fact that the classes implementing
/// the [Functor] interface will need to be higher kinded types.
mixin Functor<G, A> on HKT<G, A> {
  /// Return type is `HKT<G, B>`, which expresses the fact that what
  /// we return is using exactly the same type constructor represented by the brand `G`
  HKT<G, B> map<B>(B Function(A a) f);
}

mixin Functor2<G, A, B> on HKT2<G, A, B> {
  HKT2<G, A, C> map<C>(C Function(B b) f);
}

mixin Functor3<G, A, B, C> on HKT3<G, A, B, C> {
  HKT3<G, A, B, D> map<D>(D Function(C c) f);
}
