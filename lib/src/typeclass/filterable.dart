import '../either.dart';
import '../maybe.dart';
import '../tuple.dart';
import '../typedef.dart';
import 'functor.dart';
import 'hkt.dart';

abstract class Filterable<KT, A> extends HKT<KT, A> with Functor<KT, A> {
  /// Filter a data structure based on a boolean predicate.
  HKT<KT, A> filter(bool Function(A a) f);

  /// Map over a data structure and filter based on a [Maybe] predicate.
  HKT<KT, Z> filterMap<Z>(Maybe<Z> Function(A a) f);

  /// Partition a data structure based on a boolean predicate.
  Separated<KT, A, A> partition(bool Function(A a) f) =>
      Tuple2(filter((a) => !f(a)), filter(f));

  /// Partition a data structure based on an [Either] predicate.
  Separated<KT, Z, Y> partitionMap<Z, Y>(Either<Z, Y> Function(A a) f);
}
