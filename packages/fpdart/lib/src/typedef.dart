import 'typeclass/hkt.dart';

typedef Endo<A> = A Function(A a);
typedef Separated<KT, A, B> = (HKT<KT, A>, HKT<KT, B>);
