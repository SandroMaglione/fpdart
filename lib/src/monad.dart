import 'package:fpdart/src/applicative.dart';
import 'package:fpdart/src/hkt.dart';

abstract class Monad<G, A> extends HKT<G, A> with Applicative<G, A> {
  HKT<G, B> flatMap<B>(HKT<G, B> Function(A a) f);
}
