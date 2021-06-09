import 'tuple.dart';
import 'typeclass/hkt.dart';

typedef Separated<KT, A, B> = Tuple2<HKT<KT, A>, HKT<KT, B>>;
