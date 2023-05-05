import 'functor.dart';
import 'hkt.dart';

/// `Alt` type class identifies an associative operation on a type constructor.
///
/// It provides an `alt` function used to return an alternative value when the
/// current one represents a failure (for example, [None] for [Option]).
mixin Alt<KT, A> on HKT<KT, A>, Functor<KT, A> {
  HKT<KT, A> alt(HKT<KT, A> Function() orElse);
}

mixin Alt2<KT, A, B> on HKT2<KT, A, B>, Functor2<KT, A, B> {
  HKT2<KT, A, B> alt(HKT2<KT, A, B> Function() orElse);
}
