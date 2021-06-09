import 'hkt.dart';
import 'functor.dart';

/// `Alt` type class identifies an associative operation on a type constructor.
///
/// It provides an `alt` function used to return an alternative value when the
/// current one represents a failure (for example, [Nothing] for [Maybe]).
abstract class Alt<KT, A> extends HKT<KT, A> with Functor<KT, A> {
  HKT<KT, A> alt(HKT<KT, A> Function() orElse);
}

abstract class Alt2<KT, A, B> extends HKT2<KT, A, B> with Functor2<KT, A, B> {
  HKT2<KT, A, B> alt(HKT2<KT, A, B> Function() orElse);
}
