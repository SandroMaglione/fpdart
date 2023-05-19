import 'tuple.dart';
import 'typeclass/hkt.dart';

typedef Endo<A> = A Function(A a);
typedef Separated<KT, A, B> = Tuple2<HKT<KT, A>, HKT<KT, B>>;
typedef Magma<T> = T Function(T x, T y);
